#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import sys
import argparse
__author__='menghao'
__mail__='haomeng@genome.cn'

bindir=os.path.abspath(os.path.dirname(__file__))
pat1=re.compile('^\s*$')

def check_exists(content, Type):
	if Type == "file":
		if not os.path.isfile(content):
			sys.stderr.write(content + ' not exists!\n')
			sys.exit(1)
	elif Type == 'dir':
		if not os.path.exists(content):
			os.makedirs(content)
	else:
		pass
	return content

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-g','--group',help='diff group',dest='group',required=True)
	parser.add_argument('-s','--sample',help='diff sample',dest='sample',required=True)
	parser.add_argument('-i','--indir',help='anno indir',dest='indir',required=True)
	parser.add_argument('-o','--outdir',help='diff outdir',dest='outdir',required=True)
	parser.add_argument('-t','--type',help='{SNP, INDEL}',dest='Type',required=True)
	parser.add_argument('-k','--key',help='anno file suffix',dest='key',default='hg19_multianno.txt')
	args=parser.parse_args()

	check_exists(args.outdir, 'dir')

	sampleNum = len(args.sample.split(','))

	allvars = {}
	samples = {}
	for sample in args.sample.split(','):
		ANNO = '{0}/{1}.{2}.{3}'.format(args.indir, sample, args.Type, args.key)
		check_exists(ANNO, 'file')

		OUT_FILE = '{0}/{1}.{2}.diff_key.txt'.format(args.outdir, sample, args.Type)
		with open (ANNO) as anno, open(OUT_FILE, 'w') as OUTH:
			OUTH.write(sample + '\n')
			for line in anno:
				if line.startswith(('#','Chr')): continue
				C, S, E, A, R, *a = line.rstrip().split('\t')
				key = '{0}:{1}_{2}-{3}:{4}'.format(C, S, E, A, R)
				OUTH.write(key + '\n')
				allvars[key] = allvars.get(key,0) + 1
				samples.setdefault(key,[]).append(sample)

	with open ('{0}/{1}.venn'.format(args.outdir, args.group),'w') as LIST:
		for sample in args.sample.split(','):
			LIST.write('{1}\t{0}/{1}.{2}.diff_key.txt\n'.format(args.outdir, sample, args.Type))

	for i in range(1,sampleNum+1):
		if i == sampleNum:
			OUT = open('{0}/{1}.all.overlap.list'.format(args.outdir, args.group),'w')
		else:
			OUT = open('{0}/{1}.{2}.overlap.list'.format(args.outdir, args.group, i),'w')

		for key in sorted(allvars):
			if allvars[key] == i:
				samplelist = ','.join(samples[key])
				OUT.write('{0}\t{1}\n'.format(key, samplelist))
		OUT.close()

if __name__ == "__main__":
	main()
