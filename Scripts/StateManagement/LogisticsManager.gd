# ---------------------------------------------------------------------------
# LogisticsManager.gd
# ---------------------------------------------------------------------------
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

# key  = _make_key(actor, material)
# value = ResourceRequest / ResourceOffer
var request_map: Dictionary = {}     # Dictionary[String, ResourceRequest]
var offer_map:   Dictionary = {}     # Dictionary[String, ResourceOffer]

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

func _make_key(actor: Node, material: MaterialData) -> String:
	# `get_instance_id()` is stable for the lifetime of the object.
	# Using ':' keeps it readable in the debugger.
	return "%s:%s" % [actor.get_instance_id(), material.get_instance_id()]


func _process_queues() -> void:
	if request_map.is_empty() or offer_map.is_empty():
		return

	# Make a snapshot of keys to allow mutation during iteration
	var request_keys := request_map.keys()

	for key in request_keys:
		if !request_map.has(key):
			continue
		var request: ResourceRequest = request_map[key]

		# Search through offer keys (copy to avoid modification issues)
		var offer_keys := offer_map.keys()

		for offer_key in offer_keys:
			if !offer_map.has(offer_key):
				continue
			var offer: ResourceOffer = offer_map[offer_key]

			if offer.material != request.material:
				continue

			var transfer_amount: int = min(request.amount, offer.amount)

			if drone_manager.dispatch_drone(
					offer.provider, request.requester,
					request.material, transfer_amount):

				request.amount -= transfer_amount
				offer.amount   -= transfer_amount

				if request.amount <= 0:
					request_map.erase(key)
				if offer.amount <= 0:
					offer_map.erase(offer_key)

				break  # Move to next request


# Called by buildings that need something
func _on_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	var key := _make_key(building, material)
	var req: ResourceRequest = request_map.get(key, null)

	if req:
		# --- Replace the existing entry ----
		req.amount     = amount       # overwrite with latest quantity
		req.timestamp  = Time.get_unix_time_from_system()
	else:
		# --- First time we see this pair ----
		req = ResourceRequest.new()
		req.requester  = building
		req.material   = material
		req.amount     = amount
		req.timestamp  = Time.get_unix_time_from_system()
		request_map[key] = req

func _on_resource_available(building: Node, material: MaterialData, amount: int) -> void:
	var key := _make_key(building, material)
	var offer: ResourceOffer = offer_map.get(key, null)

	if offer:
		offer.amount    = amount
		offer.timestamp = Time.get_unix_time_from_system()
	else:
		offer = ResourceOffer.new()
		offer.provider  = building
		offer.material  = material
		offer.amount    = amount
		offer.timestamp = Time.get_unix_time_from_system()
		offer_map[key] = offer

func _on_drone_available() -> void:
	# A drone just became available, try to process more requests
	_process_queues()

# Public methods for external building registration
func register_building(building: Node) -> void:
	building_tracker.register_building(building)
	print("Registered "+building.name)

func get_queue_status() -> Dictionary:
	return {
		"requests": request_map.size(),
		"offers"  : offer_map.size(),
		"available_drones": drone_manager.get_available_drone_count(),
		"busy_drones"     : drone_manager.get_busy_drone_count(),
	}
