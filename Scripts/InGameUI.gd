extends Control

@onready var req_bar = $BottomPanel/RequisitionBar
@onready var req_label = $BottomPanel/RequisitionBar/Label

@onready var hand_container = $BottomPanel/HandContainer

var deck: Array = []
var discard: Array = []

func _ready():
	if GameState.player_deck.size() > 0:
		deck = GameState.player_deck.duplicate()
	else:
		deck = ["CommanderCard", "CheapGruntCard", "SupportingFireCard", "MedicCard", "CallArtilleryCard", "SniperCard"]
		
	deck.shuffle()
	# Connect signals for all 3 hand slots
	for card_ui in hand_container.get_children():
		card_ui.connect("card_clicked", Callable(self, "_on_card_clicked"))
		draw_card(card_ui)
		
	var exit_btn = get_node_or_null("ExitButton")
	if exit_btn:
		exit_btn.connect("pressed", Callable(self, "_on_exit_button_pressed"))

func draw_card(card_ui):
	if deck.is_empty() and discard.is_empty():
		return
	if deck.is_empty():
		deck = discard.duplicate()
		discard.clear()
		deck.shuffle()
		
	var card_name = deck.pop_front()
	var data = load("res://Data/Cards/" + card_name + ".tres")
	if data:
		card_ui.set_card_data(data)

func _on_card_clicked(card_ui):
	# Tell the Arena Manager which card we want to play!
	get_tree().current_scene.select_card(card_ui)

func _on_exit_button_pressed():
	if GameState.current_mode == "ONLINE_HOST" or GameState.current_mode == "ONLINE_JOIN":
		get_tree().change_scene_to_file("res://Scenes/MultiplayerMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/ModeHub.tscn")

# The ArenaManager will call this function every frame to update the UI visually
func update_requisition(current: float, max_req: float):
	req_bar.max_value = max_req
	req_bar.value = current
	req_label.text = "Requisition: " + str(floor(current)) + " / " + str(max_req)
