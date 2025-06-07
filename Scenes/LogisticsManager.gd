extends Node
class_name LogisticsManager


@export var dronePrefab: PackedScene

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

#TEMP DRONE CREATION/DESTRUCTION
func create_drone(amount: int) -> void:
	for x in amount:
		var new_drone = dronePrefab.instantiate()
		free_drones.append(new_drone)

func destroy_drone(amount: int) -> void:
	for x in amount:
		if len(free_drones) > 0:
			for y in free_drones:
				free_drones.remove_at(y)
		elif len(busy_drones) > 0:
			for z in  busy_drones:
				busy_drones.remove_at(z)
		else:
			print("Trying to remove drones when none exist?????")

# to be called by drone factories being placed or destroyed (each factory adds 4 total drones)
func adjust_drone_count(amount: int) -> void:
	max_drones+=amount

#handle drone dispatching
func _process(delta: float) -> void:
	if(free_drones > 0):
		dispatch_drone()
		#check if resouces need to be moved to produce things or out of drills
		#if not then dispatch drones to transport materials to a base which then accepts resources into global inventory (do not worry about this yet)
		#pass
	pass

#this needs to be used by signals of buildings being placed or destroyed
func update_resource_delta(buildable: buildable_data) -> void:
	pass

#spawn a drone and take resources from inventory
func dispatch_drone(drone: Node):

# drones will call this when they transport resources to their destination and despawn
func drone_finished(drone: Node):
	busy_drones.erase(drone) #this is performance intensive and will need to be changed later
	free_drones.append(drone)
	print("Drone: " + drone.name + " Is now free")
