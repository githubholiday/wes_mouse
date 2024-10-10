#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
Created on 20190709

程序功能:
用于cytoBand注释准备文件，标准化输入文件*.SV.pass.vcf，原一行信息，标准化后使start为一行，end为一行

程序参数:
-vcf --vcf：  输入原始用于SV注释的vcf文件
-o --output： 输出标准化后的vcf文件
使用方法：
python3 format_sv_vcf.py -vcf *.SV.pass.vcf -o *.SV.pass.vcf.format

'''

import os
import sys
import re
import argparse

__author__='陈鹏燕'
__mail__='pengyanchen@genome.cn'
__version__= 'v1.0.0'

def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument('-vcf','--vcf',help='pass.vcf file',dest='vcf',required=True,type=open)
	parser.add_argument('-o','--output',help='out file',dest='output',required=True,type=argparse.FileType('w'))
	args=parser.parse_args()

	for line in args.vcf:
		if line.startswith('#'):
			args.output.write(line)
		else:
			tmp = line.strip().split("\t")
			description = tmp[7]
			groups=re.findall(r";END=([^(;)?]*)",tmp[7])
			endpos=''.join(groups)
			startpos = tmp[1]
			new_tmp7 = tmp[7].replace(endpos,startpos)
			info_b7 = '\t'.join(tmp[0:7])
			info_a8 = '\t'.join(tmp[8:])
			info_a2 = '\t'.join(tmp[2:])
			newline = info_b7+'\t'+new_tmp7+'\t'+info_a8+'\n'+tmp[0]+'\t'+endpos+'\t'+info_a2+'\n'
			args.output.write(newline)

if __name__=="__main__":
	main()
