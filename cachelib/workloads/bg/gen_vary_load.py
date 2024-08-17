# Generate vary load file for varying banckground traffic over time
filename = './vary-10-5-15.txt'
with open(filename, 'w') as f:
    for i in range(200):
        f.write('10\n')
    for i in range(50):
        f.write('5\n')
    for i in range(50):
        f.write('15\n')

filename = './vary-pulse5.txt'
with open(filename, 'w') as f:
    for i in range(200):
        f.write('0\n')
    for i in range(30):
        f.write('5\n')
    for i in range(30):
        f.write('0\n')
    for i in range(30):
        f.write('10\n')
    for i in range(30):
        f.write('0\n')
    for i in range(30):
        f.write('15\n')
    for i in range(30):
        f.write('0\n')

filename = './vary-pulse5-400.txt'
with open(filename, 'w') as f:
    for i in range(400):
        f.write('0\n')
    for i in range(30):
        f.write('5\n')
    for i in range(30):
        f.write('0\n')
    for i in range(30):
        f.write('10\n')
    for i in range(30):
        f.write('0\n')
    for i in range(30):
        f.write('15\n')
    for i in range(30):
        f.write('0\n')

filename = './vary-pulse-long.txt'
with open(filename, 'w') as f:
    for i in range(300):
        f.write('0\n')
    for i in range(100):
        f.write('5\n')
    for i in range(100):
        f.write('0\n')
    for i in range(100):
        f.write('10\n')
    for i in range(100):
        f.write('0\n')
    for i in range(100):
        f.write('15\n')
    for i in range(100):
        f.write('0\n')

filename = './vary-pulse10s.txt'
with open(filename, 'w') as f:
    for i in range(200):
        f.write('0\n')
    for i in range(10):
        f.write('5\n')
    for i in range(10):
        f.write('0\n')
    for i in range(10):
        f.write('10\n')
    for i in range(10):
        f.write('0\n')
    for i in range(10):
        f.write('15\n')
    for i in range(10):
        f.write('0\n')