#!/usr/bin/env python


import sys
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-I", "--input", dest="input", default="stdin")
options, args = parser.parse_args()

open_input = sys.stdin if options.input == "stdin" else open(options.input)

d={}
c={}
pos=0
prev_tag=""
m=0
for line in open_input.readlines():
	if line[0:8] == "!Sample_":
		splitline = line.strip().replace('"', '').split("\t")
		if splitline[0] == "!Sample_title":
			for sample in splitline[1:]:
				d[sample]=[]
				c[pos]=sample
				pos+=1
		else:
			tag=splitline[0][8:]
			if tag == prev_tag:
				m+=1
				new_tag=tag+"_"+str(m)
				prev_tag=tag
				tag=new_tag
			else:
				prev_tag=tag
				m=0
			for n in range(len(splitline) -1):
				info=tag+"="+splitline[n+1]+";"
				d[c[n]].append(info)
for key in d.keys():
	l = []
	l.append(key)
	l.append(" ".join(d[key]))
	print "\t".join(l)
