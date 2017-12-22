#!/bin/bash


#********
# USAGE *
#********

display_usage() { 
	echo -e "DESCRIPTION: it partitions each region of a bedfile in the desired number of bins \n"
	echo -e "\t--bedfile <bedFile> \n"
	echo -e "\t--bins <number of bins> \n"
	echo -e "\t--stranded <whether to take into account the strand type in the sixth column> (default: TRUE) \n"
} 


if [[  $1 == "--help" ||  $1 == "-h" ]]
then
    	display_usage
        exit 0
fi


if [  $# -le 1  ]
then
	echo -e "ERROR: insufficient number of arguments\n"
    	display_usage
        exit 1
fi



#******************
# READING OPTIONS *
#******************

while [[ $# -gt 1 ]]; do

	key="$1"
	
	case $key in
    	    	
	--bedfile)
    	bedFile="$2"
    	shift # past argument
    	;;
    	
	--bins)
    	bins="$2"
    	shift # past argument
    	;;
    	
	--stranded)
	stranded="$2"
	;;
	*)
	
	;;
	esac
	shift
done


: ${stranded:="TRUE"}



if [[ ! -e "$bedFile" ]]
then
	echo "ERROR: no bedFile available"
	display_usage
	exit 1
fi



re='^[0-9]+$'
if ! [[ $bins =~ $re ]]
then
	echo "ERROR: 'bins' is not a number"
	display_usage
	exit 1
fi




#********
# BEGIN *
#********



awk -v b="$bins" -v s="$stranded" 'BEGIN{ OFMT ="%0.0f"; OFS=FS="\t" } {
start = $2;
end = $3;
strand = $6
step = ( $3 - $2 )/ b; 
for ( i=0; i < b; i++ ) {
	if ( s == "FALSE" ) {
		print $1, start+step*i, start+step*(i+1), $4, $5, $6, i+1 }
	else { 
		if (strand == "+") {
			print $1, start+step*i, start+step*(i+1), $4, $5, $6, i+1 }
		else { 
			print $1, start+step*i, start+step*(i+1), $4, $5, $6, (b-i) } }
	}
}' $bedFile
