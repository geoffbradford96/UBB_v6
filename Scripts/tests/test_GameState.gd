extends SceneTree

var gs
var node1
var node2
var node3
var node4
var node5
var initial_tests_passed = true

func _init():
    pass

func _process(delta):
    if gs != null:
        return # already initialized

    print("Running tests for GameState...")
    gs = load("res://Scripts/GameState.gd").new()

    node1 = Node3D.new()
    node2 = Node3D.new()
    node3 = Node3D.new()
    node4 = Node3D.new()
    node5 = Node3D.new()

    gs.add_child(node1)
    gs.add_child(node2)
    gs.add_child(node3)
    gs.add_child(node4)
    gs.add_child(node5)

    root.add_child(gs)

    # Set AFTER adding to root so _ready() doesn't overwrite it
    gs.corpse_max_count = 2
    gs.corpse_duration = -1.0 # prevent timeouts during testing

    gs.register_corpse(node1)
    gs.register_corpse(node2)
    gs.register_corpse(node3)
    gs.register_corpse(node4)
    gs.register_corpse(node5)

    if gs.active_corpses.size() == 2:
        print("  [PASS] Only two corpses kept active out of 5")
    else:
        print("  [FAIL] active_corpses size was ", gs.active_corpses.size(), " expected 2")
        initial_tests_passed = false

    if gs.active_corpses.has(node1) == false and gs.active_corpses.has(node2) == false and gs.active_corpses.has(node3) == false:
        print("  [PASS] Oldest corpses were removed")
    else:
        print("  [FAIL] Old corpses were still in active_corpses")
        initial_tests_passed = false

    if gs.active_corpses.has(node4) == true and gs.active_corpses.has(node5) == true:
        print("  [PASS] Most recent corpses were kept")
    else:
        print("  [FAIL] Most recent corpses were not kept")
        initial_tests_passed = false

    # Wait for frame processing so queue_free has time, and tween might register correctly
    var timer = create_timer(1.5)
    timer.timeout.connect(self._finish_test)

func _finish_test():
    var all_passed = initial_tests_passed

    if not is_instance_valid(node1) or node1.is_queued_for_deletion():
        print("  [PASS] node1 is correctly freed or queued for deletion")
    else:
        print("  [FAIL] node1 was not queued for deletion")
        all_passed = false

    if not is_instance_valid(node2) or node2.is_queued_for_deletion():
        print("  [PASS] node2 is correctly freed or queued for deletion")
    else:
        print("  [FAIL] node2 was not queued for deletion")
        all_passed = false

    if not is_instance_valid(node3) or node3.is_queued_for_deletion():
        print("  [PASS] node3 is correctly freed or queued for deletion")
    else:
        print("  [FAIL] node3 was not queued for deletion")
        all_passed = false

    if is_instance_valid(node4) and not node4.is_queued_for_deletion():
        print("  [PASS] node4 is still valid")
    else:
        print("  [FAIL] node4 was wrongly queued for deletion")
        all_passed = false

    if is_instance_valid(node5) and not node5.is_queued_for_deletion():
        print("  [PASS] node5 is still valid")
    else:
        print("  [FAIL] node5 was wrongly queued for deletion")
        all_passed = false

    if all_passed:
        print("All GameState tests PASSED")
        quit(0)
    else:
        print("Some GameState tests FAILED")
        quit(1)
