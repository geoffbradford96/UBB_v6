import time
import random
import math

class Target:
    def __init__(self, x, z):
        self.x = x
        self.z = z

def naive_approach(targets):
    best_t = targets[0]
    max_c = 0
    for u in targets:
        c = 0
        for other in targets:
            if math.dist((u.x, u.z), (other.x, other.z)) < 10.0:
                c += 1
        if c > max_c:
            max_c = c
            best_t = u
    return best_t, max_c

def spatial_hash_approach(targets):
    best_t = targets[0]
    max_c = 0
    cell_size = 10.0
    grid = {}

    for u in targets:
        cx = int(math.floor(u.x / cell_size))
        cz = int(math.floor(u.z / cell_size))
        key = (cx, cz)
        if key not in grid:
            grid[key] = []
        grid[key].append(u)

    for u in targets:
        cx = int(math.floor(u.x / cell_size))
        cz = int(math.floor(u.z / cell_size))
        c = 0
        for dx in [-1, 0, 1]:
            for dz in [-1, 0, 1]:
                key = (cx + dx, cz + dz)
                if key in grid:
                    for other in grid[key]:
                        if math.dist((u.x, u.z), (other.x, other.z)) < 10.0:
                            c += 1
        if c > max_c:
            max_c = c
            best_t = u
    return best_t, max_c

targets = [Target(random.uniform(-100, 100), random.uniform(-100, 100)) for _ in range(1000)]

start = time.time()
naive_best, naive_max = naive_approach(targets)
naive_time = time.time() - start

start = time.time()
hash_best, hash_max = spatial_hash_approach(targets)
hash_time = time.time() - start

print(f"Naive time: {naive_time:.4f}s")
print(f"Hash time: {hash_time:.4f}s")
print(f"Speedup: {naive_time / hash_time:.2f}x")
print(f"Max counts - Naive: {naive_max}, Hash: {hash_max}")
assert naive_max == hash_max
