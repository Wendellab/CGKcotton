
module load perl/5.40.0-l2sxfqz
module load zlib/1.2.13-wcef3x6
module load perl-list-moreutils/0.430-6om3ljo
module load perl-parallel-forkmanager/2.02-vh7wtb2
module load perl-gd/2.53-u7fgagv

#micromamba activate /path/to/USER_ROOT/00_BioinformaticTools/envs/envs/kmercity/

#cd /path/to/USER_ROOT/00_BioinformaticTools/kmercity/workflow/envs/
#cpanm --installdeps .

perl /path/to/USER_ROOT/00_BioinformaticTools/kmercity/workflow/scripts/KCounts_2_intersections.pl \
    -database /path/to/CGK_PROJECT/07_Kmer/n38_30Kmer_output/KMER_database/n38_30mer_30mer_cut30x_counts.tab.gz \
    -outdir /path/to/CGK_PROJECT/07_Kmer/n38_30Kmer_output \
    -prefix n38_30mer  


	
#########################################################################

cut -d" " -f1 fastq_table_n38.txt | uniq |
awk '
BEGIN {
    color["C1"] = "red"
    color["C2"] = "blue"
    color["G1"] = "green"
    color["G2"] = "purple"
    color["G3"] = "orange"
    color["K"]  = "cyan"
}

{
    match($1, /^([A-Z]+[0-9]+)/, m)
    prefix = m[1]

    # K groups
    if (prefix ~ /^K[0-9]+$/) {
        group = "K"
    }
    # G1, G2, G3
    else if (prefix ~ /^G[0-9]+/) {
        group = substr(prefix,1,2)
    }
    # C1, C2
    else {
        group = prefix
    }

    print $1 "\t" color[group]
}' |
sort -k1,1 > /path/to/CGK_PROJECT/07_Kmer/n38_30Kmer_output/INTERSEC-n38_30mer/graph_accession.tab

#####################################

perl /path/to/USER_ROOT/00_BioinformaticTools/kmercity/workflow/scripts/Draw_KGraph.pl \
-in /path/to/CGK_PROJECT/07_Kmer/n38_30Kmer_output/INTERSEC-n38_30mer/n38_30mer.intersections \
-list /path/to/CGK_PROJECT/07_Kmer/n38_30Kmer_output/INTERSEC-n38_30mer/graph_accession.tab \
-outprefix n38_30mer \
-classes 10,20,30

module load librsvg/2.56.2-py311-6cvnsym
rsvg-convert -f pdf -o n40_graph.pdf n40_graph.svg


#####################################

perl /path/to/USER_ROOT/00_BioinformaticTools/kmercity/workflow/scripts/KCounts_2_intersections.pl \
    -database /path/to/CGK_PROJECT/07_Kmer/n40_50Kmer_output/KMER_database/n40_50mer_50mer_cut30x_counts.tab.gz \
    -outdir /path/to/CGK_PROJECT/07_Kmer/n40_50Kmer_output/ \
    -prefix n40_50mer  
	
perl /path/to/USER_ROOT/00_BioinformaticTools/kmercity/workflow/scripts/Draw_KGraph.pl \
-in /path/to/CGK_PROJECT/07_Kmer/n40_50Kmer_output/INTERSEC-n40_50mer/n40_50mer.intersections \
-list /path/to/CGK_PROJECT/07_Kmer/n40_31Kmer_output/INTERSEC-n40/graph_accession2.tab \
-outprefix /path/to/CGK_PROJECT/07_Kmer/n40_50Kmer_output/n40_50mer_graph \
-classes 10,20,30

module load librsvg/2.56.2-py311-6cvnsym
rsvg-convert -f pdf -o n40_50mer_graph.pdf n40_50mer_graph.svg

