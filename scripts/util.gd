class_name Util
extends Node

static func compare_dicts(dict_a: Dictionary, dict_b: Dictionary) -> Dictionary:
	var results = {
		"is_equal": true,
		"missing_in_b": [],
		"missing_in_a": [],
		"mismatched_values": {}
	}

	# check for keys present in A but missing in B, and check for mismatches
	for key in dict_a:
		if not dict_b.has(key):
			results["missing_in_b"].append(key)
			results["is_equal"] = false
		else:
			# if both have the key, compare the values
			var val_a = dict_a[key]
			var val_b = dict_b[key]

			# if the values are nested dictionaries, compare them recursively
			if typeof(val_a) == TYPE_DICTIONARY and typeof(val_b) == TYPE_DICTIONARY:
				var nested_res = compare_dicts(val_a, val_b)
				if not nested_res["is_equal"]:
					results["mismatched_values"][key] = nested_res
					results["is_equal"] = false
			# otherwise, do a standard value check
			elif val_a != val_b:
				results["mismatched_values"][key] = {"val_a": val_a, "val_b": val_b}
				results["is_equal"] = false

	# check for keys present in B but missing in A
	for key in dict_b:
		if not dict_a.has(key):
			results["missing_in_a"].append(key)
			results["is_equal"] = false

	return results
