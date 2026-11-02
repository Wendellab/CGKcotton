#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=30 
#SBATCH --mem=200G 
#SBATCH --time=2-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.trim.%A_%a.out 
#SBATCH --job-name="trim"
#SBATCH --array=22-41

DIR=/path/to/CGK_PROJECT/00_rawreads
tDir=/path/to/CGK_PROJECT/01_trimedreads
thr=30

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f1)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f1 | sed 's/_1[.]fastq/_2\.fastq/' | sed 's/_1[.]fq/_2\.fq/')

newname=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f2)

echo "the first file is " $file1
echo "the second file is " $file2
echo "new name is" $newname

#trim reads with Trimmomatic:
module load  trimmomatic/0.39-zwxnnrx
cd $TMPDIR/
trimmomatic PE -threads $thr $file1 $file2 $TMPDIR/$newname.R1.fq.gz $TMPDIR/$newname.U1.fq.gz $TMPDIR/$newname.R2.fq.gz $TMPDIR/$newname.U2.fq.gz ILLUMINACLIP:/path/to/USER_ROOT/03_Ggvcf/Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75

mv $TMPDIR/$newname.R1.fq.gz $tDir
mv $TMPDIR/$newname.R2.fq.gz $tDir

module purge
