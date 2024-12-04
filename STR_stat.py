#! /usr/bin/env python
'''
Description:
	this file is used to get overlap for 2 file, and output intercouse line
'''
import argparse
import sys
import os

__author__='Liu Tao'
__mail__='taoliu@annoroad.com'
def Overlap(dict1,dict2):
	out_dict={}
	for i in dict1:
		if i in dict2:
			#out_dict[i]="{0}\t{1}".format(dict1[i],dict2[i])
			out_dict[i]="{0}".format('\t'.join(dict2[i]))
	return out_dict

def store_record(id,record,args,count,line):
	tmp=line.split('\t')
	if not id in record:
		record[id]={}
	if args.col[count] == 'all':
		record[id][count] = line
	else:
		try:
			a_col = int(args.col[count])
			record[id][count] = tmp[a_col]
		except :
			print(args.col[count],'should be int')
			sys.exit()
	#return record

def main():
	parser=argparse.ArgumentParser(
			description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='Author:\t{0}\nE-mail:\t{1}\n'.format(__author__,__mail__)
			)
	parser.add_argument('-i','--infile',dest='infile',help='infile',required=True)
	parser.add_argument('-o','--outfile',dest='outfile',help='outfile')
	args=parser.parse_args()
	
	depth_dict = {}
	sample_list = []
	sample_dict = {}
	zero_depth_site = {"1":0, "2":0,"3":0,"4":0,"5":0,">5":0}
	with open(args.infile, 'r') as input, open(args.outfile, 'w') as output:
		for line in input:
			if line.starswith('chr'):
				tmp = line.rstrip().split('\t')
				sample_list = tmp[5:]
				for sample in tmp[5:]:
					value_index = sample_list.index(sample)
					sample_dict[value_index] = sample
					depth_dict[sample] = {"0":0,"0-100":0,">100":0}
				continue
			tmp = line.rstrip().split('\t')
			depth_list = [float(i) for i in tmp[5:]]
			zero_depth_sample_num = 0
			for d,d_index in enumerate(depth_list):
				sample = sample_dict[d_index]
				if d == float(0):
					zero_depth_sample_num += 1
					depth_dict[sample]['0']+=1
				if float(0) < d <= float(100):
					depth_dict[sample]['0-100']+=1
				else:
					depth_dict[sample]['>100']+=1
			
			if zero_depth_sample_num == 1 :
				zero_depth_site['1'] += 1
			if zero_depth_sample_num == 2 :
				zero_depth_site['2'] += 1
			if zero_depth_sample_num == 3 :
				zero_depth_site['3'] += 1
			if zero_depth_sample_num == 4 :
				zero_depth_site['4'] += 1
			if zero_depth_sample_num > 4 :
				zero_depth_site['>=5'] += 1
		for sample in depth_dict :
			value_list = [sample]
			for i in ["0","0-100",">100"]:
				value = depth_dict[sample][i]
				value_list.append(value)
			output.write('\t'.join(value_list)+'\n')
		for depth in zero_depth_site :
			print(depth , zero_depth_site[depth])
				
				

					
			

if __name__=='__main__':
	main()
