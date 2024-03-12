import random
import numpy as np

WSS = 77309411328
# CHUNK_SIZE = 4096
CHUNK_SIZE = 2*1024*1024
FILENAME = 'dist.txt'

dist='zipf'
num_samples = 10000000
num_threads = 1
step_size = 0 # L3 size is roughly 12 2MB pages
step_factor = 3.0
a = 1.0
geom_p = 0.8

buf_size = ((WSS//CHUNK_SIZE)//(num_threads))*CHUNK_SIZE
slots = buf_size//CHUNK_SIZE
step_size_thread = step_size//num_threads

x = np.arange(1, slots+1)

if dist == 'zipf':
    weights = np.arange(1, slots+1 - step_size_thread) ** (-a)
    weights = np.concatenate((np.full(step_size_thread, float(step_factor)), weights))
    weights /= weights.sum()
elif dist == 'geom':
    # Implement geometric distribution
    weights = ((1-geom_p)**(np.arange(1, slots+1 - step_size_thread)-1))*geom_p
    weights = np.concatenate((np.full(step_size_thread, step_factor*geom_p), weights))
    weights /= weights.sum()
else:
    raise Exception("Unknown distribution")

print(weights[0])
cum = 0
for i in range(3275):
    cum += weights[i]
print(cum)

samples = np.random.choice(x, num_samples, p=weights)

# Invert the samples
samples = [slots - s + 1 for s in samples]

with open(FILENAME, 'w') as f:
    for el in samples:
        f.write(str(el-1) + '\n')

