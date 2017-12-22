# -*- coding: utf-8 -*-
##takes in input the output path and 2 files corresponding to 2 gene sets with 3 columns each one as follows:
##identifier, class (sth to discriminate between genes in file1 and genes in file2), expression level
##for each gene in the first file retrieves a gene from the second file with similar level of expression

import sys

first_arg = sys.argv[1]
second_arg = sys.argv[2]
third_arg = sys.argv[3]

def compare_expression_levels (file1=first_arg, file2=second_arg, output=third_arg):
    f = open(file1)
    g = open(file2)
    dc_file1 = {}
    dc_file2 = {}
    final_list = []
    for line in f.readlines():
        line = line.strip().split("\t") 
        value = round(float(line[2]))
        dc_file1[value] = dc_file1.get(value, 0) +1
    for line in g.readlines():
        line = line.strip().split("\t")
        identifier = line[0]
	classifier = line[1]
        value = round(float(line[2]))
        dc_file2[value] = dc_file2.get(value, [])+[(classifier,identifier)]
        dc_file2[value].sort()
    for key in (sorted(dc_file1.keys())):
        test = dc_file1[key]
        c = key
        d = key
	while test >0: ##number of genes from file1 with a given expression level
            if key in dc_file2.keys(): ##there are genes from file2 with the same level of expression
                if dc_file1[key] <= len(dc_file2[key]): #there are enough stable genes with same level of expression
                    for time in range(dc_file1[key]):
                        if dc_file2[key][time] not in final_list:
                            final_list.append(dc_file2[key][time])
                            test -= 1
                else: ##there are not enough genes from file2 with the same level of expression
                    for time in range(len(dc_file2[key])):
                        if dc_file2[key][time] not in final_list:
                            final_list.append(dc_file2[key][time])
                            test -= 1
            if test > 0: ##either there are not genes from file2 with the same level or there are not enough
                b = test
                c += 1
                d -= 1
                if d in dc_file2.keys():
                    if (len(dc_file2[d]) >= test):
                        for j in range(b):
                            if dc_file2[d][j] not in final_list:
                                final_list.append(dc_file2[d][j])
                                test -= 1
                        b = test
                    else:
                        for j in range(len(dc_file2[d])):
                            if dc_file2[d][j] not in final_list:
                                final_list.append(dc_file2[d][j])
                                test -= 1
                                b -= 1
                elif (d not in dc_file2.keys()) or (test > 0):
                    if c in dc_file2.keys():
                        if (len(dc_file2[c]) >= test):
                            for j in range(b):
                                if dc_file2[c][j] not in final_list:
                                    final_list.append(dc_file2[c][j])
                                    test -= 1
                            b = test
                        else:
                            for j in range(len(dc_file2[c])):
                                if dc_file2[c][j] not in final_list:
                                    final_list.append(dc_file2[c][j])
                                    test -= 1
                                    b -= 1

    o = open(output, 'w')
    for id in final_list:
	o.write(id[1])
        o.write('\n')
    o.close()

if __name__ == "__main__":
    compare_expression_levels()

