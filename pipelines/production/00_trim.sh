#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=100G 
#SBATCH --time=1-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.cultivar.%A_%a.out 
#SBATCH --job-name="makeVCF"
#SBATCH --array=1-18

DIR=/path/to/CGK_PROJECT/00_rawreads
tDir=/path/to/CGK_PROJECT/01_trimedreads
thr=20

oldname=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename.txt | cut -f1)
newname=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename.txt | cut -f2)


file1=$(ls -1 $DIR/$oldname/*_1.fq.gz)
file2=$(ls -1 $DIR/$oldname/*_1.fq.gz | sed 's/_1[.]fq/_2\.fq/')

name=$(basename $file1 _1.fq.gz)

echo "the first file is " $file1
echo "the second file is " $file2

trim reads with Trimmomatic:
module load  trimmomatic/0.39-zwxnnrx
cd $TMPDIR/
trimmomatic PE -threads $thr $file1 $file2 $TMPDIR/$name.R1.fq.gz $TMPDIR/$name.U1.fq.gz $TMPDIR/$name.R2.fq.gz $TMPDIR/$name.U2.fq.gz ILLUMINACLIP:/path/to/USER_ROOT/03_Ggvcf/Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75

mv $TMPDIR/$name.R1.fq.gz $tDir/$newname.R1.fq.gz
mv $TMPDIR/$name.R2.fq.gz $tDir/$newname.R2.fq.gz

module purge
