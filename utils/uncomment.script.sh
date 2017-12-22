#!/bin/bash

# script to uncomment whatever file provided the rows to comment
# usage: uncomment.script.sh <file> <start> <end>


file=$1
start=$2
end=$3

awk -v start="$start" -v end="$end" 'BEGIN{FS=OFS="\t"}{
n++;
if(n>=start && n<=end){
	split( $0, a, "# " )
	print a[2]}
else{
	print $0}
}' $file 
