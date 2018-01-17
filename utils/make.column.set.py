#!/usr/bin/env python


#************
# LIBRARIES *
#************

import sys
from optparse import OptionParser


#*****************
# OPTION PARSING *
#*****************

parser = OptionParser()
parser.add_option("-i", "--input", dest="input", default="stdin")
options, args = parser.parse_args()

open_input = sys.stdin if options.input == "stdin" else open(options.input)



#********
# BEGIN *
#********

d={}
for line in open_input.readlines():
	name, val = line.strip().split('\t')
	d[name] = d.get(name, {})
	d[name][val] = d[name].get(val, 0) +1

for key in d.keys():
	mylist = []
	for name in d[key].keys():
		mystring = ":".join([name, str(d[key][name])])
		mylist.append(mystring)
	print key, "\t", ";".join(mylist)
