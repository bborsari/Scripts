import sys
import math

first_arg = sys.argv[1]
second_arg = sys.argv[2]



def ggline_input(input_file=first_arg, output_file=second_arg):
    dz = {}
    f = open(input_file)
    o = open(output_file, 'w')
    i = 1
    for time in [0, 3, 6, 9, 12, 18, 24, 36, 48, 72, 120, 168]:
        dz[i]= time
        i += 1
    for line in f.readlines():
        line = line.strip().split("\t")
        for value in range(len(line)):
            if value > 0:
                if line[value] == "NA":
                    line[value]= 0
                o.write(str(line[0]+"\t"+str(dz[value])+"\t"+str(line[value])))
                o.write("\n")
    o.close()

if __name__=="__main__":
    ggline_input()
