#! /usr/bin/env python3
import argparse
import time
import sys
import re
import os
import json
import glob
import logging
import pandas as pd
from collections import OrderedDict
bindir = os.path.abspath(os.path.dirname(__file__))

__author__ = 'Liu Huiling'
__mail__ = 'huilingliu@genome.cn'
__doc__ = 'the description of program'

'''
将tab分隔的文本文件转换为js格式
读取数据时第一行和第一列都认为是数据，不作为header和index
通过 -t 参数可以设置表格文件转置行列后再转换js
'''
pat1=re.compile('^s+$')

def tb2js(infile,outfile,trans,label):
	df = pd.read_table(infile,header=None, index_col=None, low_memory=False)
	if trans:
		dict = df.T.to_dict(orient='split')
	else :
		dict = df.to_dict(orient='split')
	result = OrderedDict()
	result['title'] = dict['data'][0]
	dict['data'].remove(dict['data'][0])
	title_list = [df.index.name]
	
	result['label'] = label
	result['data'] = dict['data']
	

	json.dump(result, skipkeys=True, ensure_ascii=False, indent=4, fp= open(outfile,'w'))

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument('-i','--input',help='input file',dest='input',required=True)
	parser.add_argument('-t','--trans',help='transpose the input data', action='store_true', dest='trans')
	args=parser.parse_args()
	logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s")
	Clinical_pathogenic = ['location:5', 'MAF_1000g:13', 'MAF_EXAC:14']
	with open(args.input, 'r') as input:
		for line in input:
			if not line.startswith('JsTable'):continue
			file_str = line.split(',')[0].replace('JsTable:','').replace('.json','')
			file_list = glob.glob(os.path.dirname(args.input)+'/'+file_str)
			if not file_list:
				logging.error('{0} 文件不存在'.format(file_str))
				sys.exit(1)
			for file in file_list:
				if 'Clinical_pathogenic' in file:
					tb2js(file,file+'.json',args.trans,Clinical_pathogenic)
				else:
					tb2js(file,file+'.json',args.trans,[])
				#break #动态报告支持多个json文件时，注释掉此行！！！

if __name__ == '__main__':
	main()
