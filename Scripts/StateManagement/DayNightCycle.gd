extends CanvasModulate

# Day/Night cycle configuration
@export_group("Day/Night Cycle")
@export var cycle_duration: float = 120.0  # Duration in seconds for full day/night cycle
@export var start_time: float = 0.0  # 0.0 = noon (bright), 0.5 = midnight (dark), 1.0 = noon again

@export_group("Colors")
@export var day_color: Color = Color(0.95, 0.95, 1.0, 1.0)    # Minimal day tint (slight cool)
@export var dusk_color: Color = Color(0.8, 0.6, 0.4, 1.0)     # Warm evening
@export var night_color: Color = Color(0.3, 0.4, 0.6, 1.0)    # Cool night for contrast
@export var dawn_color: Color = Color(0.7, 0.5, 0.4, 1.0)     # Warm morning

@export_group("Transition Points")
@export_range(0.0, 1.0) var dusk_start: float = 0.2   # When dusk begins (after noon)
@export_range(0.0, 1.0) var night_start: float = 0.3  # When night begins
@export_range(0.0, 1.0) var dawn_start: float = 0.7   # When dawn begins
@export_range(0.0, 1.0) var day_start: float = 0.8    # When day begins (back to noon)

# Internal variables
var current_time: float = 0.0
var time_speed: float = 1.0

# Optional: expose current time info for other systems
signal time_changed(current_time: float, time_of_day: String)
signal day_started()
signal night_started()

func _ready() -> void:
	current_time = start_time
	_update_lighting()

func _process(delta: float) -> void:
	# Update time (frame rate independent)
	current_time += (delta * time_speed) / cycle_duration
	
	# Wrap time between 0.0 and 1.0
	if current_time >= 1.0:
		current_time -= 1.0
	elif current_time < 0.0:
		current_time += 1.0
	
	_update_lighting()
	
	# Emit signals for other systems to use
	var time_of_day = get_time_of_day()
	time_changed.emit(current_time, time_of_day)

func _update_lighting() -> void:
	var target_color: Color
	
	if current_time >= 0.0 and current_time < dusk_start:
		# Day time (noon start)
		target_color = day_color
	elif current_time >= dusk_start and current_time < night_start:
		# Dusk transition
		var progress = (current_time - dusk_start) / (night_start - dusk_start)
		target_color = day_color.lerp(dusk_color, progress)
	elif current_time >= night_start and current_time < dawn_start:
		# Night time - but smooth transition into deep night
		var night_duration = dawn_start - night_start
		var time_into_night = current_time - night_start
		var progress = min(time_into_night / (night_duration * 0.2), 1.0)  # 20% of night for transition
		target_color = dusk_color.lerp(night_color, progress)
	elif current_time >= dawn_start and current_time < day_start:
		# Dawn transition
		var progress = (current_time - dawn_start) / (day_start - dawn_start)
		target_color = night_color.lerp(dawn_color, progress)
	elif current_time >= day_start and current_time <= 1.0:
		# Back to day (completing the cycle)
		var progress = (current_time - day_start) / (1.0 - day_start)
		target_color = dawn_color.lerp(day_color, progress)
	else:
		# Fallback to day
		target_color = day_color
	
	# Apply the color to the CanvasModulate
	color = target_color

func get_time_of_day() -> String:
	if current_time >= 0.0 and current_time < dusk_start:
		return "Day"
	elif current_time >= dusk_start and current_time < night_start:
		return "Dusk"
	elif current_time >= night_start and current_time < dawn_start:
		return "Night"
	elif current_time >= dawn_start and current_time < day_start:
		return "Dawn"
	elif current_time >= day_start and current_time <= 1.0:
		return "Day"
	else:
		return "Day"

# Utility functions for other systems to use
func get_current_time() -> float:
	return current_time

func set_time(new_time: float) -> void:
	current_time = clamp(new_time, 0.0, 1.0)
	_update_lighting()

func set_time_speed(speed: float) -> void:
	time_speed = speed

func is_day_time() -> bool:
	return (current_time >= 0.0 and current_time < dusk_start) or (current_time >= day_start and current_time <= 1.0)

func is_night_time() -> bool:
	return current_time >= night_start and current_time < dawn_start

# Get time as hours (0-24)
func get_time_as_hours() -> float:
	return current_time * 24.0

# Get a normalized brightness value (0.0 = darkest night, 1.0 = brightest day)
func get_brightness() -> float:
	var brightness = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
	return brightness

# Get solar efficiency (0.0 = no power at night, 1.0 = full power at day)
func get_solar_efficiency() -> float:
	# Simple linear mapping based on time of day
	if current_time >= 0.0 and current_time < dusk_start:
		# Full day - maximum efficiency
		return 1.0
	elif current_time >= dusk_start and current_time < night_start:
		# Dusk transition - decreasing efficiency
		var progress = (current_time - dusk_start) / (night_start - dusk_start)
		return 1.0 - progress  # Goes from 1.0 to 0.0
	elif current_time >= night_start and current_time < dawn_start:
		# Night - no solar power
		return 0.0
	elif current_time >= dawn_start and current_time < day_start:
		# Dawn transition - increasing efficiency
		var progress = (current_time - dawn_start) / (day_start - dawn_start)
		return progress  # Goes from 0.0 to 1.0
	elif current_time >= day_start and current_time <= 1.0:
		# Back to full day
		return 1.0
	else:
		return 1.0  # Fallback to day
