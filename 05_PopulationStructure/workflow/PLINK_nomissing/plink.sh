#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=100G 
#SBATCH --time=05:00:00
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.plink.%J.out"
#SBATCH --job-name="plink"


vcf=/path/to/CGK_PROJECT/06_species_specific/00_finalmerge/CGK.biallelic.missing90.mindp5.id.altfix.vcf
output=CGK_G2ref
plink=/path/to/USER_ROOT/00_BioinformaticTools/plink


#Filtering LD by Plink 
$plink --threads 30 --vcf $vcf --mac 2 --mind 0.1  \
--indep-pairwise 50 10 0.2 --allow-extra-chr --const-fid \
--out $output

$plink --threads 30 --extract $output.prune.in  \
--make-bed --allow-extra-chr --const-fid --out $output \
--recode vcf-iid --vcf $vcf

$plink --threads 30 --mac 2 --mind 0.1 --vcf $vcf --allow-extra-chr --const-fid \
--extract $output.prune.in --recode --make-bed \
--pca 20 var-wts --distance square 1-ibs --out $output

paste -d '\t'  $output.mdist.id $output.mdist >  $output.distmatrix

module load r

Rscript PCA_plot.R
