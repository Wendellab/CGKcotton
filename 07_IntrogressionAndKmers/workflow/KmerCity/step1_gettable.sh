(
echo "Sample FastQ NbReads Seed"
ls /path/to/CGK_PROJECT/07_Kmer/03_nuclear/*.gz | sort | while read f; do
    sample=$(basename "$f" | sed 's/_clean.*//')
    if [[ $sample == YUC* ]]; then
        sample=$(echo "$sample" | sed 's/_.*//')
    fi
    seed=$(od -vAn -N2 -tu2 < /dev/urandom | tr -d ' ')
    echo "${sample} ${f} 6000000 ${seed}"
done
) > fastq_table_n38.txt
