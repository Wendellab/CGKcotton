#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="CGK_merge_sorted"


cd /path/to/CGK_PROJECT/06_species_specific
mkdir -p 00_finalmerge
cd 00_finalmerge
module load bcftools vcftools

# =========================
# 1. SORT (fix unsorted VCF error)
# =========================
bcftools sort -Oz -o C1.sorted.vcf.gz \
/path/to/CGK_PROJECT/06_species_specific/C1_ref/VCF/merged/C1C2_C1ref.combined.transannoG2.vcf.gz

bcftools sort -Oz -o G1.sorted.vcf.gz \
/path/to/CGK_PROJECT/06_species_specific/G1_ref/VCF/merged/G1_G1ref.combined.transannoG2.vcf.gz

bcftools sort -Oz -o G2G3.sorted.vcf.gz \
/path/to/CGK_PROJECT/06_species_specific/G2_ref/VCF/merged/G2G3_G1ref.combined.vcf.gz

bcftools sort -Oz -o K2.sorted.vcf.gz \
/path/to/CGK_PROJECT/06_species_specific/K2_ref/VCF/merged/K_K2ref.combined.transannoG2.vcf.gz

bcftools sort -Oz -o D5.sorted.vcf.gz \
/path/to/CGK_PROJECT/06_species_specific/D5_ref/VCF/merged/D5_D5ref.combined.transannoG2.vcf.gz




# =========================
# 2. INDEX sorted VCFs
# =========================
bcftools index -t C1.sorted.vcf.gz
bcftools index -t G1.sorted.vcf.gz
bcftools index -t G2G3.sorted.vcf.gz
bcftools index -t K2.sorted.vcf.gz
bcftools index -t D5.sorted.vcf.gz



# =========================
# 3. SPLIT MULTIALLELIC
# =========================
bcftools norm -m -any --force -Oz -o C1.split.vcf.gz C1.sorted.vcf.gz
bcftools norm -m -any --force -Oz -o G1.split.vcf.gz G1.sorted.vcf.gz
bcftools norm -m -any --force -Oz -o G2G3.split.vcf.gz G2G3.sorted.vcf.gz
bcftools norm -m -any --force -Oz -o K2.split.vcf.gz K2.sorted.vcf.gz
bcftools norm -m -any --force -Oz -o D5.split.vcf.gz D5.sorted.vcf.gz

# =========================
# 4. REMOVE DUPLICATES
# =========================
bcftools norm -d exact -Oz -o C1.dedup.vcf.gz C1.split.vcf.gz
bcftools norm -d exact -Oz -o G1.dedup.vcf.gz G1.split.vcf.gz
bcftools norm -d exact -Oz -o G2G3.dedup.vcf.gz G2G3.split.vcf.gz
bcftools norm -d exact -Oz -o K2.dedup.vcf.gz K2.split.vcf.gz
bcftools norm -d exact -Oz -o D5.dedup.vcf.gz D5.split.vcf.gz

# =========================
# 5. INDEX DEDUP
# =========================
bcftools index -t C1.dedup.vcf.gz
bcftools index -t G1.dedup.vcf.gz
bcftools index -t G2G3.dedup.vcf.gz
bcftools index -t K2.dedup.vcf.gz
bcftools index -t D5.dedup.vcf.gz


# =========================
# 6. MERGE
# =========================
bcftools merge \
  -m all \
  -Oz \
  -o CGKD_merged_sorted.vcf.gz \
  ../00_finalmerge/C1.dedup.vcf.gz \
  ../00_finalmerge/G1.dedup.vcf.gz \
  ../00_finalmerge/G2G3.noC3-1.dedup.vcf.gz \
  ../00_finalmerge/K2.dedup.vcf.gz \
  D5.dedup.vcf.gz

bcftools index -t CGK_merged_sorted.vcf.gz

vcftools \
  --gzvcf CGK_merged_sorted.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --remove-indels \
  --recode --recode-INFO-all \
  --out CGK.biallelic
  
vcftools \
  --vcf CGK.biallelic.recode.vcf \
  --max-missing 0.9 \
  --mac 1 \
  --minDP 5 \
  --recode \
  --recode-INFO-all \
  --out CGK.biallelic.missing90.mindp5
  
bcftools annotate --set-id +"%CHROM:%POS:%REF:%ALT" CGK.biallelic.missing90.mindp5.recode.vcf >  CGK.biallelic.missing90.mindp5.id.vcf

bcftools view -e 'ALT="*"' CGK.biallelic.missing90.mindp5.id.vcf > CGK.biallelic.missing90.mindp5.id.altfix.vcf