#! /usr/bin/env python3
"""
To combine alignment stat file 

"""
import argparse
import os
import sys
import re
import subprocess
import logging

bin = os.path.abspath(os.path.dirname(__file__))
sys.path.append(bin + '/lib')
pat1=re.compile('^\S*$')

import warnings
#warnings.filterwarnings("ignore")

__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '20170911'

def link_figure(filter, outdir, sample):
	os.system("ln -s {0}/Analysis/{1}/filter/clean/{1}.base.png {2}/{1}/{1}.base.png".format(filter, sample, outdir))
	os.system("ln -s {0}/Analysis/{1}/filter/clean/{1}.base.pdf {2}/{1}/{1}.base.pdf".format(filter, sample, outdir))
	os.system("ln -s {0}/Analysis/{1}/filter/clean/{1}.quality.pdf {2}/{1}/{1}.quality.pdf".format(filter, sample, outdir))
	os.system("ln -s {0}/Analysis/{1}/filter/clean/{1}.quality.png {2}/{1}/{1}.quality.png".format(filter, sample, outdir))
	os.system("ln -s {0}/Analysis/{1}/filter/clean/{1}.quality.png {2}/{1}/{1}.quality.png".format(filter, sample, outdir))

def cp_figure(filter, outdir, sample):
	os.system("cp -rf {0}/Analysis/{1}/filter/clean/{1}.base.png {2}/{1}/{1}.base.png".format(filter, sample, outdir))
	os.system("cp -rf {0}/Analysis/{1}/filter/clean/{1}.base.pdf {2}/{1}/{1}.base.pdf".format(filter, sample, outdir))
	os.system("cp -fr {0}/Analysis/{1}/filter/clean/{1}.quality.pdf {2}/{1}/{1}.quality.pdf".format(filter, sample, outdir))
	os.system("cp -fr {0}/Analysis/{1}/filter/clean/{1}.quality.png {2}/{1}/{1}.quality.png".format(filter, sample, outdir))
	os.system("cp -fr {0}/Analysis/{1}/filter/clean/{1}.quality.png {2}/{1}/{1}.quality.png".format(filter, sample, outdir))
def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-i','--indir',help='Filter dir split by , and the first is major',dest='indir',type=str,required=True)
	parser.add_argument('-s','--samplelist',help='pipeline type',dest='samplelist',type=str,required=True)   
	parser.add_argument('-o','--outdir',help='Cleandata',dest='outdir',type=str,required=True) 
	parser.add_argument('-r','--rscript',help='rscript dir ',dest='rscript',type=str,default="/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/renxue/install/miniconda3/envs/ap_resequence/bin/Rscript")	
	parser.add_argument('-p','--perl',help='perl dir ',dest='perl',type=str,default="/usr/bin/perl")	
	args=parser.parse_args()
	
	filter_all =args.indir.split(",")
	for filter in filter_all:
		if not os.path.exists(filter):
			print("The first filter dir {0} did not exist".format(filter))
			exit(1)
	
	if not os.path.exists(args.samplelist):
		print("The samplelist did not exist")
		sys.exit()
		
	# 清除结果目录，以便产生新的结果
	outdir=args.outdir
	if os.path.exists(outdir):
		os.system("rm -r {0}".format(outdir))
	os.system("mkdir -p {0}".format(outdir))	
	
	a=open(args.samplelist,"r")
	for line in a:
		if line.startswith('#') or pat1.search(line):continue
		else:
			bms,info = line.split("\t")[0:2]
			tag=0
			for filter in filter_all:
				if not os.path.exists('{0}/Analysis/{1}'.format(filter,bms)):
					#logging.warning("{0} is not in the first filter analysis: {1}/Analysis".format(info,filter))
					continue
				else:
					os.system('mkdir -p {0}/{1}'.format(outdir, info))
					if bms == info:
						cp_figure(filter, outdir, bms)
					else:
						cmd=('{0} {1}/draw_base_quality_distirbution.pl --r1 {2}/Analysis/{3}/filter/clean/{3}_R1.fq.gz.report --r2 {2}/Analysis/{3}/filter/clean/{3}_R2.fq.gz.report --prefix {4}/{5}/{5} --sample {5} --rscript {6}'.format(args.perl, bin, filter, bms, outdir, info, args.rscript))
						print(cmd)
						subprocess.call(cmd, shell=True)
						os.system('convert {0}/{1}/{1}.base.pdf {0}/{1}/{1}.base.png'.format(outdir,info))
						os.system('convert {0}/{1}/{1}.quality.pdf {0}/{1}/{1}.quality.png'.format(outdir,info))			
					tag=1
					break
			if tag==0:
				logging.warning("{0} is not in the first filter analysis".format(info))
				continue
	a.close()
	
	
if __name__=="__main__": 
	main()

