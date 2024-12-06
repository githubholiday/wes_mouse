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
	parser.add_argument('-i','--input',help='input file',dest='input',required=True,nargs='+')
	parser.add_argument('-he','--head',help='if exists header for input file',dest='head',action='store_true')
	parser.add_argument('-b','--bin',help='bindir',dest='bin',default='{0}'.format(os.path.dirname(bindir)))
	args=parser.parse_args()
	
	for file in args.input :
		f=open(file)
		out=open(file+'.tmp','w')
		for index,line in enumerate(f):
			if index == 0 :
				if args.head :
					out.write(line)
					continue
			tmp=line.rstrip().split('\t')
			#print(tmp[0])
			ii=tmp[0].find('(')
			if ii != '-1' :
				out.write(tmp[0][0:ii]+'\t'+'\t'.join(tmp[1:])+'\n')
			else :
				out.write(line)
		f.close()
		out.close()
	
	
	





if __name__ == '__main__':
	main()



