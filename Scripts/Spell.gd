extends Area3D

@export var damage: float = 50.0
@export var radius: float = 10.0

func _ready():
	# Visual Polish: Explosive expanding sphere!
	var mesh = get_node_or_null("MeshInstance3D")
	if mesh and mesh.mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.3, 0.0, 0.8)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.3, 0.0)
		mat.emission_energy_multiplier = 4.0
		mesh.set_surface_override_material(0, mat)
		
		# Animate the explosion expansion
		var tween = create_tween()
		mesh.scale = Vector3(0.1, 0.1, 0.1)
		tween.tween_property(mesh, "scale", Vector3(1, 1, 1), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		
	# Wait 0.5s for explosion animation to finish expanding
	await get_tree().create_timer(0.5).timeout
	
	# Determine enemy team (Spells default to hurting Team2 unless cast by Team2)
	var enemy_group = "Team2" if self.is_in_group("Team1") else "Team1"
	
	# Find everything in the enemy team in a radius
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	for e in enemies:
		if is_instance_valid(e):
			var effective_radius = radius
			if "Base" in e.name:
				effective_radius += 5.5
			elif "Tower" in e.name or "CommandBay" in e.name:
				effective_radius += 2.5
				
			if global_position.distance_to(e.global_position) <= effective_radius:
				var health = e.get_node_or_null("HealthComponent")
				if health:
					print("Spell hit ", e.name, " for ", damage)
					health.take_damage(damage)
					
	queue_free()
