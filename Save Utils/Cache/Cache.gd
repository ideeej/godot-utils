extends Node

export(bool) var debugging = false

signal stored(data, key)
signal cache_saved(data)
signal cache_loaded(data)

# The cached data is store here
# Everytime the game is closed "cache" is automatically saved to a file
# The "cache" can also be saved manually if needed
var cache: Dictionary = {}

func _ready():
	var _stored = connect("stored", self, "_on_data_stored")
	var _cache_saved = connect("cache_saved", self, "_on_cache_saved")
	var _cache_loaded = connect("cache_loaded", self, "_on_cache_loaded")

	
	# Read from the cache file
	cache = load_cache()


func _exit_tree():
	# Save to the cache file
	save_cache()


func _on_data_stored(data, key):
    if debugging:
        print("========== Data Stored ==========")
        print("Data: %s" % [data])
        print("Key: %s" % [key])
        print("=================================\n")


func _on_cache_saved(data):
    if debugging:
        print("========== Cache saved ==========")
        print("Data: %s" % [data])
        print("=================================\n")


func _on_cache_loaded(data):
    if debugging:
        print("========== Cache loaded ==========")
        print("Data: %s" % [data])
        print("==================================\n")



func store(key, data):
    cache[key] = data
    emit_signal("stored", data, key)


func delete(key):
    if cache.has(key):
        var erased = cache.erase(key)
        if not erased:
            push_error("Something went wrong trying to delete the key '%s'" % key)


func save_cache():
	if not cache:
		push_warning("Could not save cache, because cache does nothing to save.")
		return
	
	var cache_file = File.new()
	cache_file.open("user://cache.save", File.WRITE)
	cache_file.store_line(to_json(cache))
	cache_file.close()
	
	emit_signal("cache_saved", cache)


func load_cache():
    var cached_data = {}
    var cache_file = File.new()
    if not cache_file.file_exists("user://cache.save"):
        push_warning("No cache file found.")
        return cached_data # We don't have a save to load.

    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    cache_file.open("user://cache.save", File.READ)
    while cache_file.get_position() < cache_file.get_len():
        # Get the saved dictionary from the next line in the save file
        cached_data = parse_json(cache_file.get_line())
    cache_file.close()
    
    if !cached_data:
        # If for some reason Null gets saved to the cache
        # or a broken JSON file
        push_warning("Cache is broken or empty. %s" % str(cached_data))

    emit_signal("cache_loaded", cached_data)
    return cached_data
