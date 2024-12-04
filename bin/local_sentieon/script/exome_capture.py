#!/usr/bin/env python3
import argparse
import sys
import os
import re
import bam_read
import pysam

bindir = os.path.abspath(os.path.dirname(__file__))
__author__='yangyumei'
__mail__= 'yumeiyang@annoroad.com'




pat1=re.compile('^s+$')
def mapping_stat(bams):
	r_dict={}
	mapped_bases,unmapped_bases,total_bases,mapped_multi_bases=0,0,0,0
	names = {}
	multinames = {}
	out=[]
	readlen=0
	for bam in bams:
		unmapp=0
		samfile = pysam.AlignmentFile(bam,'rb')
		for read in samfile.fetch():
			readlen=read.query_length
			if read.is_unmapped:
				unmapp+=1		
				continue
			qname=read.qname
			if read.is_read1:
				qname += '_1'
			elif read.is_read2:
				qname += '_2'
			if not qname in names:
				names[qname] = read.query_alignment_length
			else:
			#	names[qname] += read.query_alignment_length
				if not qname in multinames :
					multinames[qname] = names[qname] #如果qname再次出现，说明该read为multi reads
				elif (qname in multinames) and (multinames[qname] < read.query_alignment_length):
					multinames[qname] = read.query_alignment_length


		for qname in multinames:
			del names[qname]

		#unmapped_bases += (samfile.unmapped*read.query_length)
		#mapped_bases += sum(names.values())
		#total_bases += ((len(names.keys())+len(multinames.keys()))*readlen) + (unmapped_bases)
		#mapped_multi_bases += sum(multinames.values())
		mapped_reads = len(names.keys())+len(multinames.keys())
		out.append(mapped_reads)
	return out

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-bam','--bam',help='input bam file',dest='bam',required=True,nargs='+')
	parser.add_argument('-map','--map',help='input map file',dest='map',required=True,nargs='+')
	parser.add_argument('-o','--output',help='output file',dest='output',required=True,type=argparse.FileType('w'))
	args=parser.parse_args()
	total_map = 0
	
	mapped_reads=mapping_stat(args.bam)[0]

	with open(args.map[0],'r') as f:
		for line in f:
			line = line.strip("\n")
			if line.startswith("Mapped Reads"):
				total_map = line.split('\t')[1]
	
	capture_effiency = '%.2f'%(float(mapped_reads)/float(total_map)*100)
	args.output.write('{0}\t{1}\n'.format("Reads Mapped to Target Region",mapped_reads))
	args.output.write('{0}\t{1}\n'.format("Capture Specificity (%)",capture_effiency))
	args.output.close()
	


if __name__ == '__main__':
	main()



