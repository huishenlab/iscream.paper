import sys
import gzip

bedfile = sys.argv[1]

def bed2cov(line):
    chr, start, end, beta, cov, mergecg = line.split('\t')
    percent, meth, unmeth = convert(float(beta), int(cov))
    return '\t'.join([chr, start, start, str(percent), str(meth), str(unmeth)])

def convert(beta, cov):
    percent = round(beta * 100)
    meth = round(beta * cov)
    unmeth = cov - meth
    return [percent, meth, unmeth]

with gzip.open(bedfile, 'rt') as bed:
    for line in bed:
        print(bed2cov(line))

