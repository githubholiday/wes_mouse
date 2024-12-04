#! /usr/bin/env pythoni2.7
import argparse
import sys
import os
import re
import pysam
import pprint

__author__='Liu Tao'
__mail__= 'taoliu@annoroad.com'

pat1=re.compile('^\s+$')
pat2=re.compile('^chr',re.I)
samtools = '/annoroad/bioinfo/PMO/share/software/samtools-0.1.19/samtools'

def bam_reader(bam):
	'''
	return a dict 
	dict -> chr -> position = depth
	'''
	r_dict={}
	print(bam)
	samfile = pysam.Samfile(bam,'rb')
	for chr in samfile.references:
		nchr = chr
		if not pat2.search(chr) : nchr = 'chr'+chr
		if not nchr in r_dict:
			r_dict[nchr]={}
		for read in samfile.fetch(chr):
			for pos in read.positions:
				if not pos in r_dict[nchr]:
					r_dict[nchr][pos] = 0
				r_dict[nchr][pos] += 1
	return r_dict

def mapping_rate(bams,f_output):
	r_dict={}
	mapped_reads,unmapped_reads,total_reads,mapped_multi_reads=0,0,0,0
	names = {}
	for bam in bams:
		print(bam)
		samfile = pysam.Samfile(bam,'rb')
		for read in samfile.fetch():
			if read.is_unmapped:continue
			qname=read.qname
			if read.is_read1:
				qname += '_1'
			elif read.is_read2:
				qname += '_2'
			if not qname in names:
				names[qname] = 1
			else:
				names[qname] += 1
		unmapped_reads += samfile.unmapped

	mapped_reads += len(names.keys())
	total_reads += len(names.keys()) + unmapped_reads
	for i in names :
		if names[i] > 1:mapped_multi_reads += 1
	f_output.write("\t".join(['Total Reads','Mapped Reads','Mapping Rate','UnMapped Reads','MultiMap Reads','MultiMap Rate'])+"\n")
	f_output.write("\t".join([str(i) for i in [total_reads,mapped_reads,mapped_reads/total_reads,unmapped_reads,mapped_multi_reads,mapped_multi_reads/total_reads]])+"\n")

def output_align_position(bam):
	r_dict={}
	print(bam)
	samfile = pysam.Samfile(bam,'rb')
	#ref = samfile.references
	all_contigs = os.popen('{0} view -F 4 {1} | cut -f3 |uniq '.format(samtools,bam)).readlines()
	for chr in all_contigs:
		chr = chr.rstrip()
		#print(chr)
		for read in samfile.fetch(chr):
			if read.is_proper_pair:
				if read.is_reverse != read.mate_is_reverse:
					start = read.pos+1
					end = read.aend
					qname = read.qname
				#	print(qname)
					seq = read.seq
					if qname in r_dict:
						r_dict[qname]['region'].append([start,end,seq.decode()])
					else :
						r_dict[qname]={'chr':chr,'region':[[start,end,seq.decode()]]}
				else:
					print(read.qname)
	return r_dict

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',required=True,nargs='+')
	parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
	args=parser.parse_args()
	
	mapping_rate(args.input,args.output)
	#tt = bam_reader(args.input)
	#pprint.pprint(tt)

if __name__ == '__main__':
	main()
