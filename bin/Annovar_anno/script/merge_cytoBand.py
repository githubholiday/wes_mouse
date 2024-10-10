#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
Created on 20190709

程序功能:
用于cytoBand注释结果整合，替换原cytoBand注释信息，得到准确的注释结果

程序参数:
-cyto --cytofile：  输入cytoBand注释结果文件
-anno ---anno       输入原始用于SV注释结果文件
-o --output：       输出整合cytoBand注释结果后的注释文件
使用方法：
python3 merge_cytoBand.py -cyto *SV.hg19.cytoBand.hg19_multianno.txt -anno *SV.hg19.raw.hg19_multianno.txt -o *SV.hg19.hg19_multianno.txt

'''
import os
import sys
import re
import argparse

__author__='陈鹏燕'
__mail__='pengyanchen@genome.cn'
__version__= 'v1.0.0'

def Read_cytoband(file):
	dict={}
	for line in file:
		tmp=line.strip().split('\t')
		if tmp[1]==tmp[2]:
			pos='\t'.join(tmp[0:2])
		else:
			pos='\t'.join(tmp[0:3])
		cyto_anno=tmp[5]
		dict[pos]=cyto_anno
	return(dict)


def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument('-cyto','--cyto_anno',help='cytoBand anno file',dest='cytofile',required=True,type=open)
	parser.add_argument('-anno','--all_anno',help='all anno file',dest='anno',required=True,type=open)
	parser.add_argument('-o','--output',help='out file',dest='output',required=True,type=argparse.FileType('w'))
	args=parser.parse_args()

	dict=Read_cytoband(args.cytofile)
	for line in args.anno:
		if line.startswith('Chr\t'):
			args.output.write(line)
		else:
			tmp=line.strip().split('\t')
			idstart=tmp[0]+'\t'+tmp[1]
			idend=tmp[0]+'\t'+tmp[2]
			idregion='\t'.join(tmp[0:3])
			info_bef='\t'.join(tmp[0:121])
			info_end='\t'.join(tmp[122:])
			if idregion in dict.keys():
				cytoregion=dict[idregion]
				args.output.write("{0}\t{1}\t{2}\n".format(info_bef,cytoregion,info_end))
			else:
				cytostart=dict[idstart]
				cytoend=dict[idend]
				if cytostart == cytoend:
					args.output.write("{0}\t{1}\t{2}\n".format(info_bef,cytostart,info_end))
				else:
					cytopos=cytostart+'-'+cytoend
					args.output.write("{0}\t{1}\t{2}\n".format(info_bef,cytopos,info_end))

if __name__=="__main__":
	main()
