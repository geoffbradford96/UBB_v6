extends CharacterBody3D

@export var speed: float = 4.0
@export var repair_range: float = 3.0
@export var repair_amount: float = 40.0
@export var repair_rate: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var current_target: Node3D = null
var action_timer: float = 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	if current_target == null or not is_instance_valid(current_target):
		find_new_target()
		
	if current_target != null:
		var dist = global_position.distance_to(current_target.global_position)
		var effective_range = repair_range
		if "Base" in current_target.name:
			effective_range += 5.5
		elif "Tower" in current_target.name or "CommandBay" in current_target.name:
			effective_range += 2.5
			
		if dist > effective_range:
			nav_agent.target_position = current_target.global_position
			var next_path_pos = nav_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(next_path_pos) * speed
			new_velocity.y = velocity.y
			velocity = new_velocity
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
			action_timer += delta
			if action_timer >= repair_rate:
				action_timer = 0.0
				
				var friendly_group = "Team1" if self.is_in_group("Team1") else "Team2"
				# Are we repairing an ally or attacking an enemy?
				if current_target.is_in_group(friendly_group):
					var target_health = current_target.get_node_or_null("HealthComponent")
					if target_health:
						if target_health.current_health < target_health.max_health:
							target_health.heal(repair_amount)
						
						if target_health.current_health >= target_health.max_health:
							current_target = null
				else:
					# Attack!
					var target_health = current_target.get_node_or_null("HealthComponent")
					if target_health:
						target_health.take_damage(10.0)

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func find_new_target():
	current_target = null
	var friendly_group = "Team1" if self.is_in_group("Team1") else "Team2"
	var friendly_structures = get_tree().get_nodes_in_group(friendly_group)
	var closest_repair_dist = 99999.0
	var repair_target = null
	
	for a in friendly_structures:
		# Only check actual structures!
		if is_instance_valid(a) and ("Tower" in a.name or "Base" in a.name or "CommandBay" in a.name):
			var health = a.get_node_or_null("HealthComponent")
			if health and health.current_health < health.max_health:
				var d = global_position.distance_to(a.global_position)
				if d < closest_repair_dist:
					closest_repair_dist = d
					repair_target = a
					
	if repair_target != null:
		current_target = repair_target
	else:
		# If no repairs are needed, act like a normal grunt and push the lane!
		var enemy_group = "Team2" if self.is_in_group("Team1") else "Team1"
		var enemies = get_tree().get_nodes_in_group(enemy_group)
		var closest_enemy_dist = 99999.0
		for e in enemies:
			if is_instance_valid(e):
				var d = global_position.distance_to(e.global_position)
				if d < closest_enemy_dist:
					closest_enemy_dist = d
					current_target = e
