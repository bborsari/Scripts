# simple mds, w/o colours
mds.R -i distance.matrix.tsv

# mds with colours and shapes
mds.R -i distance.matrix.tsv -c 4 -s 4 -d H3K4me3.R1.MDS.gene.counts.tsv

# mds with colours and shapes + labels whose coordinates are retrieved from the fit object (with and w/o header)
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{ print $1, "hello_world" }' | sed '1ilabels' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels TRUE --header_labels TRUE -d H3K4me3.R1.MDS.gene.counts.tsv -s 4 -c 4
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{ print $1, "hello_world" }' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels TRUE --header_labels FALSE -d H3K4me3.R1.MDS.gene.counts.tsv -s 4 -c 4

# same as above, but w/o colours and shapes
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{ print $1, "hello_world" }' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels TRUE --header_labels FALSE

# mds w/o colours and shapes, and providing coordinates of the labels (with and w/o header)
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{sum+=1; print sum, sum, "hello_world" }' | sed '1ix\ty\tlab' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels FALSE --header_labels TRUE
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{sum+=1; print sum, sum, "hello_world" }' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels FALSE --header_labels FALSE

# mds with colours and shapes, and providing coordinates of the labels (w/o header)
head H3K4me3.R1.MDS.gene.counts.tsv | tail -n+2 | cut -f1-4 | awk 'BEGIN{FS=OFS="\t"}{sum+=1; print sum, sum, "hello_world" }' | mds.R -i distance.matrix.tsv -l stdin --retrieve_coordinates_labels FALSE --header_labels FALSE -c 4 -s 4 -d H3K4me3.R1.MDS.gene.counts.tsv
