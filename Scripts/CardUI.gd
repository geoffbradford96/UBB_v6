extends Control

signal card_clicked(card_ui_node)

@export var card_data: Resource # Will hold our CardData.tres

@onready var cost_label = $CostLabel
@onready var name_label = $NameLabel
@onready var background = $Background
@onready var hp_label = $HPLabel
@onready var type_label = $TypeLabel

var is_selected: bool = false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("card_clicked", self)

func set_selected(selected: bool):
	is_selected = selected
	if is_selected:
		position.y = -20 # Pop the card up slightly to show it's ready to be placed!
		background.color = Color(0.2, 0.5, 0.2) # Green tint
	else:
		position.y = 0
		# Reset color based on type
		if card_data and "is_spell" in card_data and card_data.is_spell:
			background.color = Color(0.4, 0.1, 0.1)
		elif card_data and "card_type" in card_data and card_data.card_type == "Commander":
			background.color = Color(0.5, 0.4, 0.1)
		elif card_data and "card_type" in card_data and card_data.card_type == "Vehicle":
			background.color = Color(0.2, 0.3, 0.4)
		else:
			background.color = Color(0.15, 0.15, 0.15)

func _ready():
	# Crucial: Ensure children don't absorb mouse clicks so the CardUI gets the click!
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
	if card_data:
		set_card_data(card_data)

func set_card_data(data: Resource):
	card_data = data
	cost_label.text = str(data.cost)
	name_label.text = data.card_name
	
	var desc_label = get_node_or_null("DescLabel")
	if desc_label and "description" in data:
		desc_label.text = data.description
		
	if "max_hp" in data:
		hp_label.text = "HP: " + str(data.max_hp)
		
	if "is_melee" in data:
		type_label.text = "Melee" if data.is_melee else "Ranged"
		
	if data.is_spell:
		background.color = Color(0.4, 0.1, 0.1) # Spell cards have a dark red tint
		hp_label.text = ""
		type_label.text = "Spell"
	elif "card_type" in data and data.card_type == "Commander":
		background.color = Color(0.5, 0.4, 0.1) # Commander cards have a gold tint
		type_label.text = "Com"
	elif "card_type" in data and data.card_type == "Vehicle":
		background.color = Color(0.2, 0.3, 0.4) # Vehicles have a steel blue tint
		type_label.text = "Veh"
	else:
		background.color = Color(0.15, 0.15, 0.15) # Standard unit cards
