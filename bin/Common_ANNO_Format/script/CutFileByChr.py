#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import sys
import argparse
import logging
__author__='menghao'
__mail__='haomeng@genome.cn'

bindir=os.path.abspath(os.path.dirname(__file__))
pat1=re.compile('^\s*$')

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--indir',help='input directory',dest='indir',required=True)
	parser.add_argument('-t','--type',help='Mutation type: SNP or INDEL',dest='type',required=True)
	parser.add_argument('-s','--sample',help='sample name',dest='sample',required=True)
	parser.add_argument('-g','--genome',help='genome name, hg19 hg38',dest='genome',required=True)
	args=parser.parse_args()

	#set the logging
	logging.basicConfig(level=logging.DEBUG,format="%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s")

	input = '{0}/{1}.{2}.{3}'.format(args.indir, args.sample, args.type, args.genome+'_multianno.txt')
	if not os.path.exists(input):
		logging.error(input + '  do not exists!\n')
		sys.exit()

	#判断最开始是什么染色体
	[ header, firstchr, n ] = [ '', '', 0 ]
	with open (input,'r') as infile:
		for line in infile:
			n +=1
			if line.startswith('#') or re.search(pat1,line):continue
			if line.startswith('Chr'):
				header = line
				continue
			firstchr = line.rstrip().split('\t')[0]
			if n ==2: break

	#创建文件夹
	outdir = '{0}/{1}'.format(args.indir,args.sample)
	if not os.path.exists(outdir):
		os.makedirs(outdir)

	#切割染色体
	OUTFILE = open('{0}/{1}.{2}.{3}.{4}'.format(outdir,args.sample,firstchr,args.type, args.genome+'_multianno.txt'),'w')
	OUTFILE.write(header)
	
	log = {firstchr:1}
	with open (input,'r') as infile:
		for line in infile:
			n+=1
			if line.startswith('#') or line.startswith('Chr') or re.search(pat1,line):continue
			tmp = line.rstrip().split('\t')
			#print(tmp[0])
			if tmp[0] == firstchr:
				OUTFILE.write(line)
			else:
				OUTFILE.close()
				if tmp[0] not in log:
					OUTFILE = open('{0}/{1}.{2}.{3}.{4}'.format(outdir,args.sample,tmp[0],args.type, args.genome+'_multianno.txt'),'w')
					OUTFILE.write(header)
				else:
					OUTFILE = open('{0}/{1}.{2}.{3}.{4}'.format(outdir,args.sample,tmp[0],args.type,args.genome+'_multianno.txt'),'a')
				OUTFILE.write( line )
				firstchr = tmp[0]
				log[firstchr] = 1
	OUTFILE.close()


if __name__ == "__main__":
	main()
