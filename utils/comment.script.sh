#!/bin/bash

# script to comment  file
# usage: comment.script.sh <file>


file=$1

awk 'BEGIN{FS=" "; OFS="\t"}{if (( $1 ~ /^#/ ) || ($1=="")) {print $0} else {print "# "$0}}' $file
