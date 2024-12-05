#!/usr/bin/env python3
import argparse
import sys
import os
import re

bindir = os.path.abspath(os.path.dirname(__file__))
__author__='yangyumei'
__mail__= 'yumeiyang@annoroad.com'


pat1=re.compile('^s+$')

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--infile',help='input file',dest='infile',required=True)
	parser.add_argument('-o','--outfile',help='outfile',dest='outfile',required=True)
	args=parser.parse_args()
	
	with open( args.infile, 'r') as input, open(args.outfile, 'w') as output:
		for line in input:
			tmp = line.rstrip().split('\t')
			if line.startswith("Chr"):
				head = ["Chr",'Start',"End","Func.ensGene","Gene.ensGene","GeneDetail.ensGene","ExonicFunc.ensGene","AAChange.ensGene","Gene","CN","Depth"]
				output.write('\t'.join(head)+'\n')
				continue
			out_index = [ 0,1,2,5,6,7,8,9,16,18,19 ]
			out_value = [tmp[i] for i in out_index]
			output.write('\t'.join(out_value)+'\n')
	
	





if __name__ == '__main__':
	main()



