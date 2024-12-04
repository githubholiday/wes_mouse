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
	parser.add_argument('-p','--perl',help='perl dir ',dest='perl',type=str,default="/annoroad/share/software/install/perl-5.16.2/bin/perl")	
	args=parser.parse_args()
	
	filter =args.indir.split(",")[0]
	if not os.path.exists(filter):
		print("The first filter dir {0} did not exist".format(filter))
		exit(1)
	if not os.path.exists(args.samplelist):
		print("The samplelist did not exist")
		sys.exit()
		
	# 清除结果目录，以便产生新的结果
	outdir=os.path.join(args.outdir,"Cleandata")
	if os.path.exists(outdir):
		os.system("rm -r {0}".format(outdir))
	os.system("mkdir -p {0}".format(outdir))	
	
	a=open(args.samplelist,"r")
	for line in a:
		if line.startswith('#') or pat1.search(line):continue
		else:
			bms,info = line.split("\t")[0:2]
			if not os.path.exists('{0}/Analysis/{1}'.format(filter,bms)):
				logging.warning("{0} is not in the first filter analysis: {1}/Analysis".format(info,filter))
				continue
			os.system('mkdir -p {0}/{1}'.format(outdir, info))
			if bms == info:
				link_figure(filter, outdir, bms)
			else:
				cmd=('{0} {1}/draw_base_quality_distirbution.pl --r1 {2}/Analysis/{3}/filter/clean/{3}_R1.fq.gz.report --r2 {2}/Analysis/{3}/filter/clean/{3}_R2.fq.gz.report --prefix {4}/{5}/{5} --sample {5}'.format(args.perl, bin, filter, bms, outdir, info))
				print(cmd)
				subprocess.call(cmd, shell=True)
				os.system('convert {0}/{1}/{1}.base.pdf {0}/{1}/{1}.base.png'.format(outdir,info))
				os.system('convert {0}/{1}/{1}.quality.pdf {0}/{1}/{1}.quality.png'.format(outdir,info))			
	a.close()
	if os.path.exists('{0}/STAT_result.xls'.format(filter)):
		if os.path.exists('{0}/STAT_result.xls'.format(args.outdir)):
			os.system('rm -r {0}/STAT_result.xls'.format(args.outdir))
		os.system('cp -rf {0}/STAT_result.xls {1}/STAT_result.xls'.format(filter, args.outdir))		
	else:
		logging.error("{0} has no STAT_result.xls".format(filter))
		sys.exit(1)
		
	
	
if __name__=="__main__": 
	main()

