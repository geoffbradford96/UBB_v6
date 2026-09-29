extends Node
class_name BotAI

@export var max_requisition: float = 10.0
var current_requisition: float = 0.0
var requisition_rate: float = 0.5 # Same base rate as player

var deck: Array = []
var hand: Array = []
var discard: Array = []

var think_timer: float = 0.0
var think_interval: float = 2.0 # Make a decision every 2 seconds
var active_commander: Node3D = null

@export var my_team: String = "Team2"
@export var enemy_team: String = "Team1"

func _ready():
	deck = generate_random_deck()
	pass # Replaced with random deck generator
		
	deck.shuffle()
	draw_to_hand()
	draw_to_hand()
	draw_to_hand()

func _process(delta):
	# Gain Requisition
	var bot_towers = 0
	for z in get_tree().get_nodes_in_group(my_team):
		if "Tower" in z.name:
			bot_towers += 1
	var dynamic_rate = requisition_rate + ((2 - bot_towers) * 0.5)
	if current_requisition < max_requisition:
		current_requisition += dynamic_rate * delta
		if current_requisition > max_requisition:
			current_requisition = max_requisition
			
	# AI Thinking Loop
	think_timer += delta
	if think_timer >= think_interval:
		think_timer = 0.0
		evaluate_moves()

func draw_to_hand():
	if hand.size() >= 3:
		return
	if deck.is_empty():
		deck = discard.duplicate()
		discard.clear()
		deck.shuffle()
	
	if not deck.is_empty():
		var card_name = deck.pop_front()
		var data = load("res://Data/Cards/" + card_name + ".tres")
		if data:
			hand.append(data)

func evaluate_moves():
	# 1. Figure out which cards we can afford
	var affordable = []
	for c in hand:
		if current_requisition >= c.cost:
			affordable.append(c)
			
	if affordable.is_empty():
		return # Save up!
		
	# 2. Pick a card to play
	var card_to_play = affordable.pick_random()
	
	# 3. Prevent multiple enemy commanders
	if card_to_play.card_type == "Commander":
		if is_instance_valid(active_commander):
			return # We already have a Commander, skip this turn and wait to afford something else!

	# 4. Figure out WHERE to play it
	var spawn_pos = calculate_optimal_spawn(card_to_play)
	if spawn_pos != null:
		play_card(card_to_play, spawn_pos)

func calculate_optimal_spawn(card: CardData):
	if card.is_spell:
		var player_units = get_tree().get_nodes_in_group(enemy_team)
		if player_units.is_empty():
			return null
			
		var valid_targets = []
		for u in player_units:
			if not "Base" in u.name and not "Tower" in u.name:
				valid_targets.append(u)
				
		if valid_targets.size() > 0:
			var t = valid_targets.pick_random()
			return t.global_position
			return null
			
		var team2_structures = []
		for z in get_tree().get_nodes_in_group(my_team):
			if "Base" in z.name or "Tower" in z.name or "CommandBay" in z.name:
				team2_structures.append(z)
				
		if team2_structures.is_empty():
			return null
			
		var spawn_anchor = team2_structures[0]
		for s in team2_structures:
			if my_team == "Team2":
				if s.global_position.z > spawn_anchor.global_position.z:
					spawn_anchor = s
				if s.global_position.z < spawn_anchor.global_position.z:
					spawn_anchor = s
		
		var push_dir = 1.0 if my_team == "Team2" else -1.0
		
		if card.card_name == "Sniper" or card.card_name == "VoidSpitter":
			var side = 30.0 if randf() > 0.5 else -30.0
			return Vector3(side, 2.0, spawn_anchor.global_position.z + (randf_range(2, 5) * push_dir))
		elif card.card_name == "Assassin" or card.card_name == "VoidStalker":
			var side = 18.0 if randf() > 0.5 else -18.0
			return Vector3(side, 2.0, spawn_anchor.global_position.z + (randf_range(5, 10) * push_dir))
			return spawn_anchor.global_position + Vector3(randf_range(-5, 5), 2.0, randf_range(5, 15) * push_dir)

func play_card(card: CardData, target_position: Vector3):
	current_requisition -= card.cost
	
	hand.erase(card)
	discard.append(card.card_name.replace(" ", "") + "Card")
	
	print(my_team, " AI played ", card.card_name, " at ", target_position)
	
	for i in range(card.spawn_count):
		var unit = card.unit_scene.instantiate()
		get_tree().current_scene.add_child(unit)
		
		if card.is_spell:
			unit.global_position = target_position
			unit.global_position = target_position + Vector3(randf_range(-2.0, 2.0), 2.0, randf_range(-2.0, 2.0))
			
		unit.add_to_group(my_team)
		if unit.is_in_group(enemy_team):
			unit.remove_from_group(enemy_team)
			
		if card.card_type == "Commander":
			active_commander = unit
			
	# Draw replacement
	draw_to_hand()

func generate_random_deck() -> Array:
	var dir = DirAccess.open("res://Data/Cards/")
	var all_commanders = []
	var all_units = []
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".tres.remap")):
				var clean_name = file_name.trim_suffix(".remap")
				var res = load("res://Data/Cards/" + clean_name)
				if res != null:
					var raw_name = clean_name.replace(".tres", "")
					if "card_type" in res and res.card_type == "Commander":
						all_commanders.append(raw_name)
					else:
						all_units.append(raw_name)
			file_name = dir.get_next()
			
	var new_deck = []
	if all_commanders.size() > 0:
		new_deck.append(all_commanders.pick_random())
	
	all_units.shuffle()
	for i in range(min(5, all_units.size())):
		new_deck.append(all_units[i])
		
	return new_deck
