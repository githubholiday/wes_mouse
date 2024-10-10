Bin=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))/
ifeq ($(strip $(config)),)
Bconfig=$(Bin)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

sentieon=/opt/sentieon-genomics-202308.03/bin/sentieon
sequencing_platform?=ILLUMINA
quality=4
thread=16
HELP:
	@echo Description:使用本地sention bwa比对
	@echo Program:sention_bwa 
	@echo Version: v1.0.0
	@echo Contactor: jiaozhang03@genome.cn
	@echo Usage:
	@echo -e "\t" "make -f $(makefile_name) genome= R1= R2= prefix= outdir= [config= ] [thread= ]  bwa uniq rmdup realn"
	@echo 参数说明：
	@echo -e "\t" "config: [文件|可选]  模块配置文件，和软件相关参数，默认为$(makefile_dir)/config/config.txt "
	@echo -e "\t" "REF: 参考基因组路经"
	@echo -e "\t" "R1: R1端reads"
	@echo -e "\t" "R2: R2端reads"
	@echo -e "\t" "prefix: 输出文件名索引"
	@echo -e "\t" "outdir: 输出路径"
	@echo 'thread: 程序运行使用的线程数, 默认16'
	@echo Supplementary information :如果使用其他模块，需提供"sort_bam= or uniq_bam= or rmdup_bam= "

bwa:
	@echo "=================== Run sention bwa Begin at `date` =================== "
	[ -d $(outdir) ] || mkdir -p $(outdir) && echo "dir ok"
	$(sentieon) bwa mem -R "@RG\tID:$(prefix)\tSM:$(prefix)\tPL:$(sequencing_platform)" -t $(thread) -K 10000000 $(REF)  $(R1)  $(R2) | $(sentieon) util sort -r $(REF)  -t $(thread) --sam2bam -o $(outdir)/$(prefix).sorted.bam -
	$(sentieon) driver -r $(REF) -t $(thread) -i $(outdir)/$(prefix).sorted.bam --algo AlignmentStat --adapter_seq '' $(outdir)/$(prefix).aln_metrics.txt --algo CoverageMetrics  --omit_base_output --cov_thresh=1 --histogram_high=2000 --histogram_bin_count=1999 $(outdir)/$(prefix).cover
	tail -n 2 $(outdir)/$(prefix).aln_metrics.txt |head -n 1 |awk '{print "Mapped Reads\t"$$6"\nMapped Bases\t"$$8}' > $(outdir)/$(prefix).map.info
	@echo "=================== Run sention bwa End at `date` =================== "


sort_bam?=$(outdir)/$(prefix).sorted.bam
uniq:
	@echo "================== Run sention uniq Begin at `date` ================== "
	$(samtools) view -@ $(thread) -bh -q $(quality) $(sort_bam) > $(outdir)/$(prefix).uniq.bam
	$(sentieon) util index $(outdir)/$(prefix).uniq.bam
	$(samtools) view -@ $(thread) -h -F 2308 $(outdir)/$(prefix).uniq.bam|$(Bin)/script/map_stat $(outdir)/$(prefix).uniq.xls.tmp
	sed -i -e 's/Mapped Reads/Uniq Reads/' -e 's/Mapped Bases/Uniq Bases/' $(outdir)/$(prefix).uniq.xls.tmp
	cat $(outdir)/$(prefix).uniq.xls.tmp $(outdir)/$(prefix).map.info >$(outdir)/$(prefix).uniq.xls
	@echo "================== Run sention uniq End at `date` ================== "


uniq_bam?=$(outdir)/$(prefix).uniq.bam
rmdup:
	@echo "================== Run sention rmdup Begin at `date` ================== "
	$(sentieon) driver  -t $(thread) -i $(uniq_bam) --algo LocusCollector --fun score_info $(outdir)/$(prefix).score.txt
	$(sentieon) driver  -t $(thread) -i $(uniq_bam) --algo Dedup --rmdup --score_info $(outdir)/$(prefix).score.txt --metrics $(outdir)/$(prefix).rmdup_metrics.txt.tmp $(outdir)/$(prefix).rmdup.bam
	cat $(outdir)/$(prefix).rmdup_metrics.txt.tmp | grep -v "^#SentieonCommandLine" > $(outdir)/$(prefix).rmdup_metrics.txt
	$(sentieon) driver -r $(REF) -t $(thread) -i $(outdir)/$(prefix).rmdup.bam --algo AlignmentStat --adapter_seq '' $(outdir)/rmdup.$(prefix).aln_metrics.txt --algo CoverageMetrics  --omit_base_output --cov_thresh=1 --histogram_high=2000 --histogram_bin_count=1999 $(outdir)/rmudp.$(prefix).cover
	@echo "================== Run sention rmdup End at `date` ================== "

rmdup_bam?=$(outdir)/$(prefix).rmdup.bam
call_paramter=--emit_conf=10 --call_conf=30
ploidy?=2
call:
	@echo "================== Run sention call Begin at `date` ================== "
	mkdir -p $(snp_indel_outdir)/GVCF
	mkdir -p $(snp_indel_outdir)/$(prefix)
	$(sentieon) driver -r $(REF) -t $(thread) -i $(rmdup_bam) --algo Haplotyper --emit_mode=gvcf --ploidy=$(ploidy) $(call_paramter) $(snp_indel_outdir)/GVCF/$(prefix).raw.g.vcf.gz
	$(sentieon) driver -r $(REF) -t $(thread) -i $(rmdup_bam) --algo GVCFtyper -v $(snp_indel_outdir)/GVCF/$(prefix).raw.g.vcf.gz $(snp_indel_outdir)/$(prefix)/$(prefix).raw.vcf.gz	
	@echo "================== Run sention call end at `date` ================== "

mergevcf:
	mkdir -p $(snp_indel_outdir)
	@echo "================== Run sention mergevcf  Begin at `date` ================== "
	$(sentieon) driver -r $(REF) -t $(thread) --algo GVCFtyper $(snp_indel_outdir)/ALL.raw.vcf.gz $(snp_indel_outdir)/GVCF/*.raw.g.vcf.gz
	@echo "================== Run sention mergevcf  End at `date` ================== "

recal_bam?=$(outdir)/Recal/$(prefix).recal.bam
recal_data?=$(outdir)/$(prefix).recal_data.table
.PHONY:Call
Call:
    mkdir -p $(outdir)
    @echo "=================== Run Human WES Begin at `date` =================== "
    $(sentieon) driver -r $(REF)  -t $(thread) -i $(rmdup_bam) --interval $(exonbed) --algo Haplotyper -d $(DBSNP) --emit_conf=10 --call_conf=30 --emit_mode=gvcf $(outdir)/$(prefix).raw.g.vcf.gz 
    $(sentieon) driver -r $(REF) -t $(thread) --interval $(exonbed) --algo GVCFtyper -v $(outdir)/$(prefix).raw.g.vcf.gz $(outdir)/$(prefix).raw.vcf.gz
	@echo "=================== Run Human WES End at `date` =================== "

.PHONY:SELECT
SELECT:
        [ -d $(outdir)/$(sample).vcf ] && rm $(outdir)/$(sample).vcf || echo start analysis
        gunzip -c $(outdir)/$(sample).vcf.gz>$(outdir)/$(sample).vcf
        $(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -T SelectVariants -R $(ref) -V $(outdir)/$(sample).vcf -o $(outdir)/$(sample).snp.raw.vcf -selectType SNP
        $(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -T SelectVariants -R $(ref) -V $(outdir)/$(sample).vcf -o $(outdir)/$(sample).indel.raw.vcf -selectType INDEL

.PHONY:Filter
Filter:
        $(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -R $(ref) --variant $(outdir)/$(sample).snp.raw.vcf -o $(outdir)/$(sample).snp.filter.vcf $(snp_filter)
        $(JAVA) $(java_command) -jar $(script)/GATK/GenomeAnalysisTK.jar -R $(ref) --variant $(outdir)/$(sample).indel.raw.vcf -o $(outdir)/$(sample).indel.filter.vcf $(indel_filter)
        $(perl) -ne 'if(/^#/){print}else{@F=split(/\t/);print unless ($$F[6] ne "PASS")}' $(outdir)/$(sample).snp.filter.vcf >$(outdir)/$(sample).snp.filter.vcf.tmp
        mv $(outdir)/$(sample).snp.filter.vcf.tmp $(outdir)/$(sample).snp.filter.vcf
        $(perl) -ne 'if(/^#/){print}else{@F=split(/\t/);print unless ($$F[6] ne "PASS")}' $(outdir)/$(sample).indel.filter.vcf >$(outdir)/$(sample).indel.filter.vcf.tmp
        mv $(outdir)/$(sample).indel.filter.vcf.tmp $(outdir)/$(sample).indel.filter.vcf

.PHONY:extract
extract:
        $(perl) $(bindir)/script/snp_indel/vcf2gp.pl -v $(outdir)/$(sample).snp.filter.vcf -o $(outdir)/$(sample).All.SNP.variants.list.xls
        $(perl) $(bindir)/script/snp_indel/vcf2gp.pl -v $(outdir)/$(sample).indel.filter.vcf -o $(outdir)/$(sample).All.INDEL.variants.list.xls
