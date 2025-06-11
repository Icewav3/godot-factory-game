# =============================================================================
# LogisticsManager.gd - High-level coordination and request queue
# =============================================================================
extends Node
class_name LogisticsManager

static var instance: LogisticsManager

class ResourceRequest:
	var requester: Node
	var material: MaterialData
	var amount: int
	var timestamp: float

class ResourceOffer:
	var provider: Node
	var material: MaterialData
	var amount: int
	var timestamp: float

var request_queue: Array[ResourceRequest] = []
var offer_queue: Array[ResourceOffer] = []

@onready var drone_manager: DroneManager = $DroneManager
@onready var building_tracker: BuildingTracker = $BuildingTracker

func _ready() -> void:
	instance = self
	# Connect to drone manager signals
	drone_manager.drone_available.connect(_on_drone_available)
	
	# Start processing queue
	set_process(true)
	
#Cleanup
func _exit_tree():
	instance = null
	
func _process(delta: float) -> void:
	_process_queues()

func _process_queues() -> void:
	if request_queue.is_empty() or offer_queue.is_empty():
		return
	
	# Try to match requests with offers
	for i in range(request_queue.size() - 1, -1, -1):  # Iterate backwards
		var request = request_queue[i]
		
		# Find matching offer
		for j in range(offer_queue.size() - 1, -1, -1):
			var offer = offer_queue[j]
			
			if offer.material == request.material:
				var transfer_amount = min(request.amount, offer.amount)
				
				# Try to dispatch drone
				if drone_manager.dispatch_drone(offer.provider, request.requester, 
												request.material, transfer_amount):
					# Update quantities
					request.amount -= transfer_amount
					offer.amount -= transfer_amount
					
					# Remove completed requests/offers
					if request.amount <= 0:
						request_queue.remove_at(i)
					if offer.amount <= 0:
						offer_queue.remove_at(j)
					
					break  # Move to next request

func _on_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	var request = ResourceRequest.new()
	request.requester = building
	request.material = material
	request.amount = amount
	request.timestamp = Time.get_unix_time_from_system()
	
	request_queue.append(request)

func _on_resource_available(building: Node, material: MaterialData, amount: int) -> void:
	var offer = ResourceOffer.new()
	offer.provider = building
	offer.material = material
	offer.amount = amount
	offer.timestamp = Time.get_unix_time_from_system()
	
	offer_queue.append(offer)

func _on_drone_available() -> void:
	# A drone just became available, try to process more requests
	_process_queues()

# Public methods for external building registration
func register_building(building: Node) -> void:
	building_tracker.register_building(building)
	print("Registered "+building.name)

func get_queue_status() -> Dictionary:
	return {
		"requests": request_queue.size(),
		"offers": offer_queue.size(),
		"available_drones": drone_manager.get_available_drone_count(),
		"busy_drones": drone_manager.get_busy_drone_count()
	}
