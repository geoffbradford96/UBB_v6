extends CharacterBody3D

@export var speed: float = 5.0
@export var heal_range: float = 3.0
@export var heal_amount: float = 50.0
@export var heal_rate: float = 2.0 # Heals every 2 seconds

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var current_target: Node3D = null
var action_timer: float = 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	# Find someone to heal!
	if current_target == null or not is_instance_valid(current_target):
		find_new_target()
		
	if current_target != null:
		var dist = global_position.distance_to(current_target.global_position)
		var effective_range = heal_range
		if "Base" in current_target.name:
			effective_range += 5.5
		elif "Tower" in current_target.name or "CommandBay" in current_target.name:
			effective_range += 2.5
			
		if dist > effective_range:
			# Move towards hurt ally
			nav_agent.target_position = current_target.global_position
			var next_path_pos = nav_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(next_path_pos) * speed
			new_velocity.y = velocity.y
			velocity = new_velocity
		else:
			# Stop and Heal
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
			action_timer += delta
			if action_timer >= heal_rate:
				action_timer = 0.0
				var target_health = current_target.get_node_or_null("HealthComponent")
				if target_health:
					# Only pop a heal if they actually need it!
					if target_health.current_health < target_health.max_health:
						print("Medic heals ", current_target.name, " for ", heal_amount)
						target_health.heal(heal_amount)
					
					# If they are fully healed (or already were), re-evaluate targets next frame
					if target_health.current_health >= target_health.max_health:
						current_target = null

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func find_new_target():
	current_target = null
	var friendly_group = "Team1" if self.is_in_group("Team1") else "Team2"
	var allies = get_tree().get_nodes_in_group(friendly_group)
	var closest_dist = 99999.0
	var healthy_fallback = null
	var closest_healthy_dist = 99999.0
	
	for a in allies:
		if is_instance_valid(a) and a != self:
			var health = a.get_node_or_null("HealthComponent")
			if health:
				var d = global_position.distance_to(a.global_position)
				# Priority 1: Target injured allies
				if health.current_health < health.max_health:
					if d < closest_dist:
						closest_dist = d
						current_target = a
				# Priority 2: Keep track of healthy allies to follow just in case
				elif current_target == null and d < closest_healthy_dist:
					closest_healthy_dist = d
					healthy_fallback = a
					
	# If no one is hurt, follow the closest healthy ally so we stay with the army!
	if current_target == null and healthy_fallback != null:
		current_target = healthy_fallback
