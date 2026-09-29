extends Node

# This script runs in the background at all times.
# It remembers data as you move between menus and the arena.

var current_mode = "LOCAL"
var player_faction = "Dominion of Sol"
var player_deck = [] # Will hold the 6 cards you select

func _ready():
	print("Global GameState is active!")
	load_deck()
	
func save_deck():
	var save_path = "user://local_deck.json"
	if current_mode == "ONLINE" or current_mode == "ONLINE_HOST" or current_mode == "ONLINE_JOIN":
		save_path = "user://online_deck.json"
		
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(player_deck)
		file.store_string(json)
		file.close()
		
func load_deck():
	var load_path = "user://local_deck.json"
	if current_mode == "ONLINE" or current_mode == "ONLINE_HOST" or current_mode == "ONLINE_JOIN":
		load_path = "user://online_deck.json"
		
	if FileAccess.file_exists(load_path):
		var file = FileAccess.open(load_path, FileAccess.READ)
		var json = file.get_as_text()
		file.close()
		
		var parsed = JSON.parse_string(json)
		if typeof(parsed) == TYPE_ARRAY:
			player_deck = parsed
