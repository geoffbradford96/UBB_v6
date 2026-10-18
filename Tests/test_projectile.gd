extends SceneTree

var ProjectileScript = load("res://Scripts/Projectile.gd")

func _init():
	print("Running Tests/test_projectile.gd...")

	# Test 1: Hit target with null body
	test_hit_target_null_body()

	# Test 2: Hit target with invalid body (freed)
	test_hit_target_invalid_body()

	print("All Tests Passed.")
	quit(0)

func test_hit_target_null_body():
	if ProjectileScript == null:
		print("Failed to load Projectile.gd")
		quit(1)
		return

	var projectile = ProjectileScript.new()

	print("Testing _hit_target with null body...")
	# This should not crash or throw an error in GDScript
	# because of `if is_instance_valid(body):`
	projectile._hit_target(null)

	# We simulate manual clean up because Area3D isn't fully in a SceneTree
	projectile.free()

func test_hit_target_invalid_body():
	if ProjectileScript == null:
		print("Failed to load Projectile.gd")
		quit(1)
		return

	var projectile = ProjectileScript.new()

	# Create a dummy node and free it
	var dummy_node = Node3D.new()
	dummy_node.free()

	print("Testing _hit_target with freed body...")
	# This should not crash
	projectile._hit_target(dummy_node)

	# Clean up
	projectile.free()
