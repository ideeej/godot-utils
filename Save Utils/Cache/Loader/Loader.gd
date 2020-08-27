extends Node


signal loading_status(dir, status)

# All resources are stored here, for easy later use
var resources: Dictionary = {}

func _ready():
	connect("loading_status", self, "_on_loading_status")
	
	# Stores it in RAM (I think)
	# MAYBE... this is bad, but i don't think i will ever have more than 500MB
	# Should be fiiiiine...
	var loaded = _load_all_resources_from("res://Assets")
	if loaded == OK:
		print("========== Loader ==========")
		print("")
		print("   Loaded everything OK")
		print("")
		print("============================\n")


func _on_loading_status(dir, status):
	if status != OK:
		print("[LOADING STATUS] %s for directory %s" % [status, dir])


func get_resource(resource_name):
	if resources.has(resource_name):
		return resources[resource_name]
	else:
		return ERR_DOES_NOT_EXIST


# Does a deep search inside the scan_dir and loads each resource into "resources"
# https://godotengine.org/qa/30423/files-folders-subfolders-outside-godot-project-directory
func _load_all_resources_from(scan_dir : String):
	var dir := Directory.new()
	var open_file_status = dir.open(scan_dir)
	if open_file_status != OK:
		emit_signal("loading_status", scan_dir, open_file_status)
		return open_file_status
	
	var skip_navigational = true
	var skip_hidden = true
	var list_content_status = dir.list_dir_begin(skip_navigational, skip_hidden)
	if list_content_status != OK:
		emit_signal("loading_status", scan_dir, list_content_status)
		return list_content_status
	
	var file_name := dir.get_next()
	while file_name != "":
		var full_path: String = dir.get_current_dir().plus_file(file_name)
		
		if dir.current_is_dir():
			var recursive_loading_status = _load_all_resources_from(full_path)
			if recursive_loading_status != OK:
				emit_signal("loading_status", full_path, recursive_loading_status)
				return recursive_loading_status
		else:
			if not (file_name.ends_with(".import") or file_name.ends_with(".cfg")):
				# Save that bad boy in resources
				resources[file_name.get_basename()] = load(full_path)
		file_name = dir.get_next()
		
	emit_signal("loading_status", scan_dir, OK)
	return OK


# With "get_all_files_from" now this function is deprecated i guess?
# Keeping it here, because i'm not sure
# Loads everything inside "path" with extension "extension"
# and returns a dictionary containing the loaded value from path/filename
#func _load_all_from(path: String, extension: String):
#	var dir = Directory.new()
#	var result: Dictionary = {}
#
#	assert(dir.dir_exists(path))
#	if not dir.open(path) == OK:
#		print("Could not read directory %s" % path)
#
#	dir.list_dir_begin()
#	var file_name: String
#	while true:
#		file_name = dir.get_next()
#		if file_name == "":
#			break
#		if not file_name.ends_with(extension):
#			continue
#
#		# Creates a property inside result using the filename
#		# The value is whatever gets loaded from "path/filename"
#		result[file_name.get_basename()] = load(path.plus_file(file_name))
#
#	return result
#
#
#func _load_all_json_from(path: String):
#	# JSON is a little trickier, that's why i made this other function
#	var dir = Directory.new()
#	var result: Dictionary = {}
#
#	assert(dir.dir_exists(path))
#	if not dir.open(path) == OK:
#		print("Could not read directory %s" % path)
#
#	dir.list_dir_begin()
#	var file_name: String
#	while true:
#		file_name = dir.get_next()
#		if file_name == "":
#			break
#		if not file_name.ends_with(".json"):
#			continue
#
#		var json_file = File.new()
#		var json_path: String = path.plus_file(file_name)
#
#		json_file.open(json_path, File.READ)
#		result[file_name.get_basename()] = JSON.parse(json_file.get_as_text()).result as Dictionary
#		json_file.close()
#
#	return result
#
