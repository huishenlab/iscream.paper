import gzip
import sys

def parse_entry(entry_line, bed_writer):
    split_entry = entry_line.split("\t")
    if len(split_entry) < 2:
        return
    gene = split_entry[2]
    if gene != "gene":
        return
    chr = split_entry[0]
    start = int(split_entry[3]) - 1
    end = split_entry[4]
    ft_attr = list(filter(None, split_entry[8].split(";")))
    ft_attr_dict = dict([x.strip().split() for x in ft_attr])
    if ft_attr_dict['gene_biotype'] != '"protein_coding"':
        return
    if 'gene_name' in ft_attr_dict:
        gene_name = ft_attr_dict["gene_name"]
    else:
        gene_name = ""
    bed_writer.write(f"chr{chr}\t{start}\t{end}\t{gene_name}\n")


with (
    gzip.open(sys.argv[1], "rt") as gtf,
    open("genes.bed", "w") as bed,
):
    [parse_entry(entry.strip(), bed) for entry in gtf]
