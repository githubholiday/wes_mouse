#!/usr/bin/env python3
import argparse
import sys
import os
import re

bindir = os.path.abspath(os.path.dirname(__file__))
__author__='yangyumei'
__mail__= 'yumeiyang@annoroad.com'


pat1=re.compile('^s+$')

def read_vcf(vcfs,out):
	for file in vcfs :
		svtype=''
		chr2=''
		end=''
		lenth=0
		inslen=0
		f_file=open(file)
		for line in f_file :
			if line.startswith('#') or re.search(pat1,line) :continue
			chr1,start,id,ref,alt,qual,filter,infos,*a=line.rstrip().split('\t')
			if filter == 'LowQual' :continue
			for info in infos.split(';') :
				if info.startswith('SVTYPE'):
					svtype=info.split('=')[1]
				if info.startswith('CHR2'):
					chr2=info.split('=')[1]
				if info.startswith('END') :
					end=info.split('=')[1]
				if info.startswith('INSLEN') :
					inslen=int(info.split('=')[1])
			if chr1==chr2 :
				#print(chr1)
				#print(start,id,ref,alt,qual,filter,infos)
				#if svtype == 'DUP' or svtype == 'DEL' or svtype == 'INV' or svtype == 'INS' :
				lenth=abs(int(end)-int(start))
				if svtype == 'INS' :
					lenth=inslen
				out.write(chr1+'\t'+str(start)+'\t'+str(end)+'\t'+str(0)+'\t'+str(0)+'\t'+str(svtype)+'\t'+str(lenth)+'\n')
				#else :
				#	print(chr1+'-'+chr2+':'+start+' '+svtype+'not not in the same chr')
				#	out.write(chr1+'\t'+str(start)+'\t'+str(start)+'\t'+str(ref)+'\t'+str(0)+'\t'+str(svtype)+'\t'+str(lenth)+'\n')
				#	out.write(chr1+'\t'+str(end)+'\t'+str(end)+'\t'+str(ref)+'\t'+str(0)+'\t'+str(svtype)+'\t'+str(lenth)+'\n')
			else :
				print(chr1+'-'+chr2+':'+start+' '+svtype+'not not in the same chr')
				out.write(chr1+'\t'+str(start)+'\t'+str(start)+'\t'+str(0)+'\t'+str(0)+'\t'+str(svtype)+'\t'+str(0)+'\n')
				out.write(chr2+'\t'+str(end)+'\t'+str(end)+'\t'+str(0)+'\t'+str(0)+'\t'+str(svtype)+'\t'+str(0)+'\n')


	f_file.close()

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input delly2 vcf  file',dest='input',required=True,nargs='+')
	parser.add_argument('-o','--output',help='output file',dest='output',required=True,type=argparse.FileType('w'))
	parser.add_argument('-b','--bin',help='bindir',dest='bin',default='{0}'.format(os.path.dirname(bindir)))
	args=parser.parse_args()
	
	read_vcf(args.input,args.output)
	
	
	


	



if __name__ == '__main__':
	main()



