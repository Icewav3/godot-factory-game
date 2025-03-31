# Factories/BaseFactory.gd
extends Node2D
class_name BaseFactory

@export var production_interval: float = 3.0  # seconds per production cycle
var timer: float = 0.0

func _ready():
	set_process(true)

func _process(delta: float):
	timer += delta
	if timer >= production_interval:
		timer = 0.0
		_produce()

func _produce():
	# Base method, should be overridden by child classes.
	print("BaseFactory production cycle - override this!")
