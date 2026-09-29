extends Control

var all_cards = []
var deck_commander = null
var deck_units = []

@onready var main_body = $MainBody
var card_ui_scene = preload("res://Scenes/CardUI.tscn")

var left_grid: GridContainer
var right_commander_slot: CenterContainer
var right_deck_grid: GridContainer
var count_label: Label

func _ready():
	# Load existing deck from GameState if we have one
	load_all_cards()
	build_ui()
	
	# Pre-load whatever is in GameState
	for c_name in GameState.player_deck:
		var res = load("res://Data/Cards/" + c_name + ".tres")
		if res:
			if res.card_type == "Commander":
				deck_commander = res
			else:
				deck_units.append(res)
				
	refresh_ui()

func load_all_cards():
	var dir = DirAccess.open("res://Data/Cards")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".tres.remap")):
				# Trim .remap if it exists (Godot export behavior)
				var clean_name = file_name.trim_suffix(".remap")
				var res = load("res://Data/Cards/" + clean_name)
				if res is CardData:
					all_cards.append(res)
			file_name = dir.get_next()

func build_ui():
	# Left Panel (Collection)
	var left_panel = PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_body.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_panel.add_child(left_vbox)
	
	var tab_bar = TabBar.new()
	tab_bar.add_tab("Dominion of Sol")
	tab_bar.add_tab("The Void Swarm")
	tab_bar.connect("tab_changed", Callable(self, "_on_tab_changed"))
	left_vbox.add_child(tab_bar)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(scroll)
	
	left_grid = GridContainer.new()
	left_grid.columns = 4
	scroll.add_child(left_grid)
	
	# Populate initial Collection
	_on_tab_changed(0)
	
	# Right Panel (Your Deck)
	var right_panel = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(400, 0)
	main_body.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_panel.add_child(right_vbox)
	
	var deck_title = Label.new()
	deck_title.text = "-- Your Army --"
	deck_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_vbox.add_child(deck_title)
	
	var cmdr_label = Label.new()
	cmdr_label.text = "Commander (1/1)"
	right_vbox.add_child(cmdr_label)
	
	right_commander_slot = CenterContainer.new()
	right_commander_slot.custom_minimum_size = Vector2(0, 220)
	right_vbox.add_child(right_commander_slot)
	
	count_label = Label.new()
	count_label.text = "Units & Spells (0/5)"
	right_vbox.add_child(count_label)
	
	right_deck_grid = GridContainer.new()
	right_deck_grid.columns = 2
	right_deck_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(right_deck_grid)
	
	var save_btn = Button.new()
	save_btn.text = "Save & Return to Hub"
	save_btn.custom_minimum_size = Vector2(0, 60)
	save_btn.add_theme_font_size_override("font_size", 24)
	save_btn.connect("pressed", Callable(self, "_on_back_pressed"))
	right_vbox.add_child(save_btn)

func _on_tab_changed(tab_idx: int):
	for c in left_grid.get_children():
		left_grid.remove_child(c)
		c.queue_free()
		
	for card_data in all_cards:
		var is_void = "Void" in card_data.card_name
		if (tab_idx == 0 and not is_void) or (tab_idx == 1 and is_void):
			var c = card_ui_scene.instantiate()
			c.card_data = card_data
			c.connect("card_clicked", Callable(self, "_on_collection_card_clicked"))
			left_grid.add_child(c)

func _on_collection_card_clicked(card_ui):
	var data = card_ui.card_data
	if data.card_type == "Commander":
		deck_commander = data
	else:
		if deck_units.size() < 5 and not deck_units.has(data):
			deck_units.append(data)
	refresh_ui()

func _on_deck_card_clicked(card_ui):
	var data = card_ui.card_data
	if data.card_type == "Commander":
		deck_commander = null
	else:
		deck_units.erase(data)
	refresh_ui()

func refresh_ui():
	# Clear right side
	for c in right_commander_slot.get_children():
		right_commander_slot.remove_child(c)
		c.queue_free()
	for c in right_deck_grid.get_children():
		right_deck_grid.remove_child(c)
		c.queue_free()
		
	# Rebuild right side
	if deck_commander:
		var c = card_ui_scene.instantiate()
		c.card_data = deck_commander
		c.connect("card_clicked", Callable(self, "_on_deck_card_clicked"))
		right_commander_slot.add_child(c)
		
	for u in deck_units:
		var c = card_ui_scene.instantiate()
		c.card_data = u
		c.connect("card_clicked", Callable(self, "_on_deck_card_clicked"))
		right_deck_grid.add_child(c)
		
	count_label.text = "Units, Spells, Vehicles (" + str(deck_units.size()) + "/5)"

func _on_back_pressed():
	if deck_commander == null or deck_units.size() < 5:
		print("Cannot save! You must have exactly 1 Commander and 5 Units/Spells.")
		count_label.text = "ERROR: Need 1 Cmdr and 5 Units!"
		return
		
	# Save to GameState!
	GameState.player_deck.clear()
	if deck_commander:
		GameState.player_deck.append(deck_commander.card_name.replace(" ", "") + "Card")
	for u in deck_units:
		GameState.player_deck.append(u.card_name.replace(" ", "") + "Card")
		
	GameState.save_deck()
	if GameState.current_mode == "ONLINE_HOST" or GameState.current_mode == "ONLINE_JOIN":
		get_tree().change_scene_to_file("res://Scenes/MultiplayerMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/ModeHub.tscn")
