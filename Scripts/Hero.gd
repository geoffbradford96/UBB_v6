extends CharacterBody3D

const SPEED = 8.0

@export var attack_range: float = 3.0
@export var damage: float = 15.0
@export var attack_rate: float = 1.0
@export var is_player_controlled: bool = false

var attack_timer: float = 0.0
var current_target: Node3D = null

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	if is_player_controlled:
		# Movement (Player Controlled)
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		# Movement (AI Controlled)
		if current_target != null:
			var dist = global_position.distance_to(current_target.global_position)
			var effective_range = attack_range
			if "Base" in current_target.name:
				effective_range += 5.5
			elif "Tower" in current_target.name or "CommandBay" in current_target.name:
				effective_range += 2.5
			if dist > effective_range:
				var nav_agent = get_node_or_null("NavigationAgent3D")
				if nav_agent:
					nav_agent.target_position = current_target.global_position
					var next_path_pos = nav_agent.get_next_path_position()
					var new_velocity = global_position.direction_to(next_path_pos) * SPEED
					new_velocity.y = velocity.y
					velocity = new_velocity
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			# Apply friction if no target!
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
				
	move_and_slide()
	
	# Auto-Attack (AI Controlled)
	if current_target == null or not is_instance_valid(current_target):
		find_new_target()
		
	if current_target != null:
		var dist = global_position.distance_to(current_target.global_position)
		var effective_range = attack_range
		if "Base" in current_target.name:
			effective_range += 5.5
		elif "Tower" in current_target.name or "CommandBay" in current_target.name:
			effective_range += 2.5
			
		if dist <= effective_range:
			attack_timer += delta
			if attack_timer >= attack_rate:
				attack_timer = 0.0
				var target_health = current_target.get_node_or_null("HealthComponent")
				if target_health:
					print("Commander strikes ", current_target.name, " for ", damage, " damage!")
					target_health.take_damage(damage)
		else:
			# Target walked out of range
			current_target = null

func find_new_target():
	var enemy_group = "Team2" if self.is_in_group("Team1") else "Team1"
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	current_target = null
	var closest = 99999.0
	for e in enemies:
		if is_instance_valid(e):
			var d = global_position.distance_to(e.global_position)
			if d < closest:
				closest = d
				current_target = e
