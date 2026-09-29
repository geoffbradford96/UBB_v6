extends CharacterBody3D

@export var speed: float = 3.5
@export var attack_range: float = 18.0 
@export var damage: float = 15.0
@export var attack_rate: float = 1.2

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
		if dist > attack_range:
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
		proj.global_position = global_position + Vector3(0, 1.0, 0)
		proj.target = current_target
		proj.set("damage", damage)
		
		# Make it look like a glowing yellow bullet
		var mesh = proj.get_node_or_null("MeshInstance3D")
		if mesh and mesh.mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1, 0.8, 0)
			mat.emission_enabled = true
			mat.emission = Color(1, 0.8, 0)
			mat.emission_energy_multiplier = 1.5
			mesh.set_surface_override_material(0, mat)

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
