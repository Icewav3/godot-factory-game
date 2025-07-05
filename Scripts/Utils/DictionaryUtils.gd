## DictionaryUtils.gd
## A high-performance utility class for advanced dictionary operations in Godot 4.4
## Optimized for frequent calls and resource management scenarios

class_name DictionaryUtils
extends RefCounted

## Static utility class for advanced dictionary operations
## All methods are static for performance and ease of use

#region Dictionary Comparison and Analysis

## Calculates the difference between two dictionaries (dict_a - dict_b)
## Returns a dictionary with positive values where dict_a > dict_b, negative where dict_a < dict_b
## @param dict_a: First dictionary (Dictionary[Variant, Variant])
## @param dict_b: Second dictionary (Dictionary[Variant, Variant])
## @param include_zero: Include keys with zero difference in result
## @return Dictionary with differences
static func get_difference(dict_a: Dictionary, dict_b: Dictionary, include_zero: bool = false) -> Dictionary:
	var result := Dictionary()
	var all_keys := Dictionary()  # Use dict for O(1) lookups
	
	# Collect all unique keys efficiently
	for key in dict_a:
		all_keys[key] = true
	for key in dict_b:
		all_keys[key] = true
	
	# Calculate differences
	for key in all_keys:
		var val_a = dict_a.get(key, 0)
		var val_b = dict_b.get(key, 0)
		var diff = val_a - val_b
		
		if diff != 0 or include_zero:
			result[key] = diff
	
	return result

## Calculates the absolute difference between two dictionaries
## @param dict_a: First dictionary
## @param dict_b: Second dictionary
## @return Dictionary with absolute differences
static func get_absolute_difference(dict_a: Dictionary, dict_b: Dictionary) -> Dictionary:
	var result := Dictionary()
	var all_keys := Dictionary()
	
	for key in dict_a:
		all_keys[key] = true
	for key in dict_b:
		all_keys[key] = true
	
	for key in all_keys:
		var val_a = dict_a.get(key, 0)
		var val_b = dict_b.get(key, 0)
		var diff = abs(val_a - val_b)
		
		if diff > 0:
			result[key] = diff
	
	return result

## Gets only the missing resources (where required > current)
## Optimized for resource management scenarios
## @param required: Dictionary of required amounts
## @param current: Dictionary of current amounts
## @return Dictionary of missing amounts (only positive values)
static func get_missing_resources(required: Dictionary, current: Dictionary) -> Dictionary:
	var missing := Dictionary()
	
	for resource in required:
		var needed = required[resource]
		var available = current.get(resource, 0)
		var shortage = needed - available
		
		if shortage > 0:
			missing[resource] = shortage
	
	return missing

## Gets excess resources (where current > required)
## @param required: Dictionary of required amounts
## @param current: Dictionary of current amounts
## @return Dictionary of excess amounts (only positive values)
static func get_excess_resources(required: Dictionary, current: Dictionary) -> Dictionary:
	var excess := Dictionary()
	
	for resource in current:
		var available = current[resource]
		var needed = required.get(resource, 0)
		var surplus = available - needed
		
		if surplus > 0:
			excess[resource] = surplus
	
	return excess

#endregion

#region Dictionary Arithmetic Operations

## Adds two dictionaries together (dict_a + dict_b)
## @param dict_a: First dictionary
## @param dict_b: Second dictionary
## @return New dictionary with summed values
static func add_dictionaries(dict_a: Dictionary, dict_b: Dictionary) -> Dictionary:
	var result := dict_a.duplicate()
	
	for key in dict_b:
		result[key] = result.get(key, 0) + dict_b[key]
	
	return result

## Subtracts dict_b from dict_a (dict_a - dict_b)
## @param dict_a: Dictionary to subtract from
## @param dict_b: Dictionary to subtract
## @param allow_negative: Allow negative results
## @return New dictionary with subtracted values
static func subtract_dictionaries(dict_a: Dictionary, dict_b: Dictionary, allow_negative: bool = true) -> Dictionary:
	var result := dict_a.duplicate()
	
	for key in dict_b:
		var new_value = result.get(key, 0) - dict_b[key]
		if allow_negative or new_value >= 0:
			result[key] = new_value
		elif result.has(key):
			result.erase(key)
	
	return result

## Multiplies all values in a dictionary by a scalar
## @param dict: Dictionary to multiply
## @param multiplier: Scalar multiplier
## @return New dictionary with multiplied values
static func multiply_dictionary(dict: Dictionary, multiplier: float) -> Dictionary:
	var result := Dictionary()
	
	for key in dict:
		result[key] = dict[key] * multiplier
	
	return result

## Scales a dictionary by another dictionary (element-wise multiplication)
## @param dict_a: First dictionary
## @param dict_b: Dictionary of multipliers
## @return New dictionary with scaled values
static func scale_dictionary(dict_a: Dictionary, dict_b: Dictionary) -> Dictionary:
	var result := Dictionary()
	
	for key in dict_a:
		if dict_b.has(key):
			result[key] = dict_a[key] * dict_b[key]
		else:
			result[key] = dict_a[key]
	
	return result

#endregion

#region Dictionary Analysis and Statistics

## Calculates the sum of all values in a dictionary
## @param dict: Dictionary to sum
## @return Sum of all values
static func sum_values(dict: Dictionary) -> float:
	var total := 0.0
	
	for value in dict.values():
		total += value
	
	return total

## Gets the total count of all materials in a resource dictionary
## Optimized for Dictionary[MaterialData, int] format where int represents quantity
## @param materials_dict: Dictionary mapping MaterialData to quantities
## @return Total count of all materials combined
static func get_total_material_count(materials_dict: Dictionary) -> int:
	var total_count := 0
	
	for quantity in materials_dict.values():
		total_count += quantity
	
	return total_count

## Gets the count of unique material types in a resource dictionary
## @param materials_dict: Dictionary mapping MaterialData to quantities
## @return Number of different material types (keys) in the dictionary
static func get_unique_material_count(materials_dict: Dictionary) -> int:
	return materials_dict.size()

## Gets detailed material statistics for a resource dictionary
## @param materials_dict: Dictionary mapping MaterialData to quantities
## @return Dictionary with statistics: total_count, unique_count, average_per_type
static func get_material_statistics(materials_dict: Dictionary) -> Dictionary:
	var stats := Dictionary()
	var total_count = get_total_material_count(materials_dict)
	var unique_count = get_unique_material_count(materials_dict)
	
	stats["total_count"] = total_count
	stats["unique_count"] = unique_count
	stats["average_per_type"] = float(total_count) / float(unique_count) if unique_count > 0 else 0.0
	
	return stats

## Finds the key with the maximum value
## @param dict: Dictionary to search
## @return Key with maximum value, or null if empty
static func get_max_key(dict: Dictionary) -> Variant:
	if dict.is_empty():
		return null
	
	var max_key = null
	var max_value = -INF
	
	for key in dict:
		if dict[key] > max_value:
			max_value = dict[key]
			max_key = key
	
	return max_key

## Finds the key with the minimum value
## @param dict: Dictionary to search
## @return Key with minimum value, or null if empty
static func get_min_key(dict: Dictionary) -> Variant:
	if dict.is_empty():
		return null
	
	var min_key = null
	var min_value = INF
	
	for key in dict:
		if dict[key] < min_value:
			min_value = dict[key]
			min_key = key
	
	return min_key

## Gets the maximum value in the dictionary
## @param dict: Dictionary to search
## @return Maximum value, or -INF if empty
static func get_max_value(dict: Dictionary) -> float:
	if dict.is_empty():
		return -INF
	
	var max_value := -INF
	
	for value in dict.values():
		if value > max_value:
			max_value = value
	
	return max_value

## Gets the minimum value in the dictionary
## @param dict: Dictionary to search
## @return Minimum value, or INF if empty
static func get_min_value(dict: Dictionary) -> float:
	if dict.is_empty():
		return INF
	
	var min_value := INF
	
	for value in dict.values():
		if value < min_value:
			min_value = value
	
	return min_value

#endregion

#region Dictionary Filtering and Transformation

## Filters dictionary by value predicate
## @param dict: Dictionary to filter
## @param min_value: Minimum value (inclusive)
## @param max_value: Maximum value (inclusive)
## @return Filtered dictionary
static func filter_by_value_range(dict: Dictionary, min_value: float = -INF, max_value: float = INF) -> Dictionary:
	var result := Dictionary()
	
	for key in dict:
		var value = dict[key]
		if value >= min_value and value <= max_value:
			result[key] = value
	
	return result

## Filters dictionary to only include positive values
## @param dict: Dictionary to filter
## @return Dictionary with only positive values
static func filter_positive(dict: Dictionary) -> Dictionary:
	return filter_by_value_range(dict, 0.001)  # Slightly above 0 to avoid floating point issues

## Filters dictionary to only include negative values
## @param dict: Dictionary to filter
## @return Dictionary with only negative values
static func filter_negative(dict: Dictionary) -> Dictionary:
	return filter_by_value_range(dict, -INF, -0.001)

## Removes keys with zero or near-zero values
## @param dict: Dictionary to clean
## @param epsilon: Threshold for considering a value as zero
## @return Cleaned dictionary
static func remove_zeros(dict: Dictionary, epsilon: float = 0.0001) -> Dictionary:
	var result := Dictionary()
	
	for key in dict:
		if abs(dict[key]) > epsilon:
			result[key] = dict[key]
	
	return result

## Normalizes dictionary values to sum to 1.0
## @param dict: Dictionary to normalize
## @return Normalized dictionary
static func normalize(dict: Dictionary) -> Dictionary:
	var total = sum_values(dict)
	if total == 0.0:
		return Dictionary()
	
	return multiply_dictionary(dict, 1.0 / total)

#endregion

#region Dictionary Conversion and Utility

## Converts dictionary to sorted array of [key, value] pairs
## @param dict: Dictionary to convert
## @param ascending: Sort in ascending order by value
## @return Array of [key, value] arrays sorted by value
static func to_sorted_pairs(dict: Dictionary, ascending: bool = true) -> Array:
	var pairs := []
	
	for key in dict:
		pairs.append([key, dict[key]])
	
	if ascending:
		pairs.sort_custom(func(a, b): return a[1] < b[1])
	else:
		pairs.sort_custom(func(a, b): return a[1] > b[1])
	
	return pairs

## Inverts a dictionary (swaps keys and values)
## Warning: Values must be hashable and unique
## @param dict: Dictionary to invert
## @return Inverted dictionary
static func invert_dictionary(dict: Dictionary) -> Dictionary:
	var result := Dictionary()
	
	for key in dict:
		result[dict[key]] = key
	
	return result

## Checks if dict_a can satisfy dict_b (all values in dict_a >= dict_b)
## Useful for resource requirement checking
## @param available: Dictionary of available amounts
## @param required: Dictionary of required amounts
## @return True if available can satisfy required
static func can_satisfy(available: Dictionary, required: Dictionary) -> bool:
	for resource in required:
		if available.get(resource, 0) < required[resource]:
			return false
	
	return true

## Calculates satisfaction ratio (how much of requirements can be met)
## @param available: Dictionary of available amounts
## @param required: Dictionary of required amounts
## @return Float between 0.0 and 1.0 representing satisfaction ratio
static func get_satisfaction_ratio(available: Dictionary, required: Dictionary) -> float:
	if required.is_empty():
		return 1.0
	
	var total_required := 0.0
	var total_satisfied := 0.0
	
	for resource in required:
		var req_amount = required[resource]
		var avail_amount = available.get(resource, 0)
		
		total_required += req_amount
		total_satisfied += min(avail_amount, req_amount)
	
	return total_satisfied / total_required if total_required > 0 else 1.0

#endregion

#region Performance Optimized Batch Operations

## Performs multiple dictionary operations in a single pass for better performance
## @param operations: Array of operation dictionaries with "type" and "data" keys
## @param base_dict: Base dictionary to operate on
## @return Result dictionary after all operations
static func batch_operations(operations: Array, base_dict: Dictionary) -> Dictionary:
	var result := base_dict.duplicate()
	
	for op in operations:
		match op.get("type", ""):
			"add":
				for key in op.data:
					result[key] = result.get(key, 0) + op.data[key]
			"subtract":
				for key in op.data:
					var new_val = result.get(key, 0) - op.data[key]
					if new_val != 0:
						result[key] = new_val
					elif result.has(key):
						result.erase(key)
			"multiply":
				var multiplier = op.get("multiplier", 1.0)
				for key in result:
					result[key] *= multiplier
			"filter_positive":
				var keys_to_remove := []
				for key in result:
					if result[key] <= 0:
						keys_to_remove.append(key)
				for key in keys_to_remove:
					result.erase(key)
	
	return result

#endregion
