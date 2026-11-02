[AUTHOR@nova19-speedy-5 03_genetrees]$ awk -F'\t' '
NR>1 {

    if ($2 != 40) {
        not40++
        next
    }

    if ($9 == 0) {
        zero++
    } else {
        retained++
        aln_sum += $3
        pis_sum += $9
    }
}
END {
    printf "No_of_taxa != 40:\t%d\n", not40
    printf "PIS=0 loci (among 40-taxon loci):\t%d\n", zero
    printf "Retained loci (40 taxa & PIS>0):\t%d\n", retained
    printf "Mean alignment length:\t%.2f\n", aln_sum/retained
    printf "Total parsimony-informative sites:\t%d\n", pis_sum
    printf "Mean parsimony-informative sites per locus:\t%.2f\n", pis_sum/retained
}' n19028_all_trees_stat.txt
No_of_taxa != 40:       224
PIS=0 loci (among 40-taxon loci):       2
Retained loci (40 taxa & PIS>0):        18803
Mean alignment length:  2478.98
Total parsimony-informative sites:      3011666
Mean parsimony-informative sites per locus:     160.17
