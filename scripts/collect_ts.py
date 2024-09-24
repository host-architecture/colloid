import sys, os, glob
import argparse

STATS_PATH = '/home/midhul/membw-eval'

def load_gups(d, filepath):
    with open(filepath, 'r') as f:
        if 'gups' not in d:
            d['gups'] = []
        for line in f:
            if 'Total' in line or 'memset' in line or 'size' in line:
                continue
            if 'moved' in line or 'hotset' in line:
                continue
            d['gups'].append(float(line.strip()))


def load_colloid(d, filepath):
    with open(filepath, 'r') as f:
        for line in f:
            if 'occ_local' in line:
                cols = line.split(',')
                for col in cols:
                    if col.strip() == '':
                        continue
                    if len(col.split('=')) != 2:
                        continue
                    key = (col.split('=')[0]).strip()
                    if key == 'pairs':
                        continue
                    if not key in d:
                        d[key] = []
                    d[key].append(float(col.split('=')[1]))

# return timeseries (list of numbers)
def query(d, metric):
    if not metric in d:
        raise Exception('Metric ' + metric + ' not available')
    return d[metric]

parser = argparse.ArgumentParser()
parser.add_argument('config', help='Label for experiment')
parser.add_argument('columns', help='Metrics to collect. Comma separated.')

args = parser.parse_args(sys.argv[1:])

d = {}

filepath= os.path.join(STATS_PATH, args.config + '.hemem-colloid.log')
if os.path.isfile(filepath):
    load_colloid(d, filepath)

filepath= os.path.join(STATS_PATH, args.config + '.app.txt')
if os.path.isfile(filepath):
    load_gups(d, filepath)

cols = args.columns.split(',')
res = []
for col in cols:
    res.append(query(d, col))

ts_len = len(res[0])
for i in range(len(res)):
    if len(res[i]) != ts_len:
        raise Exception('ts length mismatch')
    

for i in range(ts_len):
    print(' '.join([str(res[j][i]) for j in range(len(res))]))
