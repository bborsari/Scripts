#!/bin/bash
#for each gene returns if there's 2 FC between 2 conditions A and B (A >= 2B) and in which condition the gene is overexpressed

[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"


awk 'BEGIN{FS=OFS="\t"}{
	if(NR==1){
		c1=$1;
		c2=$2;
		print c1,c2,"status","condition"}
	else{
		if ($2<$3){
			condition=c2
			if ($3>=2*$2 && ($3-$2)>=1)
				{status="more_than_2_FC"}
			else
				{status="less_than_2_FC"}}
		else if($2>$3){
			condition=c1
			if ($2>=2*$3 && ($2-$3)>=1)
				{status="more_than_2_FC"}
			else
				{status="less_than_2_FC"}}
		else if($2==$3)
			{status="no_FC"; condition="null"};
		print $1,$2,$3,status,condition}}' $input





