extends CharacterBody3D

@export var speed: float = 5.0
@export var attack_range: float = 2.0
@export var damage: float = 10.0
@export var attack_rate: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health = $HealthComponent

var current_target: Node3D = null
var attack_timer: float = 0.0

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	# Basic AI: Find nearest enemy, move to it, attack.
	if current_target == null or not is_instance_valid(current_target):
		find_new_target()
		
	if current_target != null:
		var dist = global_position.distance_to(current_target.global_position)
		var effective_range = attack_range
		if "Base" in current_target.name:
			effective_range += 5.5
		elif "Tower" in current_target.name or "CommandBay" in current_target.name:
			effective_range += 2.5
			
		if dist > effective_range:
			# Move towards target
			nav_agent.target_position = current_target.global_position
			var next_path_pos = nav_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(next_path_pos) * speed
			new_velocity.y = velocity.y # Preserve gravity
			velocity = new_velocity
		else:
			# Stop and Attack
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
			attack_timer += delta
			if attack_timer >= attack_rate:
				attack_timer = 0.0
				var target_health = current_target.get_node_or_null("HealthComponent")
				if target_health:
					target_health.take_damage(damage)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func find_new_target():
	current_target = null
	var enemy_group = "Team2" if self.is_in_group("Team1") else "Team1"
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	var closest_dist = 99999.0
	for e in enemies:
		if is_instance_valid(e):
			var d = global_position.distance_to(e.global_position)
			if d < closest_dist:
				closest_dist = d
				current_target = e
