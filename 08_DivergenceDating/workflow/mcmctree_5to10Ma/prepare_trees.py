"""Prepare gene trees by exact locus ID and root/calibrate an ASTRAL topology.

Requires ETE3. The rebuild deliberately enforces an exclusive D5 outgroup split;
it is a corrected workflow, not guaranteed to reproduce historical exclusions.
"""
import argparse
import csv
import json
import re
from pathlib import Path
from ete3 import Tree


def read_ids(path):
    return [x.strip() for x in Path(path).read_text().splitlines() if x.strip()]


def root_on_outgroup(tree, outgroups):
    names = tree.get_leaf_names()
    if len(names) != len(set(names)):
        raise ValueError('duplicate tip labels')
    all_names = set(names)
    if not outgroups < all_names:
        raise ValueError('outgroup missing, or no ingroup')
    # An edge separates the requested outgroup iff one side is exactly that set.
    # Check both directions; this works regardless of the current arbitrary root.
    for node in list(tree.traverse()):
        if node.is_root():
            continue
        side = set(node.get_leaf_names())
        if side == outgroups or all_names - side == outgroups:
            tree.set_outgroup(node)
            if outgroups not in [set(c.get_leaf_names()) for c in tree.children]:
                raise ValueError('failed to place root at the outgroup split')
            return tree
    raise ValueError('no exclusive outgroup split after support collapse')


def load_named_trees(path):
    trees = {}
    for line in Path(path).read_text().splitlines():
        if not line.strip():
            continue
        match = re.fullmatch(r'\s*tree\s+(\S+)\s*=\s*(.+;)\s*', line)
        if not match:
            raise ValueError('Expected tree GENE_ID = NEWICK; in aggregate tree file')
        gene, newick = match.groups()
        if gene in trees:
            raise ValueError('duplicate tree for ' + gene)
        trees[gene] = newick
    return trees


def genes(args):
    out = args.output
    out.mkdir(parents=True, exist_ok=False)
    trees = load_named_trees(args.genetrees / 'n19028_all_trees.tre')
    outgroups = set(read_ids(args.genetrees / 'outgroup.list'))
    selected = []
    with (args.genetrees / 'n19028_all_trees_stat.txt').open() as handle:
        for row in csv.DictReader(handle, delimiter='\t'):
            if int(row['No_of_taxa']) == 40:
                gene = re.fullmatch(r'DCGK_(.+)\.t1_aln_trim\.fasta', row['Alignment_name']).group(1)
                selected.append(gene)
    if len(selected) != len(set(selected)):
        raise ValueError('duplicate locus IDs in alignment statistics')
    accepted, rejected = [], []
    expected_tips = None
    with (out / 'gene_trees.rooted.nwk').open('w') as rooted:
        for gene in selected:
            if gene not in trees:
                rejected.append((gene, 'missing_gene_tree'))
                continue
            # Parse internal labels as names to avoid inventing support for
            # unlabeled branches. IQ-TREE single-support labels are required.
            tree = Tree(trees[gene], format=1)
            names = tree.get_leaf_names()
            if len(names) != 40 or len(set(names)) != 40:
                raise ValueError('Expected 40 unique tips: ' + gene)
            if expected_tips is None:
                expected_tips = set(names)
            if set(names) != expected_tips:
                raise ValueError('Inconsistent taxon set: ' + gene)
            for node in list(tree.traverse('postorder')):
                if not node.is_leaf() and not node.is_root() and node.name:
                    try:
                        support = float(node.name)
                    except ValueError as exc:
                        raise ValueError('Ambiguous/multiple support labels in ' + gene) from exc
                    if not 0 <= support <= 100:
                        raise ValueError('Support outside 0--100 in ' + gene)
                    if support <= args.support:
                        node.delete(prevent_nondicotomic=False, preserve_branch_length=False)
            try:
                root_on_outgroup(tree, outgroups)
            except ValueError as exc:
                rejected.append((gene, str(exc)))
                continue
            alignment = args.alignments / ('DCGK_' + gene + '.t1_aln_trim.fasta')
            if not alignment.is_file():
                raise FileNotFoundError(alignment)
            # Small FASTA inputs: validate exact taxon equality and aligned lengths.
            lengths = {}
            name = None
            for line in alignment.read_text().splitlines():
                if line.startswith('>'):
                    name = line[1:].split()[0]
                    if name in lengths:
                        raise ValueError('Duplicate FASTA tip: ' + gene)
                    lengths[name] = 0
                elif line.strip():
                    if name is None:
                        raise ValueError('Sequence before FASTA header: ' + gene)
                    lengths[name] += len(''.join(line.split()))
            if set(lengths) != expected_tips or len(set(lengths.values())) != 1 or min(lengths.values()) < 1:
                raise ValueError('Invalid alignment or taxon mismatch: ' + gene)
            # Branch lengths are immaterial to ASTRAL; do not carry collapsed
            # substitution lengths forward as if they were dated branches.
            rooted.write(tree.write(format=9) + '\n')
            accepted.append((gene, str(alignment.resolve())))
    if not accepted:
        raise ValueError('No retained loci')
    (out / 'retained_gene_ids.txt').write_text(''.join(g + '\n' for g, _ in accepted))
    (out / 'alignment_paths.txt').write_text(''.join(p + '\n' for _, p in accepted))
    (out / 'taxa.txt').write_text('\n'.join(sorted(expected_tips)) + '\n')
    with (out / 'excluded_loci.tsv').open('w', newline='') as handle:
        writer = csv.writer(handle, delimiter='\t')
        writer.writerow(['gene_id', 'reason'])
        writer.writerows(rejected)
    summary = dict(selected_40_taxon_loci=len(selected), retained=len(accepted), excluded=len(rejected),
                   support_cutoff=args.support, policy='exclusive D5 split after support collapse')
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


def calibrate(args):
    if not 0 < args.lower < args.upper:
        raise ValueError('Require 0 < root minimum < root maximum')
    tree = Tree(args.tree.read_text().strip(), format=1, quoted_node_names=True)
    root_on_outgroup(tree, set(read_ids(args.outgroups)))
    if any(len(n.children) != 2 for n in tree.traverse() if not n.is_leaf()):
        raise ValueError('Dating topology must be bifurcating; do not resolve polytomies arbitrarily')
    # Strip ASTRAL support labels and coalescent branch lengths. IQ-TREE fits
    # substitution branch lengths on this fixed topology from the alignment.
    bare = tree.write(format=9).rstrip(';')
    args.output.write_text(bare + "'B(" + str(args.lower) + ',' + str(args.upper) + ")';\n")
    print('Root calibration written:', args.output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    p = sub.add_parser('genes')
    p.add_argument('--genetrees', type=Path, required=True)
    p.add_argument('--alignments', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--support', type=float, default=30)
    p.set_defaults(run=genes)
    p = sub.add_parser('calibrate')
    p.add_argument('--tree', type=Path, required=True)
    p.add_argument('--outgroups', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--lower', type=float, default=0.05)
    p.add_argument('--upper', type=float, default=0.08)
    p.set_defaults(run=calibrate)
    args = parser.parse_args()
    args.run(args)
