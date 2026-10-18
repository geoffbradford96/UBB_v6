extends Node

var tests_passed = 0
var tests_failed = 0

func assert_eq(actual, expected, message):
	if actual == expected:
		tests_passed += 1
		print("PASS: ", message)
	else:
		tests_failed += 1
		print("FAIL: ", message, " - Expected ", expected, ", got ", actual)

func assert_true(condition, message):
	if condition:
		tests_passed += 1
		print("PASS: ", message)
	else:
		tests_failed += 1
		print("FAIL: ", message)

func test_projectile_hit():
	print("Running test_projectile_hit...")

	# Mock a health component
	var health = Node.new()
	health.name = "HealthComponent"
	# Instead of loading HealthComponent which has complex logic, mock take_damage
	var scr = GDScript.new()
	scr.source_code = "extends Node\nvar last_damage = 0\nvar poison_ticks = 0\nvar poison_dps = 0\nfunc take_damage(amount):\n\tlast_damage = amount\nfunc apply_poison(ticks, dps):\n\tpoison_ticks = ticks\n\tpoison_dps = dps"
	scr.reload()
	health.set_script(scr)

	var target = Node3D.new()
	target.name = "Target"
	target.add_child(health)

	var projectile_scene = load("res://Scenes/Projectile.tscn")
	var proj = projectile_scene.instantiate()
	proj.damage = 25.0
	proj.is_poisonous = true
	proj.target = target

	# Add to tree
	add_child(target)
	add_child(proj)

	# Manually call _hit_target
	proj._hit_target(target)

	assert_eq(health.last_damage, 25.0, "Projectile should apply correct damage")
	assert_eq(health.poison_ticks, 4, "Poison projectile should apply poison ticks")
	assert_eq(health.poison_dps, 12.5, "Poison projectile should apply poison dps")

	# Cleanup
	proj.queue_free()
	target.queue_free()

func test_physics_process():
	print("Running test_physics_process...")

	var projectile_scene = load("res://Scenes/Projectile.tscn")
	var proj = projectile_scene.instantiate()

	var target = Node3D.new()
	target.name = "Target"

	add_child(target)
	add_child(proj)

	# Initial setup
	proj.target = target
	proj.speed = 10.0
	proj.lifetime = 1.0
	proj.global_position = Vector3(0, 0, 0)
	target.global_position = Vector3(10, 0, 0)

	# Move 1 second
	proj._physics_process(0.1)

	assert_true(proj.lifetime < 1.0, "Lifetime should decrease")
	assert_true(proj.global_position.x > 0, "Projectile should move towards target")
	assert_eq(proj.is_queued_for_deletion(), false, "Projectile should not be deleted yet")

	# Move close to target
	proj.global_position = Vector3(9.5, 0, 0)
	proj._physics_process(0.1)

	# Projectile will free itself after hitting
	assert_eq(proj.is_queued_for_deletion(), true, "Projectile should hit and free itself")

	# Test death via lifetime
	var proj2 = projectile_scene.instantiate()
	add_child(proj2)
	proj2.target = target
	proj2.lifetime = 0.05
	proj2._physics_process(0.1)
	assert_eq(proj2.is_queued_for_deletion(), true, "Projectile should delete when lifetime ends")

	# Cleanup
	proj.queue_free()
	proj2.queue_free()
	target.queue_free()

func run_tests():
	print("--- Running Projectile Tests ---")
	test_projectile_hit()
	test_physics_process()
	print("--- Tests Complete: ", tests_passed, " passed, ", tests_failed, " failed ---")
