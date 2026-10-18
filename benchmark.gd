extends SceneTree

func _init():
    print("Starting benchmark...")

    var root = Node.new()
    self.root.add_child(root)

    # Create many targetable nodes
    for i in range(10000):
        var dummy = Node3D.new()
        dummy.name = "Unit_" + str(i)
        dummy.add_to_group("Targetable")
        if i % 100 == 0:
            dummy.name = "Base_" + str(i)
            dummy.add_to_group("Base")
            dummy.add_to_group("SideA")
        root.add_child(dummy)

    print("Nodes created.")

    var start_time = Time.get_ticks_usec()

    var iterations = 100
    for i in range(iterations):
        var teams_alive = []
        for b in get_nodes_in_group("Targetable"):
            if "Base" in b.name and is_instance_valid(b):
                for g in b.get_groups():
                    if g.begins_with("Side") and not teams_alive.has(g):
                        teams_alive.append(g)

    var end_time = Time.get_ticks_usec()
    print("Baseline: ", (end_time - start_time) / 1000.0, " ms for ", iterations, " iterations")


    start_time = Time.get_ticks_usec()

    for i in range(iterations):
        var teams_alive = []
        for b in get_nodes_in_group("Base"):
            if is_instance_valid(b):
                for g in b.get_groups():
                    if g.begins_with("Side") and not teams_alive.has(g):
                        teams_alive.append(g)

    end_time = Time.get_ticks_usec()
    print("Optimized: ", (end_time - start_time) / 1000.0, " ms for ", iterations, " iterations")

    quit()
