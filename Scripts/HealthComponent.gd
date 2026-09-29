extends Node
class_name HealthComponent

signal died
signal health_changed(new_health, max_health)

@export var max_health: float = 100.0
var current_health: float

func _ready():
	current_health = max_health

func take_damage(amount: float):
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	print(get_parent().name, " took ", amount, " damage! Remaining HP: ", current_health)
	
	if current_health <= 0:
		die()

func heal(amount: float):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	print(get_parent().name, " was healed! HP: ", current_health)

func die():
	print(get_parent().name, " was destroyed!")
	emit_signal("died")
	
	# Check for Game Over conditions!
	if "Base" in get_parent().name:
		if get_parent().is_in_group("Team1"):
			print("DEFEAT! Your base was destroyed.")
		else:
			print("VICTORY! You destroyed the enemy base.")
		# Small delay before kicking back to the menu
		await get_tree().create_timer(3.0).timeout
		if GameState.current_mode == "ONLINE_HOST" or GameState.current_mode == "ONLINE_JOIN":
			get_tree().change_scene_to_file("res://Scenes/MultiplayerMenu.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/ModeHub.tscn")
		return
	
	# If this is a unit or tower, destroy it from the game world
	if get_parent().has_method("queue_free"):
		get_parent().queue_free()
