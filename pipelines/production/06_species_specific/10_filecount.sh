#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=20:00:00
#SBATCH --job-name=count_vcf
#SBATCH --output=joblog/count_vcf.%j.out
#SBATCH --mail-type=END,FAIL

mkdir -p joblog

OUT=variant_counts.tsv
echo -e "Reference\tFile\tVariants" > "$OUT"

for f in "$PWD"/*/VCF/merged/*.gz; do
    ref=$(basename "$(dirname "$(dirname "$(dirname "$f")")")")
    n=$(zgrep -vc '^#' "$f")
    echo -e "${ref}\t$(basename "$f")\t${n}" | tee -a "$OUT"
done

echo
echo "Done. Results saved to $OUT"
