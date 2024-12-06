#!/usr/bin/env python3
import argparse
import sys
import os
import re
import time
start=time.clock()

bindir = os.path.abspath(os.path.dirname(__file__))
__author__='yangyumei'
__mail__= 'yumeiyang@annoroad.com'


pat1=re.compile('^s+$')

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',required=True,type=open)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True,type=argparse.FileType('w'))
	parser.add_argument('-s','--stat',help='output stat file',dest='stat',required=True,type=argparse.FileType('w'))
	parser.add_argument('-t','--threshold',help='DP threshold for filter vcf',dest='threshold',default=1)
	parser.add_argument('-g','--genotype',help='Genotype to retain for filter vcf',dest='genotype',default='1,0/1,1/0,1/1')
	parser.add_argument('-b','--bin',help='bindir',dest='bin',default='{0}'.format(os.path.dirname(bindir)))
	args=parser.parse_args()
	more,less,total=[0,0,0]
	sample=''
	genotypes=args.genotype.split(',')
	print(args.threshold,args.genotype)
	for line in args.input:
		if re.search("\t\./\.",line):continue
		if line.startswith('##') or re.search(pat1,line):
			args.output.write(line)
		elif line.startswith('#') :
			args.output.write(line)
			head=line.rstrip().split('\t')
			sample=head[-1]
		else :
			total+=1
			tmp=line.rstrip().split('\t')
			if tmp[6] != 'PASS' :continue
			if len(tmp) != 10 :
				print("\n your vcf file type is not right ,please check it out\n")
				exit(1)
			else :
				#total+=1
				format,info=tmp[8:10]
				#print(format)
				#print(info)
				index_DP=(format.split(':')).index('DP')
				tmp_info=info.split(':')
				DP_value=tmp_info[index_DP]
				index_GT=(format.split(':')).index('GT')
				GT_value=tmp_info[index_GT]
				index_AD=(format.split(':')).index('AD')
				REF_value,ALT_value=tmp_info[index_AD].split(',')[0:2]
				if int(DP_value) >= int(args.threshold) :
					if GT_value in genotypes:
						if int(REF_value) != 0 or int(ALT_value) != 0:    #menghao 20180117
							args.output.write(line)
							more+=1
				else :
					less +=1
	args.stat.write('Sample\tNumber\n')
	args.stat.write('Qualified\t'+str(more)+'\n')
	args.stat.write('unQualified\t'+str(less)+'\n')
	args.stat.write('Total\t'+str(total)+'\n')


if __name__ == '__main__':
	main()
	times=(time.clock()-start)
	print('\nTime Used: '+str(times)+' seconds\n')

