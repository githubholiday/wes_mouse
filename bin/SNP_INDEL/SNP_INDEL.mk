bindir=$(dir $(firstword $(MAKEFILE_LIST)))/../
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software

ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

ifeq ($(sex),XX)
	ifeq ($(genome),hg19)
		ref=$(REF_hg19_noY)
	else ifeq ($(genome),hg38)
		ref=$(REF_hg38_XX)
	endif
else ifeq ($(sex),XY)
	ifeq ($(genome),hg19)
		ref=$(REF_hg19)
	else ifeq ($(genome),hg38)
		ref=$(REF_hg38_XY)
	endif
endif

HELP:
	@echo Description:
	@echo 生成单个样本的SNP indel 的*.raw.vcf *.filter.vcf
	@echo Usage:
	@echo make -f $(tmpdir)/Saile_SNP_INDEL.mk bam= sample= outdir= ref= ploidy= SELECT Filter extract


SELECT:
	[ -d $(outdir)/$(sample).vcf ] && rm $(outdir)/$(sample).vcf || echo start analysis
	gunzip -c $(outdir)/$(sample).vcf.gz >$(outdir)/$(sample).vcf
	$(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -T SelectVariants -R $(ref) -V $(outdir)/$(sample).vcf.gz -o $(outdir)/$(sample).snp.raw.vcf -selectType SNP
	$(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -T SelectVariants -R $(ref) -V $(outdir)/$(sample).vcf.gz -o $(outdir)/$(sample).indel.raw.vcf -selectType INDEL

Filter:
	$(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -R $(ref) --variant $(outdir)/$(sample).snp.raw.vcf -o $(outdir)/$(sample).snp.filter.vcf $(snp_filter)
	$(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -R $(ref) --variant $(outdir)/$(sample).indel.raw.vcf -o $(outdir)/$(sample).indel.filter.vcf $(indel_filter)
	$(perl) -ne 'if(/^#/){print}else{@F=split(/\t/);print unless ($$F[6] ne "PASS")}' $(outdir)/$(sample).snp.filter.vcf >$(outdir)/$(sample).snp.filter.vcf.tmp
	mv $(outdir)/$(sample).snp.filter.vcf.tmp $(outdir)/$(sample).snp.filter.vcf
	$(perl) -ne 'if(/^#/){print}else{@F=split(/\t/);print unless ($$F[6] ne "PASS")}' $(outdir)/$(sample).indel.filter.vcf >$(outdir)/$(sample).indel.filter.vcf.tmp
	mv $(outdir)/$(sample).indel.filter.vcf.tmp $(outdir)/$(sample).indel.filter.vcf

extract:
	$(perl) $(bindir)/script/snp_indel/vcf2gp.pl -v $(outdir)/$(sample).snp.filter.vcf -o $(outdir)/$(sample).All.SNP.variants.list.xls
	$(perl) $(bindir)/script/snp_indel/vcf2gp.pl -v $(outdir)/$(sample).indel.filter.vcf -o $(outdir)/$(sample).All.INDEL.variants.list.xls

