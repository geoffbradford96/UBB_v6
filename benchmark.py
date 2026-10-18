import time
import random

# Simulating Godot's group nodes
class Node:
    def __init__(self, name, groups):
        self.name = name
        self.groups = groups

    def get_groups(self):
        return self.groups

def is_instance_valid(node):
    return True

# Setup
NUM_TARGETABLE = 10000
NUM_BASES = 100

nodes = []
bases_only = []

for i in range(NUM_TARGETABLE):
    groups = ["Targetable"]
    name = f"Unit_{i}"

    if i % (NUM_TARGETABLE // NUM_BASES) == 0:
        groups.append("Base")
        groups.append("SideA" if i % 2 == 0 else "SideB")
        name = f"Base_{i}"

    node = Node(name, groups)
    nodes.append(node)

    if "Base" in groups:
        bases_only.append(node)

def baseline():
    teams_alive = []
    for b in nodes:
        if "Base" in b.name and is_instance_valid(b):
            for g in b.get_groups():
                if g.startswith("Side") and g not in teams_alive:
                    teams_alive.append(g)
    return teams_alive

def optimized():
    teams_alive = []
    for b in bases_only:
        if is_instance_valid(b):
            for g in b.get_groups():
                if g.startswith("Side") and g not in teams_alive:
                    teams_alive.append(g)
    return teams_alive

# Benchmark
ITERATIONS = 1000

start_time = time.time()
for _ in range(ITERATIONS):
    baseline()
baseline_time = time.time() - start_time

start_time = time.time()
for _ in range(ITERATIONS):
    optimized()
optimized_time = time.time() - start_time

print(f"Baseline (filtering {NUM_TARGETABLE} items): {baseline_time:.4f} seconds for {ITERATIONS} iterations")
print(f"Optimized (iterating {NUM_BASES} bases directly): {optimized_time:.4f} seconds for {ITERATIONS} iterations")
print(f"Improvement: {baseline_time / optimized_time:.2f}x faster")
