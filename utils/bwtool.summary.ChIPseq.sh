#!/bin/bash


#********
# USAGE *
#********

display_usage() {
	echo -e "DESCRIPTION: computes bwtool summary of a ChIP-seq sample provided a bedfile of genomic regions\n"
	echo -e "\t--exp <experiment Id>\n"
	echo -e "\t--db <dashboard_file> (i.e. chipseq.db)\n"
	echo -e "\t--loci <bedFile>\n"
	echo -e "\t--label (e.g. a specific label you want to add to the output file)\n"
	echo -e "\t--type <pileupSignal/pvalueSignal/fcSignal> (default: pileupSignal)\n"
	echo -e "\t--outFolder (default: cwd)\n"
	echo -e "\t--verbose <TRUE/FALSE> (default: FALSE)\n"
} 


if [[  $1 == "--help" ||  $1 == "-h" ]]
then
    	display_usage
        exit 0
fi


if [  $# -le 7 ]
then
	echo "ERROR: insufficient number of arguments\n"
    	display_usage
	exit 1
fi




#***************
# READ OPTIONS *
#***************

while [[ $# -gt 1 ]]; do

	key="$1"
	
	case $key in
    	
	--exp)
    	exp="$2"
    	shift # past argument
    	;;
    	
	--db)
    	db="$2"
    	shift # past argument
    	;;
    	
	--loci)
    	loci="$2"
    	shift # past argument
    	;;

	--method)
	method="$2"
	shift # past argument
	;;

	--log)
	log="$2"
	shift # past argument
	;;

	--label)
	label="$2"
	shift # past argument
	;;

	--type)
	type="$2"
	shift # past argument
	;;

	--outFolder)
	outFolder="$2"
	shift
	;;
	
	--verbose)
	verbose="$2"
	;;
	*)
	
	;;
	esac
	shift
done


: ${type:="pileupSignal"}
: ${verbose:="FALSE"}
: ${label:=""}
: ${outFolder:="."}


if [[ "$type" != "pileupSignal" && "$type" != "pvalueSignal" && "$type" != "fcSignal" ]]
then
	echo "ERROR: 'type' must be a .bw file type"
	exit 1
fi 



if [[ "$verbose" == "TRUE" ]]
then

        echo "reading options .."
        echo "ChIP-seq exp: " "${exp}"
        echo "dashboard file: " "${db}"
        echo "bedFile genomic regions: " "${loci}"
        echo "label: " "${label}"
        echo "bigWig data type: " "${type}"
	echo "output folder: " "${outFolder}"

fi


#********
# BEGIN *
#********


if [[ "$verbose" == "TRUE" ]]
then
	echo -e "bwtool summary .."
fi

awk -v Myexp="$exp" -v type="$type" 'BEGIN{ FS=OFS="\t" }
$1==Myexp && $5==type {print $2}' $db | while read line; do
	if [[ "$label" == "" ]]
	then
		bwtool summary $loci -header -keep-bed $line "$outFolder"/"$exp"."$(basename $db .db)".bwtool.summary.tsv
	else
		bwtool summary $loci -header -keep-bed $line "$outFolder"/"$exp"."$(basename $db .db)"."$label".bwtool.summary.tsv
	fi
done

