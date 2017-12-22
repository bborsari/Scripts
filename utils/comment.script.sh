#!/bin/bash

# script to comment whatever file provided the rows to comment
# usage: comment.script.sh <file> <start> <end>


file=$1
start=$2
end=$3

awk -v start="$start" -v end="$end" 'BEGIN{FS=OFS="\t"}{
n++;
if(n>=start && n<=end){
	print "# "$0}
else{
	print $0}
}' $file 
