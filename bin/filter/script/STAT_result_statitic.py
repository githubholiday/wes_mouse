#!/usr/bin/env python3
######################################################################### import ##########################################################
import argparse
import os
import sys
import logging
#import re
#import time
#import pandas as pd
######################################################################### ___  ##########################################################
__author__ = 'Linwenwen'
__mail__ = 'wenwenlin@genome.cn'
__date__ = '2018年04月12日 星期日 14时13分16秒'
__version__ = 'beta2.1'
__use__="本脚本用于汇总指定样品的过滤信息 beta2.1"
__doc__='本脚本会抓取输入目录下的 STAT_result.xls 文件，并根据给定的样品信息查询该样品在给定路径文件的 Raw Reads Number,Raw Bases Number,Clean Reads Number,Clean Reads Rate(%),Clean Bases Number,Low-quality Reads Number,Low-quality Reads Rate(%),Ns Reads Number,Ns Reads Rate(%),Adapter Polluted Reads Number,Adapter Polluted Reads Rate(%),Raw Q30 Bases Rate(%),Clean Q30 Bases Rate(%)，汇总后输出至指定文件中。对于找不到的信息会直接跳过，若查到重复的样品信息会报错退出。\n\n版本升级信息：\n\n20180522-林文文-beta2.0：\n1.当样品信息表内无有效样品名（如空文件）或输入路径无有效路径（如给定输入路径下均无STAT_result.xls文件），会给出警告信息，但脚本会继续执行；\n2.现在在输入文件中发现重复的样本数据后会选择Clean Bases Rate(%)更高的数据,而不再会报错退出了；\n3.移除了重复输入路径检查功能；\n4.现在输出文件中，qc指标会按照固定顺序输出了，第一行的样品顺序也会按照给定的样品信息表顺序输出了；\n5.对于能找到相关样品数据但缺失部分qc指标信息的，会以 "-" 的形式输出\n\n20180528-林文文-beta2.1：\n1.规定样品信息表第一列为匹配样本名称，第二列为输出样本名称，现在匹配过程会使用匹配样本名称，以其对应的输出名称输出，如果有重复的匹配名称，或重复的输出样本名称，那么会直接跳过该样本。\n\n20180612-林文文-beta2.2：\n1.遇到同一样本的数据时，会选择Clean Reads Number更高的数据，而不是原来的Clean Bases Rate(%)了\n'
######################################################################### main  ##########################################################

class check():
	def __init__(self,file):
		self.file=file
		self.tf=os.path.exists(file)
	def ch_in(self):
		if not self.tf:
			logging.error(' {} 文件或目录不存在'.format(self.file))
			sys.exit(1)
	def ch_out(self,f):
		if self.tf:
			if not f:
				logging.error(' {} 已存在，输入 -f 强制执行'.format(self.file))
				sys.exit(1)
			else: logging.warning(' {} 已存在，将覆盖该文件'.format(self.file))
	def ch_warning(self):
		if not self.tf:
			logging.warning(' {} 不存在，将跳过该文件或目录'.format(self.file))
		return self.tf

def getsample(file):#sample必须位于第二列
	samplelist=[]
	i0_rmdu=[]
	i1_rmdu=[]
	with open(file) as f:
		for i in f:
			i=i.strip().split('\t')
			try:	
				i0=i[0].strip()
				i1=i[1].strip()
			except: continue
			if i0 not in i0_rmdu and i1 not in i1_rmdu:
				i0_rmdu.append(i0)
				i1_rmdu.append(i1)
				samplelist.append([i[0].strip(),i[1].strip()])
			else:logging.warning('发现并跳过重复样品名称: {0}\t{1}'.format(i0,i1))
	if samplelist==[]:
		logging.warning("无有效样品名")
		#sys.exit(1)
	return samplelist

class getdata():
	def __init__(self,indir,qc):
		self.file=indir
		self.qc_dict={}
		for i in qc:
			self.qc_dict[i]="-"
		self.tf=check(self.file).ch_warning()
	def fread(self,samplelist,pd):#snp位点不能重复
		f=open(self.file)
		try: sample=f.readline().strip().split('\t')[1:]
		except: 
			logging.error('{} 文件缺失有效的样品名'.format(self.file))
			return
		ff=[i.strip().split('\t') for i in f]
		for i in range(len(sample)):
			if sample[i] not in samplelist:continue
			for ii in ff:
				if ii[0] in self.qc_dict.keys():
					self.qc_dict[ii[0]]=ii[i+1]
			pd.data_add(self.qc_dict,sample[i])
		f.close()
			
class push_data():
	def __init__(self,file,qc,samplelist):
		self.f=open(file,"w")
		self.data_dict={i:[] for i in qc}
		self.qc=qc
		self.sample_dict={i[0]:-1 for i in samplelist}
		self.samplelist=samplelist
	def data_add(self,qc_dict,sample):
		position=self.sample_dict[sample]
		if position==-1:
			for i in qc_dict.keys():
				self.data_dict[i].append(qc_dict[i])
			self.sample_dict[sample]=max(self.sample_dict.values())+1
		else:
			logging.warning('样本{}存在重复数据'.format(sample))
			c1=int(self.data_dict['Clean Reads Number'][position].replace(',',''))
			c2=int(qc_dict['Clean Reads Number'].replace(',',''))
			if c1<c2:
				for i in qc_dict.keys():
					self.data_dict[i][position]=qc_dict[i]
	def fwrite(self):
		self.f.write("sample")
		samplelist=[]
		for i in self.samplelist:
			if self.sample_dict[i[0]]==-1:
				print('未找到关于{}的信息'.format(i[0]))
			else:
				samplelist.append(self.sample_dict[i[0]])
				self.f.write('\t'+i[1])
		self.f.write('\n')
		for i in self.qc:
			self.f.write(i+'\t')
			data=[self.data_dict[i][ii] for ii in samplelist]
			data='\t'.join(data)
			self.f.write(data+'\n')
	def fclose(self):
		self.f.close()

def main():
	parser=argparse.ArgumentParser(usage=__use__,description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author: {0}\nmail: {1}\ndate: {2}\nversion: {3}'.format(__author__,__mail__,__date__,__version__))
	parser.add_argument('-i','--indir',help='输入目录 -i /***/***/,/***/***/ ，该目录下应包含 STAT_result.xls 文件，单个目录中不要包含英文逗号，多个目录请用逗号英文隔开',dest='in_dir',type=str,required=True)
	parser.add_argument('-o','--output',help='输出文件 -o /***/***/*** ，将会把整理的结果输出至此。默认为 STAT_result.xls',dest='out_file',type=str,default='STAT_result.xls')
	parser.add_argument('-f','--force',help='如果输出文件存在，使用该参数可将新的输出文件覆盖原来的文件',dest='force',action='store_true')
	parser.add_argument('-s','--sample',help='样品信息表 -s /***/***/*** ，匹配第一列，输出第二列',dest='samplelist',type=str,required=True)
	args=parser.parse_args()
	#qc=["Raw Reads Number","Raw Bases Number","Clean Reads Number","Clean Reads Rate(%)","Clean Bases Number","Low-quality Reads Number","Low-quality Reads Rate(%)","Ns Reads Number","Ns Reads Rate(%)","Adapter Polluted Reads Number","Adapter Polluted Reads Rate(%)","Raw Q30 Bases Rate(%)","Clean Q30 Bases Rate(%)"]
	qc=["Raw Reads Number","Raw Bases Number","Clean Reads Number","Clean Reads Rate(%)","Clean Bases Number","Low-quality Reads Number","Low-quality Reads Rate(%)","Ns Reads Number","Ns Reads Rate(%)","Adapter Polluted Reads Number","Adapter Polluted Reads Rate(%)","Raw Q30 Bases Rate(%)","Clean Q30 Bases Rate(%)","Raw GC percent(%)","Clean GC percent(%)"]

	#in_dir="/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/QC/Common/Analysis/Analysis/lunan/Project_PM-BJ170733-04/Analysis_2_180312_A00358_0047_BH5K5LDMXX,/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/QC/Common/Analysis/Analysis/lengxue/Project_PM-BJ170733-06/Analysis_1_180312_A00358_0047_BH5K5LDMXX,/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/QC/Common/Analysis/Analysis/lengxue/Project_PM-BJ170733-05/Analysis_1_180312_A00358_0047_BH5K5LDMXX"
	#out_file="STAT_result.xls"
	#samplelist_file="test_data/samli"

	in_dir=args.in_dir
	out_file=args.out_file
	force=args.force
	samplelist_file=args.samplelist

	in_dir=in_dir.split(",")
	in_files=[i.strip()+'/STAT_result.xls' for i in in_dir]
	infiles=[]
	for i in in_files:
		if check(i).ch_warning(): infiles.append(i)
	"""
	for i in in_files:
		if i not in infiles: 
			if check(i).ch_warning():infiles.append(i)
		else: logging.warning('发现并删除重复路径 {}'.format(i))
	if infiles==[]:
		logging.warning("无有效输入路径")
		#sys.exit(1)
	"""
	check(samplelist_file).ch_in()
	check(out_file).ch_out(force)

	samplelist=getsample(samplelist_file)

	pd=push_data(out_file,qc,samplelist)
	for i in infiles:
		gd=getdata(i,qc)
		gd.fread([ii[0] for ii in samplelist],pd)
		#pd.ddict(qc_dict)
	pd.fwrite()
	pd.fclose()

if __name__=="__main__":
	#print('Start: ',time.ctime())
	main()
	#print('End: ',time.ctime())
