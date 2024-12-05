bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software
configd=$(bindir)/config/
ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

HELP:
	@echo Description:
	@echo 报告中多样品统计图表生成
	@echo Usage:
	@echo make -f $(name) indir= outdir= STAT

SNP:
	mkdir -p $(outdir)
	#SNP Num
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.SNP.count.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.snp.num.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.snp.num.xls $(outdir) 1,2 'Number of SNP' All.snp.num stack n '' ''
	-convert $(outdir)/All.snp.num.pdf $(outdir)/All.snp.num.png || echo ok

	#SNP Genome
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.SNP.genome.region.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.snp.genome.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.snp.genome.xls $(outdir) 1,2,3,4,5,6,7,8,9,10,11 'Percentage of SNP(%)' All.snp.genome stack p '' ''
	-convert $(outdir)/All.snp.genome.pdf $(outdir)/All.snp.genome.png || echo ok

	#SNP Exonic
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.SNP.ExonicFunc.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.snp.exonic.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.snp.exonic.xls $(outdir) 1,2,3,4,5,6 'Percentage of SNP in exon(%)' All.snp.exonic stack p '' ''
	-convert $(outdir)/All.snp.exonic.pdf $(outdir)/All.snp.exonic.png || echo ok

	#SNP Mut Pattern
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.SNP.mutation.pattern.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.snp.pattern.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.snp.pattern.xls $(outdir) 1,2,3,4,5,6,7 'Percentage of SNP Mutations(%)' All.snp.pattern stack p '' ''
	-convert $(outdir)/All.snp.pattern.pdf $(outdir)/All.snp.pattern.png || echo ok

INDEL:
	mkdir -p $(outdir)
	#INDEL Num
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.INDEL.count.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.indel.num.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.indel.num.xls $(outdir) 1,2 'Number of InDel' All.indel.num stack n '' ''
	-convert $(outdir)/All.indel.num.pdf $(outdir)/All.indel.num.png || echo ok

	#INDEL Genome
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.INDEL.genome.region.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.indel.genome.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.indel.genome.xls $(outdir) 1,2,3,4,5,6,7,8,9,10,11 'Percentage of InDel(%)' All.indel.genome stack p '' ''
	-convert $(outdir)/All.indel.genome.pdf $(outdir)/All.indel.genome.png || echo ok

	#INDEL Exonic
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SNP_INDEL_ANNO/Result/Stat/*.INDEL.ExonicFunc.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.indel.exonic.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.indel.exonic.xls $(outdir) 1,2,3,4,5,6,7,8 'Percentage of InDel in exon(%)' All.indel.exonic stack p '' ''
	-convert $(outdir)/All.indel.exonic.pdf $(outdir)/All.indel.exonic.png || echo ok

SV:
	mkdir -p $(outdir)
	#SV Num
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SV_ANNO/Result/Stat/*.SV.num.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.sv.num.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.sv.num.xls $(outdir) 1,2 'Number of SV' All.sv.num stack n '' ''
	-convert $(outdir)/All.sv.num.pdf $(outdir)/All.sv.num.png || echo ok

	#SV Genome
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SV_ANNO/Result/Stat/*.SV.genome.region.stat.picture.list |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.sv.genome.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.sv.genome.xls $(outdir) 1,2,3,4,5,6,7,8,9,10,11 'Percentage of SV(%)' All.sv.genome stack p '' ''
	-convert $(outdir)/All.sv.genome.pdf $(outdir)/All.sv.genome.png || echo ok

	#SV Type
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/SV_ANNO/Result/Stat/*.SV.type.stat.picture.list |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.sv.type.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.sv.type.xls $(outdir) 1,2,3,4,5,6 'Percentage of SV Type(%)' All.sv.type stack p '' ''
	-convert $(outdir)/All.sv.type.pdf $(outdir)/All.sv.type.png || echo ok

Fusion:
	mkdir -p $(outdir)
	#Fugene Num
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/FusionGene/*.FuGene.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.Fugene.num.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.Fugene.num.xls $(outdir) 1,2 'Number of FusionGene' All.Fugene.num stack n '' ''
	-convert $(outdir)/All.Fugene.num.pdf $(outdir)/All.Fugene.num.png || echo ok

CNV:
	mkdir -p $(outdir)
	#CNV Num
	-$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/CNV/*/*.CNV.stat.txt |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.cnv.num.xls
	-$(Rscript) $(script)/barplot.r $(outdir)/All.cnv.num.xls $(outdir) 1,2,4,6,8 'Number of CNV' All.cnv.num stack n '' ''
	-convert $(outdir)/All.cnv.num.pdf $(outdir)/All.cnv.num.png || echo ok

STAT:SNP INDEL SV

.PHONY:QC
QC:
	@echo "############ QC start "`date`
	mkdir -p $(outdir)/QC
	head -1 $(indir)/Stat/All.map.stat.xls |sed 's/\t/\n/g' |sed '1d' >$(outdir)/QC/sample.list
	if [ -e $(indir)/FQ/STAT_result.xls ];then \
		$(PYTHON3) $(script)/QC/qc.py -i $(indir)  -t $(script)/QC/config/$(type).Monogenic_template.xls -s $(outdir)/QC/sample.list -n $(script)/QC/config/filter.list -p $(project_id) -o $(outdir)/QC/Filter  -e no -m ~/.email/.email.txt -d $(outdir)/QC ;\
	else \
		echo "There is no filter stat file" ;\
	fi
	$(PYTHON3) $(script)/QC/qc.py -i $(indir)  -t $(script)/QC/config/$(type).Monogenic_template.xls -s $(outdir)/QC/sample.list -n $(script)/QC/config/$(type).map.list -p $(project_id) -o $(outdir)/QC/MAP  -e no -m ~/.email/.email.txt -d $(outdir)/QC
	$(PYTHON3) $(script)/QC/qc.py -i $(indir) -t $(script)/QC/config/$(type).Monogenic_template.xls -s 0 -n $(script)/QC/config/$(type).check.list -p $(project_id) -pn $(project_name) -o $(outdir)/QC/Total  -e yes -m $(script)/QC/config/check.email.txt -d $(outdir)/QC -f --check
	@echo "############ QC end "`date`
