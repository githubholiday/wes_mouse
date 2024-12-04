#!/usr/bin/env python3
import argparse
import sys
import os
import re

bindir = os.path.abspath(os.path.dirname(__file__))
__author__='yangyumei'
__mail__= 'yumeiyang@annoroad.com'


pat1=re.compile('^s+$')

class mybed():
	def __init__(self,chr,start,end,flank):
		self.chr=chr
		self.start=start
		self.end=end
		self.flank=[]
	def getflank(self,flank):
		fk1=[str(int(self.start)-int(flank)),self.start]
		fk2=[self.end,str(int(self.end)+int(flank))]
		return [fk1,fk2]
		
	def output(self,out,f):
		for o in f :
			out.write(self.chr+'\t'+'\t'.join(o)+'\n')
	def getregionlength(self):
		leng=str(int(self.end)-int(self.start))
		return leng

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--inbed',help='input bed file',dest='inbed',required=True,type=open)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True,type=argparse.FileType('w'))
	parser.add_argument('-l','--outlen',help='output length file',dest='outlen',type=argparse.FileType('w'))
	parser.add_argument('-f','--flank',help='flank length',dest='flank',required=True,default=100)
	parser.add_argument('-b','--bin',help='bindir',dest='bin',default='{0}'.format(os.path.dirname(bindir)))
	args=parser.parse_args()
	totallen=0
	flanklen=0
	for line in args.inbed: 
		if line.startswith('#') or re.search(pat1,line):continue
		tmp=line.rstrip().split('\t')
		bed=mybed(tmp[0],tmp[1],tmp[2],args.flank)
		flanks=bed.getflank(args.flank)
		flanklen+=int(args.flank)*2
		bed.output(args.output,flanks)
		ll=bed.getregionlength()
		#args.outlen.write(ll+'\n')
		totallen+=int(ll)
	print(str(totallen)+'\n')
	print(str(flanklen)+'\n')
	
	


if __name__ == '__main__':
	main()



