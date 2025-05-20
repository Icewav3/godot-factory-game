# Factories/BaseFactory.gd
extends Node2D
class_name BaseFactory

@export var production_interval: float = 3.0  # seconds per production cycle
# This gets the inventory component to store and draw from
@onready var inventory: InventoryComponent = $InventoryComponent

var timer: float = 0.0
var _is_paused: bool = false

func _ready():
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
	else:
		printerr("Error: InventoryComponent not found on " + name + "!")
	# Ensure _process is enabled in the base class
	set_process(true)

func _process(delta: float):
	if !_is_paused:
		timer += delta
		if timer >= production_interval:
			timer = 0.0
			_produce()

func _produce():
	# Base method, should be overridden by child classes.
	print("BaseFactory production cycle - override this!")
	
func _on_inventory_full_changed(is_full: bool) -> void:
	_is_paused = is_full
	if _is_paused:
		print(name + ": Production paused - Inventory full.")
	else:
		print(name + ": Production resumed - Inventory not full.")
