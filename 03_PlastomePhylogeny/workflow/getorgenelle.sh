#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=80 
#SBATCH --mem=200G 
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.makePR.%A_%a.out 
#SBATCH --job-name="getorganelle"
#SBATCH --array=13

module load getorganelle/1.7.7.0-py310-u45ybv3
DIR=/path/to/CGK_PROJECT/01_trimedreads
outputDIR=/path/to/CGK_PROJECT/02_getorg

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

echo "the first file is " $file1
echo "the second file is " $file2
echo "sample name is" $name

thr=80

get_organelle_from_reads.py -t $thr -s /path/to/CGK_PROJECT/02_getorg/change_all_aln_selected_fix.fasta -1 $file1 -2 $file2 -o $outputDIR/01_plastome_output/$name -k 21,45,65,85,109,115 -R 20 --max-reads 536870910 -F embplant_pt --overwrite

#get_organelle_from_reads.py -t $thr -1 $file1 -2 $file2 -o $outputDIR/01_nrDNA_output/$name -k 21,45,65,85,105,125,127 -R 500 --reduce-reads-for-coverage 1500 --max-reads 536870910  -F embplant_nr --overwrite

#get_organelle_from_reads.py -t $thr -1 $file1 -2 $file2 -o $outputDIR/01_plastome_output/$name -R 15 -k 21,45,65,85,105,125 -F embplant_pt
#get_organelle_from_reads.py -t $thr -1 $file1 -2 $file2 -o $outputDIR/01_nrDNA_output/$name -R 10 -k 35,85,115 -F embplant_nr

#get_organelle_from_reads.py -t $thr -1 $file1 -2 $file2 -o $outputDIR/01_nrDNA_output/$name -R 200 -k 21,35,45,85,115,125,127 --max-reads 5E7 -F embplant_nr --overwrite
