makefile_dir=$(dir $(firstword $(MAKEFILE_LIST)))
makefile_name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(makefile_dir)/../script/Sentieon/
scriptdir=$(makefile_dir)/../script/Common_MAP
thread?=16
sequencing_platform?=ILLUMINA

ifdef config
	include $(config)
else
	include $(makefile_dir)/config/config.txt
endif

ifeq ($(genome),hg38)
	ifeq ($(sex),XX)
		REF=$(REF_hg38_XX)
		exonbed=$(target_Agilent_60M_noY)
		DBSNP=$(DBSNP_hg38)
		MILL=$(MILL_hg38)
		PHASE=$(PHASE_hg38)
	else ifeq ($(sex),XY)
		REF=$(REF_hg38_XY)
		exonbed=$(target_Agilent_60M)
		DBSNP=$(DBSNP_hg38)
		MILL=$(MILL_hg38)
		PHASE=$(PHASE_hg38)
	endif
else ifeq ($(genome),hg19)
	ifeq ($(sex),XX)
		REF=$(REF_hg19_XX)
		DBSNP=$(DBSNP_hg19)
		MILL=$(MILL_hg19)
		PHASE=$(PHASE_hg19)
		exonbed=$(target_exome60_noY_hg19)
	else ifeq ($(sex),XY)
		REF=$(REF_hg19_XY)
		DBSNP=$(DBSNP_hg19)
		MILL=$(MILL_hg19)
		PHASE=$(PHASE_hg19)
		exonbed=$(target_exome60_hg19)
	endif
else
	REF=$(REF_hg19_XX)
	DBSNP=$(DBSNP_hg19)
	MILL=$(MILL_hg19)
	PHASE=$(PHASE_hg19)
	exonbed=$(target_exome60_noY_hg19)
endif

ifeq ($(sex),XY)
	len=$(len_XY)
else ifeq ($(sex),XX)
	len=$(len_XX)
else
	len=0
endif


tar_len=$(shell less $(exonbed)|awk '{len+=$$3-$$2}END{print len}')

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
	mkdir -p $(outdir) && echo "dir ok"
	$(sentieon) bwa mem -R "@RG\tID:$(prefix)\tSM:$(prefix)\tPL:$(sequencing_platform)" -t $(thread) -K 10000000 $(REF)  $(R1)  $(R2) | $(sentieon) util sort -r $(REF)  -t $(thread) --sam2bam -o $(outdir)/$(prefix).sort.bam -
	$(sentieon) driver -r $(REF) -t $(thread) -i $(outdir)/$(prefix).sort.bam --algo AlignmentStat --adapter_seq '' $(outdir)/$(prefix).aln_metrics.txt --algo CoverageMetrics  --omit_base_output --cov_thresh=1 --histogram_high=2000 --histogram_bin_count=1999 $(outdir)/raw.$(prefix).cover
	@echo "=================== Run sention bwa End at `date` =================== "

sort_bam?=$(outdir)/$(prefix).sort.bam
uniq:
	@echo "================== Run sention uniq Begin at `date` ================== "
	$(samtools) view -@ $(thread) -bh -F 4 -q 0 $(sort_bam) > $(outdir)/$(prefix).uniq.bam
	$(sentieon) util index $(outdir)/$(prefix).uniq.bam
	$(samtools) view -@ $(thread) -h -F 2308 $(outdir)/$(prefix).uniq.bam |$(script)/map_stat $(outdir)/$(prefix).uniq.tmp
	sed -i -e 's/Mapped Reads/Uniq Reads/' -e 's/Mapped Bases/Uniq Bases/' $(outdir)/$(prefix).uniq.tmp
	tail -n 2 $(outdir)/$(prefix).aln_metrics.txt |head -n 1 |awk '{print "Mapped Reads\t"$$6"\nMapped Bases\t"$$8}' > $(outdir)/$(prefix).map.info
	cat $(outdir)/$(prefix).uniq.tmp $(outdir)/$(prefix).map.info >$(outdir)/$(prefix).uniq.xls
	@echo "================== Run sention uniq End at `date` ================== "

uniq_bam?=$(outdir)/$(prefix).uniq.bam
rmdup:
	@echo "================== Run sention rmdup Begin at `date` ================== "
	$(sentieon) driver  -t $(thread) -i $(uniq_bam) --algo LocusCollector --fun score_info $(outdir)/$(prefix).score.txt
	$(sentieon) driver  -t $(thread) -i $(outdir)/$(prefix).uniq.bam --algo Dedup --rmdup --score_info $(outdir)/$(prefix).score.txt --metrics $(outdir)/$(prefix).rmdup_metrics.txt $(outdir)/$(prefix).rmdup.bam
	cat $(outdir)/$(prefix).rmdup_metrics.txt | grep -v "^#SentieonCommandLine" > $(outdir)/$(prefix).rmdup_metrics.txt.tmp
	mv $(outdir)/$(prefix).rmdup_metrics.txt.tmp $(outdir)/$(prefix).rmdup.metrics
	$(sentieon) driver -r $(REF) -t $(thread) -i $(outdir)/$(prefix).rmdup.bam --algo AlignmentStat --adapter_seq '' $(outdir)/rmdup.$(prefix).aln_metrics.txt --algo CoverageMetrics  --omit_base_output --cov_thresh=1 --histogram_high=2000 --histogram_bin_count=1999 $(outdir)/$(prefix).cover
	@echo "================== Run sention rmdup End at `date` ================== "

rmdup_bam?=$(outdir)/$(prefix).rmdup.bam
realn:
	@echo "================== Run sention realn Begin at `date` ================== "
	$(sentieon)  driver -r $(REF) -t $(thread) -i $(rmdup_bam) --algo Realigner -k $(MILL) -k $(PHASE)  $(outdir)/$(prefix).realn.bam
	@echo "================== Run sention realn End at `date` ================== "

realn_bam?=$(outdir)/$(sample).realn.bam
recal:
	@echo "================== Run sention recal Begin at `date` ================== "
	$(sentieon) driver -r $(REF)  -t $(thread) -i $(realn_bam) --algo QualCal -k $(DBSNP) -k $(MILL) -k $(PHASE) $(outdir)/$(sample).recal_data.table
	mkdir -p $(outdir)/Recal && echo "dir ok"
	ln -sf $(realn_bam) $(outdir)/Recal/$(sample).recal.bam
	$(samtools) index $(outdir)/Recal/$(sample).recal.bam
	cp $(realn_bam).bai $(outdir)/Recal/$(sample).recal.bam.bai
	##$(JAVA) $(java_command) -jar $(GATK_3.5) -T DepthOfCoverage -R $(REF) -o $(outdir)/$(sample) -I $(outdir)/$(sample).sort.bam --omitDepthOutputAtEachBase --omitIntervalStatistics -ct 1 --nBins $(nBins) --stop $(stop)

.PHONY:STAT
STAT:
ifeq ($(Datatype),WGS)
	$(PERL) $(scriptdir)/stat_depth.pl -i $(outdir) -s $(sample) -l $(len) -o $(outdir) -t "$(TRANSPOSE)"
ifdef fq_stat
	$(PERL) $(scriptdir)/map_stat.pl $(outdir)/$(sample).uniq.xls $(outdir)/$(sample).rmdup.metrics $(sample) $(fq_stat) $(len) $(outdir)/$(sample).coverage.xls >$(outdir)/$(sample).map.stat.xls
else
	$(itools) Fqtools stat -InFq $(fq1) -MinBaseQ $(MinBaseQ) -OutStat $(outdir)/$(sample).fq1.report 
	$(itools) Fqtools stat -InFq $(fq2) -MinBaseQ $(MinBaseQ) -OutStat $(outdir)/$(sample).fq2.report
	$(PERL) $(scriptdir)/stat_fq.pl $(outdir)/$(sample).fq1.report $(outdir)/$(sample).fq2.report $(sample) >$(outdir)/$(sample).clean.xls && \
	$(PERL) $(scriptdir)/map_stat.pl $(outdir)/$(sample).uniq.xls $(outdir)/$(sample).rmdup.metrics $(sample) $(outdir)/$(sample).clean.xls $(len) $(outdir)/$(sample).coverage.xls >$(outdir)/$(sample).map.stat.xls
endif
	$(PERL) $(scriptdir)/draw_depth.pl $(sample) $(outdir)/$(sample).site.depth.xls $(outdir)/$(sample).sum.depth.xls $(outdir) $(outdir)/$(sample).map.stat.xls -c $(config)

else ifeq ($(Datatype),WES)
	@echo "================== Run sention recal Begin at `date` ================== "
	$(JAVA) $(java_command) -jar $(GATK_3.5) -T DepthOfCoverage -R $(REF) -o $(outdir)/$(sample).region -I $(outdir)/$(sample).sort.bam -L $(exonbed) --omitDepthOutputAtEachBase --omitIntervalStatistics -ct 1 --nBins $(nBins) --stop $(stop) && \
	$(PERL) $(scriptdir)/stat_depth.pl -i $(outdir) -s $(sample).region -l $(tar_len) -o $(outdir) -t "$(TRANSPOSE)" && \
	$(PYTHON3) $(scriptdir)/get_flank_regionof_exome.py -i $(exonbed) -o $(outdir)/$(sample).flank.bed -f $(flank) >$(outdir)/$(sample).region.total.len &&\
	flankbed=$(outdir)/$(sample).flank.bed ; flank_len=`less $$flankbed|awk '{len+=$$3-$$2}END{print len}'` && \
	$(JAVA) $(java_command) -jar $(GATK_3.5) -T DepthOfCoverage -R $(REF) -o $(outdir)/$(sample).flank -I $(outdir)/$(sample).sort.bam -L $$flankbed --omitDepthOutputAtEachBase --omitIntervalStatistics -ct 1 --nBins $(nBins) --stop $(stop) && \
	$(PERL) $(scriptdir)/stat_depth.pl -i $(outdir) -s $(sample).flank -l $$flank_len -o $(outdir) -t "$(TRANSPOSE)" && \
	$(SAMTOOLS) view -hb -@ 4 $(outdir)/$(sample).sort.bam -L $(exonbed) > $(outdir)/$(sample).region.bam && $(SAMTOOLS) index $(outdir)/$(sample).region.bam && \
	$(PYTHON3) $(scriptdir)/exome_capture.py -bam $(outdir)/$(sample).region.bam -map $(outdir)/$(sample).uniq.xls -o $(outdir)/$(sample).capture.xls
ifdef fqstat
	$(PERL) $(scriptdir)/map_stat.pl $(outdir)/$(sample).uniq.xls $(outdir)/$(sample).rmdup.metrics $(sample) $(fqstat) $(tar_len) $(outdir)/$(sample).region.coverage.xls $(outdir) >$(outdir)/$(sample).map.stat.xls
else
	$(itools) Fqtools stat -InFq $(fq1) -MinBaseQ $(MinBaseQ) -OutStat $(outdir)/$(sample).fq1.report ||echo ok && \
	$(itools) Fqtools stat -InFq $(fq2) -MinBaseQ $(MinBaseQ) -OutStat $(outdir)/$(sample).fq2.report ||echo ok && \
	$(PERL) $(scriptdir)/stat_fq.pl $(outdir)/$(sample).fq1.report $(outdir)/$(sample).fq2.report $(sample) >$(outdir)/$(sample).clean.xls && \
	$(PERL) $(scriptdir)/map_stat.pl $(outdir)/$(sample).uniq.xls $(outdir)/$(sample).rmdup.metrics $(sample) $(outdir)/$(sample).clean.xls $(tar_len) $(outdir)/$(sample).region.coverage.xls $(outdir) >$(outdir)/$(sample).map.stat.xls
endif
	$(PERL) $(scriptdir)/draw_depth_exome.pl $(sample) $(outdir)/$(sample).region.site.depth.xls $(outdir)/$(sample).region.sum.depth.xls $(outdir)/ $(outdir)/$(sample).map.stat.xls -c $(config)
endif
