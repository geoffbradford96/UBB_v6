extends CharacterBody3D

@export var speed: float = 4.5
@export var attack_range: float = 12.0 # laser variant, more range, less damage
@export var damage: float = 8.0
@export var attack_rate: float = 0.8

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var current_target: Node3D = null
var attack_timer: float = 0.0

var projectile_scene = preload("res://Scenes/Projectile.tscn")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
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
			nav_agent.target_position = current_target.global_position
			var next_path_pos = nav_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(next_path_pos) * speed
			new_velocity.y = velocity.y
			velocity = new_velocity
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
			attack_timer += delta
			if attack_timer >= attack_rate:
				attack_timer = 0.0
				shoot()

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func shoot():
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position + Vector3(0, 1.5, 0)
		proj.target = current_target
		
		# Visual Polish: Make the projectile look like a red laser!
		var mesh = proj.get_node_or_null("MeshInstance3D")
		if mesh and mesh.mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1, 0, 0)
			mat.emission_enabled = true
			mat.emission = Color(1, 0, 0)
			mat.emission_energy_multiplier = 3.0
			mesh.set_surface_override_material(0, mat)
			
		# Wait wait! We need to tell the projectile how much damage to deal!
		# The projectile currently assumes 20 damage. Let's set it if we can.
		proj.set("damage", damage)

func find_new_target():
	current_target = null
	var enemy_group = "Team2" if self.is_in_group("Team1") else "Team1"
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	var closest_dist = 99999.0
	var hero_target = null
	
	for e in enemies:
		if is_instance_valid(e):
			# Tunnel vision on the Commander!
			if "is_player_controlled" in e:
				hero_target = e
				break 
				
			# Fallback just in case the Hero is dead
			var d = global_position.distance_to(e.global_position)
			if d < closest_dist:
				closest_dist = d
				current_target = e
				
	if hero_target != null:
		current_target = hero_target
