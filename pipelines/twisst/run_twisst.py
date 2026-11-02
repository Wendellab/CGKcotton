"""New topology-weighting rerun using the supplied Twisst implementation.

Requires ete3 and numpy. This wrapper was added during repository organization;
it is not claimed to be the historical command that generated reported weights.
"""
import argparse
import csv
import os
import random
import runpy
import subprocess
import sys
from pathlib import Path


def main():
    p = argparse.ArgumentParser()
    p.add_argument("trees", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--seed", type=int, default=20261101)
    p.add_argument("--groups", type=Path, required=True, help="External two-column sample/group TSV")
    a = p.parse_args()
    repo = Path(__file__).resolve().parents[2]
    upstream = repo / "pipelines/production/04_bam2fasta/03_genetrees/phyparts/twisst/twisst.py"
    groups_file = a.groups.resolve(strict=True)
    trees = a.trees.resolve(strict=True)
    output = a.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    pairs = [line.split() for line in groups_file.read_text().splitlines() if line.strip()]
    summaries = []
    for comparison in ["G", "G2G3", "G1"]:
        folder = output / comparison
        folder.mkdir()
        mapped = []
        for sample, group in pairs:
            group = "C" if group in ["C1", "C2"] else group
            if comparison == "G" and group in ["G1", "G2G3"]:
                group = "G"
            mapped.append((sample, group))
        groups = folder / "groups.tsv"
        groups.write_text("".join(f"{sample}\t{group}\n" for sample, group in mapped))
        topologies = folder / "topologies.nwk"
        topologies.write_text(f"(D5,((C,{comparison}),K));\n(D5,((C,K),{comparison}));\n(D5,(C,({comparison},K)));\n")
        weights = folder / "weights.tsv"
        # Seed Python's random module before entering the unmodified upstream code.
        launcher = "import random,runpy,sys; random.seed(int(sys.argv.pop(1))); script=sys.argv.pop(1); sys.argv[0]=script; runpy.run_path(script,run_name='__main__')"
        command = [sys.executable, "-c", launcher, str(a.seed), str(upstream),
                   "-t", str(trees), "-w", str(weights), "--groupsFile", str(groups),
                   "--inputTopos", str(topologies), "--outgroup", "D5", "--method", "complete",
                   "-g", "C", "-g", comparison, "-g", "K", "-g", "D5"]
        (folder / "command.txt").write_text(repr(command) + "\n")
        with (folder / "console.log").open("w") as log:
            subprocess.run(command, check=True, stdout=log, stderr=subprocess.STDOUT)
        totals = [0.0, 0.0, 0.0]
        n = 0
        with weights.open() as handle:
            reader = csv.DictReader((line for line in handle if not line.startswith("#")), delimiter="\t")
            for row in reader:
                values = [float(row[f"topo{i}"]) for i in [1, 2, 3]]
                if not all(v >= 0 for v in values) or sum(values) <= 0:
                    raise ValueError("Invalid or unresolved weights; inspect " + str(weights))
                denominator = sum(values)
                totals = [old + value / denominator for old, value in zip(totals, values)]
                n += 1
        if not n:
            raise ValueError("No per-locus weights")
        summaries.extend((comparison.replace("G2G3", "G2/G3"), f"T{i+1}", 100 * value / n, n)
                         for i, value in enumerate(totals))
    with (output / "weights_recomputed.csv").open("w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["Group", "Topology", "Weight", "loci"])
        writer.writerows(summaries)


if __name__ == "__main__":
    main()
