import sys

def mem_str_to_gb(n):
    if n[-1].isdigit():
        return int(n) / 1000000.
    elif n[-1].upper() == 'K':
        return int(n[:-1]) / 1000000.
    elif n[-1].upper() == 'M':
        return float(n[:-1]) / 1000.
    elif n[-1].upper() == 'G':
        return float(n[:-1])

def parse_file(filename):
    rep = 0
    name = filename.split(".")[0]
    with open(filename) as f:
        data = f.read()

    time_groups = list(filter(None, data.split("TIME ")))
    groups = [list(filter(None, g.split('\n'))) for g in time_groups]
    for g in groups:
        time = g[0]
        if time == "0":
            rep += 1
        mems = g[1:]
        mems = list(map(mem_str_to_gb, mems))
        print(f"{name}\t{time}\t{sum(mems)}\t{rep}")

print("package\ttime\tmemory\trep")
parse_file(sys.argv[1])

