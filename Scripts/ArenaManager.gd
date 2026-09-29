extends Node

# --- UI Connection ---
@onready var ui = $InGameUI

# --- Economy System ---
var max_requisition: float = 10.0
var current_requisition: float = 0.0
var requisition_rate: float = 1.0 # Gains 1 energy per second

# Keep track of active player structures to calculate comeback mechanic
var active_commander: Node3D = null


func _ready():
	if GameState.current_mode == "AI_VS_AI":
		# Hide Player UI
		if ui:
			ui.visible = false
			
		# Spawn Team 1 Bot (Dominion of Sol)
		var bot1 = BotAI.new()
		bot1.name = "AI Rando (Team 1)"
		bot1.my_team = "Team1"
		bot1.enemy_team = "Team2"
		add_child(bot1)
		
		# Spawn Team 2 Bot (Void Swarm)
		var bot2 = BotAI.new()
		bot2.name = "AI Rando (Team 2)"
		bot2.my_team = "Team2"
		bot2.enemy_team = "Team1"
		add_child(bot2)
		
	else:
		# Standard Solo Play vs AI
		var bot = BotAI.new()
		bot.name = "AI Rando"
		bot.my_team = "Team2"
		bot.enemy_team = "Team1"
		add_child(bot)

func _process(delta):
	# Calculate Comeback Mechanic:
	var player_towers = 0
	for z in get_tree().get_nodes_in_group("Team1"):
		if "Tower" in z.name:
			player_towers += 1
	var dynamic_rate = requisition_rate + ((2 - player_towers) * 0.5)
	
	if current_requisition < max_requisition:
		current_requisition += dynamic_rate * delta
		if current_requisition > max_requisition:
			current_requisition = max_requisition
			
	# Update the UI visually on the screen!
	if ui:
		ui.update_requisition(current_requisition, max_requisition)
	
	var player_base = get_node_or_null("PlayerBase")
	var enemy_base = get_node_or_null("EnemyBase")
	if not player_base:
		print("DEFEAT!")
		get_tree().change_scene_to_file("res://Scenes/ModeHub.tscn")
	elif not enemy_base:
		print("VICTORY!")
		get_tree().change_scene_to_file("res://Scenes/ModeHub.tscn")

func tower_lost():
	friendly_towers -= 1
	if friendly_towers < 0:
		friendly_towers = 0
	print("Player Tower destroyed! Requisition Income increased to: ", requisition_rate + ((2 - friendly_towers) * 0.5), " per second!")

var selected_card_ui = null

func select_card(card_ui):
	if selected_card_ui:
		selected_card_ui.set_selected(false)
		
	if selected_card_ui == card_ui:
		selected_card_ui = null
		return
		
	selected_card_ui = card_ui
	selected_card_ui.set_selected(true)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_card_ui and selected_card_ui.card_data:
			var camera = get_viewport().get_camera_3d()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000.0
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result:
				var hit_pos = result.position
				if attempt_to_play_card(selected_card_ui.card_data, hit_pos):
					var played_ui = selected_card_ui
					played_ui.set_selected(false)
					selected_card_ui = null
					
					# Put in discard pile and draw a new one
					ui.discard.append(played_ui.card_data.card_name.replace(" ", "") + "Card")
					ui.draw_card(played_ui)

# --- Card Deployment Logic ---
func attempt_to_play_card(data: Resource, target_position: Vector3) -> bool:
	if current_requisition < data.cost:
		print("Not enough Requisition! Need ", data.cost, " but have ", snapped(current_requisition, 0.1))
		return false
		
	if data.card_type == "Commander":
		if is_instance_valid(active_commander):
			print("Cannot deploy! You already have an active Commander on the field.")
			return false
				
	if not data.is_spell:
		# If it's a unit or commander, verify we are clicking inside a valid deployment zone
		if not is_in_deployment_zone(target_position):
			print("Cannot deploy! You must place units near a Tower or Command Bay.")
			return false
			
	# Success! Deduct energy and spawn it
	current_requisition -= data.cost
	print("Spawned ", data.card_name, " x", data.get("spawn_count", 1), "!")
	
	var count = 1
	if "spawn_count" in data:
		count = data.spawn_count
		
	for i in range(count):
		var unit = data.unit_scene.instantiate()
		add_child(unit)
		
		if data.is_spell:
			# Spells detonate exactly where you clicked
			unit.global_position = target_position
		else:
			# Units drop from the sky with a slight spread so they don't clip into each other
			unit.global_position = target_position + Vector3(randf_range(-2.0, 2.0), 2.0, randf_range(-2.0, 2.0))
			
		# Explicitly assign them to Team1 so if an AI spawner uses this same logic later, 
		# we can just pass "Team2" to make them enemies!
		unit.add_to_group("Team1")
		if unit.is_in_group("Team2"):
			unit.remove_from_group("Team2")
			
		if data.card_type == "Commander":
			active_commander = unit
			if "is_player_controlled" in unit:
				unit.is_player_controlled = true
	
	return true

func is_in_deployment_zone(pos: Vector3) -> bool:
	# Spells bypass this check in attempt_to_play_card.
	# We must be within 25 meters of a friendly Tower, Base, or Command Bay.
	
	var zones = get_tree().get_nodes_in_group("Team1")
	var valid = false
	
	for z in zones:
		if is_instance_valid(z):
			# Is it a structure? (Bases have "Base" in name, Towers have "Tower", CommandBays have "Command")
			if "Base" in z.name or "Tower" in z.name or "CommandBay" in z.name:
				if pos.distance_to(z.global_position) <= 25.0:
					valid = true
					break
					
	return valid
