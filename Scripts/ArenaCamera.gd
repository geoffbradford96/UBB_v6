extends Camera3D

var target_position: Vector3 = Vector3.ZERO
var is_snapped: bool = false
var hero: Node3D = null

func _ready():
	pass

func _process(delta):
	# Dynamically find the Commander if we don't have one yet!
	if hero == null or not is_instance_valid(hero):
		var potential_heroes = get_tree().get_nodes_in_group("Team1")
		for p in potential_heroes:
			if "Commander" in p.name:
				hero = p
				break
				
	var camera_offset = Vector3(0, 15, 12) # The angle/height of the camera
	
	if is_snapped:
		# Smoothly fly to the clicked minimap location
		global_position = global_position.lerp(target_position + camera_offset, 5.0 * delta)
	elif hero != null and is_instance_valid(hero):
		# Smoothly follow the Hero
		global_position = global_position.lerp(hero.global_position + camera_offset, 5.0 * delta)

# Called by the UI when the minimap is clicked
func snap_to(pos: Vector3):
	is_snapped = true
	target_position = pos

# Call this if the player hits a "re-center" button or presses spacebar
func return_to_hero():
	is_snapped = false

func _unhandled_input(event):
	# If the user presses Spacebar (ui_accept), snap the camera back to the hero!
	if event.is_action_pressed("ui_accept"):
		return_to_hero()
