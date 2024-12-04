'''
生成动态报告的链接
'''
import os
import sys
import argparse
import logging
import base64

__author__ = 'suyanxun'
__mail__ = 'yanxunsu@genome.cn'

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:	{0}	mail:	{1}'.format(__author__,__mail__))
	parser.add_argument('-p','--project',help='子项目编号',dest='project_id',required=True)
	parser.add_argument('-o','--outfile',help='输出文件',dest='outfile',required=True)
	args = parser.parse_args()
	logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s")
	line = 'http://ngsreport.solargenomics.com/report/reportInterface/getReport.html?projectCode='
	with open(args.outfile,'w') as out:
		out.write( line + base64.b64encode(args.project_id.encode('utf-8')).decode('utf-8')+'\n' )
	

if __name__=="__main__":
	main()
