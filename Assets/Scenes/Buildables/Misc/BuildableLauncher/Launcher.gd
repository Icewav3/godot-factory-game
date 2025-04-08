extends Node2D
class_name Launcher

@export var Cooldown: float = 5

@onready var inventory: InventoryComponent = $InventoryComponent
@onready var InventoryManager: InventoryManager

var _timer: Timer
var can_launch: bool = true

func _ready():
	# Create and configure the cooldown timer
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = Cooldown
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func launch():
	if not can_launch:
		return

	_uploadResources()
	can_launch = false
	_timer.start()

func _uploadResources():
	# Get current inventory contents
	var current_inventory = inventory.inventory

	# Upload each resource to the InventoryManager
	for material in current_inventory:
		var amount = current_inventory[material]
		InventoryManager.add_resource(material, amount)

	# Clear the inventory after uploading
	inventory.clear_inventory()

func _on_timer_timeout():
	can_launch = true