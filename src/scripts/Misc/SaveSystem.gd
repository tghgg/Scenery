class_name SaveSystem

# Save file location
const save_name := "user://AWoO.save"

# Set a key in the save file
func set_save_data(key: String, val, _subkey := "") -> void:
	var save_file: File = File.new()

	# Stop if the save file doesn't exist
	if not save_file.file_exists(save_name): return

	save_file.open(save_name, File.READ_WRITE)

	var data: Dictionary = parse_json(save_file.get_as_text())

	if _subkey != "":
		data[key][_subkey] = val
	else:
		data[key] = val

	save_file.store_line(to_json(data))
	save_file.close()


# Append a subkey to an already existing key
func append_save_data(key: String, subkey_name: String, subkey_val) -> void:
	var current_save_data = get_save_data()

	if current_save_data.has(key):
		current_save_data[key][subkey_name] = subkey_val
		# Set the save file to the new save with the subkey added
		set_save_data(key, current_save_data[key])


# Load the save file
func get_save_data() -> Dictionary:
	var save_file: File = File.new()

	# Stop if the save file doesn't exist
	if not save_file.file_exists(save_name): return {}

	save_file.open(save_name, File.READ)

	var data: Dictionary = parse_json(save_file.get_as_text())

	save_file.close()

	return data


# Delete a key in the save data
func delete_save_data_subkey(key: String, subkey_name: String) -> void:
	var current_save_data = get_save_data()
	if current_save_data.has(key):
		if current_save_data[key].has(subkey_name):
			current_save_data[key].erase(subkey_name)
			set_save_data(key, current_save_data[key])
