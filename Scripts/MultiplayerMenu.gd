extends Control

func _ready():
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 1)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_CENTER)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "War Games - Multiplayer Hub"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)
	
	var host_btn = Button.new()
	host_btn.text = "Host Private Match (Local Server)"
	host_btn.custom_minimum_size = Vector2(300, 50)
	host_btn.connect("pressed", Callable(self, "_on_host_pressed"))
	vbox.add_child(host_btn)
	
	var join_hbox = HBoxContainer.new()
	vbox.add_child(join_hbox)
	
	var ip_input = LineEdit.new()
	ip_input.placeholder_text = "Enter Host IP (e.g. 127.0.0.1)"
	ip_input.custom_minimum_size = Vector2(220, 50)
	join_hbox.add_child(ip_input)
	
	var join_btn = Button.new()
	join_btn.text = "Join Match"
	join_btn.custom_minimum_size = Vector2(100, 50)
	join_btn.connect("pressed", Callable(self, "_on_join_pressed"))
	join_hbox.add_child(join_btn)
	
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer2)
	
	var deck_btn = Button.new()
	deck_btn.text = "Prepare Online Deck"
	deck_btn.custom_minimum_size = Vector2(300, 50)
	deck_btn.connect("pressed", Callable(self, "_on_deck_pressed"))
	vbox.add_child(deck_btn)
	
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer3)
	
	var back_btn = Button.new()
	back_btn.text = "Back to Main Menu"
	back_btn.custom_minimum_size = Vector2(300, 50)
	back_btn.connect("pressed", Callable(self, "_on_back_pressed"))
	vbox.add_child(back_btn)

func _on_host_pressed():
	print("Hosting local server... (Networking to be implemented)")
	GameState.current_mode = "ONLINE_HOST"
	GameState.load_deck()
	get_tree().change_scene_to_file("res://Scenes/Arena.tscn")

func _on_join_pressed():
	print("Joining server... (Networking to be implemented)")
	GameState.current_mode = "ONLINE_JOIN"
	GameState.load_deck()
	get_tree().change_scene_to_file("res://Scenes/Arena.tscn")
	
func _on_deck_pressed():
	GameState.current_mode = "ONLINE_HOST"
	GameState.load_deck() # Explicitly reload the array from the online save file!
	get_tree().change_scene_to_file("res://Scenes/ArmyGathering.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
