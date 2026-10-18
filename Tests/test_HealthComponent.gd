extends SceneTree

var failed = false

func assert_eq(a, b, msg=""):
	if a != b:
		print("Assertion failed: ", a, " != ", b, " - ", msg)
		failed = true
	else:
		print("Assertion passed: ", msg)

func _init():
	print("Running test_HealthComponent.gd...")
	test_apply_poison()
	test_apply_poison_golem()
	test_apply_poison_no_parent()
	test_apply_poison_no_attribute()

	if not failed:
		print("All HealthComponent tests passed!")
		quit(0)
	else:
		print("Some HealthComponent tests failed.")
		quit(1)

func test_apply_poison():
	print("Running test_apply_poison...")
	var parent = Node.new()
	var script = GDScript.new()
	script.source_code = "extends Node\nvar unit_attribute = 'Organic'"
	script.reload()
	parent.set_script(script)

	var HealthComponentScript = load("res://Scripts/HealthComponent.gd")
	var hc = HealthComponentScript.new()
	parent.add_child(hc)

	hc.apply_poison(5, 10.0)

	assert_eq(hc.poison_ticks, 5, "Poison ticks should be 5")
	assert_eq(hc.poison_dps, 10.0, "Poison dps should be 10.0")
	assert_eq(hc.poison_timer, 1.0, "Poison timer should be 1.0")

	hc.free()
	parent.free()

func test_apply_poison_golem():
	print("Running test_apply_poison_golem...")
	var parent = Node.new()
	var script = GDScript.new()
	script.source_code = "extends Node\nvar unit_attribute = 'Golem'"
	script.reload()
	parent.set_script(script)

	var HealthComponentScript = load("res://Scripts/HealthComponent.gd")
	var hc = HealthComponentScript.new()
	parent.add_child(hc)

	hc.apply_poison(5, 10.0)

	assert_eq(hc.poison_ticks, 0, "Poison ticks should be 0 (immune)")
	assert_eq(hc.poison_dps, 0.0, "Poison dps should be 0.0 (immune)")
	assert_eq(hc.poison_timer, 0.0, "Poison timer should be 0.0 (immune)")

	hc.free()
	parent.free()

func test_apply_poison_no_parent():
	print("Running test_apply_poison_no_parent...")
	var HealthComponentScript = load("res://Scripts/HealthComponent.gd")
	var hc = HealthComponentScript.new()

	hc.apply_poison(3, 5.5)

	assert_eq(hc.poison_ticks, 3, "Poison ticks should be 3 when no parent")
	assert_eq(hc.poison_dps, 5.5, "Poison dps should be 5.5 when no parent")
	assert_eq(hc.poison_timer, 1.0, "Poison timer should be 1.0 when no parent")

	hc.free()

func test_apply_poison_no_attribute():
	print("Running test_apply_poison_no_attribute...")
	var parent = Node.new()

	var HealthComponentScript = load("res://Scripts/HealthComponent.gd")
	var hc = HealthComponentScript.new()
	parent.add_child(hc)

	hc.apply_poison(4, 7.0)

	assert_eq(hc.poison_ticks, 4, "Poison ticks should be 4 when no attribute")
	assert_eq(hc.poison_dps, 7.0, "Poison dps should be 7.0 when no attribute")
	assert_eq(hc.poison_timer, 1.0, "Poison timer should be 1.0 when no attribute")

	hc.free()
	parent.free()
