extends BaseDrill
class_name WaterDrill

func _attempt_extract():
	if not target_material:
		print("No material detected under WaterDrill.")
		return

	# Check all required fuel inputs
	for fuel in drill_data.fuel_types.keys():
		var required_amount = drill_data.fuel_types[fuel]
		if not inventory.has_enough(fuel, required_amount):
			print("Missing required fuel: ", fuel.material_name)
			return

	# Consume all fuel inputs
	for fuel in drill_data.fuel_types.keys():
		var required_amount = drill_data.fuel_types[fuel]
		inventory.remove_resource(fuel, required_amount)

	# Extract the resource
	inventory.add_resource(target_material, drill_data.mining_rate)
	print("WaterDrill extracted ", target_material.material_name)
