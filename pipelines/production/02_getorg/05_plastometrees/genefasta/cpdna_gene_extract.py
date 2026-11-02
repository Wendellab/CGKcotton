#!/usr/bin/env python3
from Bio import AlignIO
import sys, os

# Parse arguments
aln_file, gff_file, ref_id, outdir = sys.argv[1:5]
os.makedirs(outdir, exist_ok=True)

# Load alignment and reference sequence
aln = AlignIO.read(aln_file, "fasta")
ref_seq = str(next(r for r in aln if r.id == ref_id).seq)

# Map reference position to alignment index (skip gaps)
ref_to_aln = {}
pos = 0
for i, b in enumerate(ref_seq):
    if b != '-':
        pos += 1
        ref_to_aln[pos] = i

# Parse genes from GFF (only 'gene' features)
genes = []
for line in open(gff_file):
    if line.startswith('#') or len(cols := line.rstrip().split('\t')) < 9 or cols[2] != 'gene':
        continue
    name = next((f.split('=',1)[1] for f in cols[8].split(';') if f.startswith('gene=')), None)
    if name:
        genes.append((int(cols[3]), int(cols[4]), name))

# Merge overlapping genes
genes.sort()
merged = []
for s, e, n in genes:
    if merged and s <= merged[-1][0][1]:
        merged[-1][0][1] = max(merged[-1][0][1], e)
        merged[-1][1].append(n)
    else:
        merged.append([[s, e], [n]])

# Extract and save each merged region
for coords, names in merged:
    s, e = coords
    if s in ref_to_aln and e in ref_to_aln:
        out = os.path.join(outdir, f"{'-'.join(sorted(set(names)))}.fasta")
        AlignIO.write(aln[:, ref_to_aln[s]:ref_to_aln[e]+1], out, "fasta")
        print(f"[OK] saved to {out}")