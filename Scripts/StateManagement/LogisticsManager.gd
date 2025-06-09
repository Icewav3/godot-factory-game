extends Node
class_name LogisticsManager


@export var dronePrefab: PackedScene
@export var BuildableParent: PackedScene = null #unused atm

#BUILDING TRACKING
#potentially should store node refrences? data is not useful here as we need mroe than just static info
var buildings: Dictionary[Node, buildable_data] = {}

#RESOURCE TRACKING

var resource_delta: Dictionary[MaterialData, int] = {}

#DRONE TRACKING
#if nothing set defualt to 4 drones
var max_drones: int = 4
#drones curerntly in use (transporting mats)
var busy_drones: Array[Node] = []
#drones free to be spawned and tasked (idle)
var free_drones: Array[Node] = []

#INITALIZATION

func _ready() -> void:
	calculate_resource_delta()
	
#RESOURCES
#this will check everything (used for initalization)
func calculate_resource_delta() -> void:
	#this stuff is fakked TODO die
	for node in get_tree().get_nodes_in_group("Buildable"):
		var material: MaterialData = node.data
		if resource_delta.has(material):
			resource_delta[material] += material.data
		else:
			resource_delta[material] = material.data
	#TODO
	
#this needs to be used by signals of buildings being placed or destroyed
func update_resource_delta(buildable: buildable_data) -> void:
	pass
	#TODO
	
	
	
#TEMP DRONE CREATION/DESTRUCTION
func create_drone(amount: int) -> void:
	for x in amount:
		var new_drone = dronePrefab.instantiate()
		free_drones.append(new_drone)

func destroy_drone(amount: int) -> void:
	for x in range(amount): # Iterate 'amount' times
		if len(free_drones) > 0:
			var drone_to_destroy: Node = free_drones.pop_front() # Safely remove and get the first free drone
			drone_to_destroy.queue_free()
		elif len(busy_drones) > 0:
			var drone_to_destroy: Node = busy_drones.pop_front() # Safely remove and get the first busy drone
			drone_to_destroy.queue_free()
		else:
			print("Trying to remove drones when none exist?????")

# to be called by drone factories being placed or destroyed (each factory adds 4 total drones)
func adjust_drone_count(amount: int) -> void:
	max_drones+=amount

#handle drone dispatching
func _process(delta: float) -> void:
	if (len(free_drones) > 0):
		dispatch_drone()
		#check if resouces need to be moved to produce things or out of drills
		#if not then dispatch drones to transport materials to a base which then accepts resources into global inventory (do not worry about this yet)
		#pass
	pass
	#TODO



#spawn a drone and take resources from inventory
func dispatch_drone():
	pass
	#TODO
# drones will call this when they transport resources to their destination and despawn
func drone_finished(drone: Node):
	busy_drones.erase(drone) #this is performance intensive and will need to be changed later
	free_drones.append(drone)
	print("Drone: " + drone.name + " Is now free")
