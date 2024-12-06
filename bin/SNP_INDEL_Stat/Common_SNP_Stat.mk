bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/

ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

Usage:
	@echo
	@echo Description:
	@echo "    SNP Stat"
	@echo
	@echo Usage:
	@echo "    make -f $(name) vcf= infile= sampleID= outdir= SNP_COUNT SNP_DISTRIBUTION SNP_EXON SNP_TS_TV SNP_MUT CP"
	@echo

SNP_COUNT:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_COUNT-INFO- ####### SNP count Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/SNP_count/
	$(PERL) $(script)/count_snp.pl -file $(vcf) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/SNP_count/
	$(Rscript) $(script)/barplot.r $(outdir)/Middle/Stat/SNP_count/$(sampleID).SNP.count.picture.list $(outdir)/Middle/Stat/SNP_count/ 1,2 'Number of SNP' $(sampleID).SNP.count stack n '' ''
	convert $(outdir)/Middle/Stat/SNP_count/$(sampleID).SNP.count.pdf $(outdir)/Middle/Stat/SNP_count/$(sampleID).SNP.count.png || echo ok
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_COUNT-INFO- ####### SNP count End"
	@echo

SNP_DISTRIBUTION:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_DISTRIBUTION-INFO- ####### SNP ditribution Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/SNP_dirtribution/
	$(PERL) $(script)/count_snp_distribution.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/SNP_dirtribution
	$(Rscript) $(script)/barplot.r $(outdir)/Middle/Stat/SNP_dirtribution/$(sampleID).SNP.genome.region.stat.picture.list $(outdir)/Middle/Stat/SNP_dirtribution 1,2,3,4,5,6,7,8,9,10,11 'Percentage of SNP(%)' $(sampleID).SNP.genome.region.stat stack p '' ''
	convert $(outdir)/Middle/Stat/SNP_dirtribution/$(sampleID).SNP.genome.region.stat.pdf $(outdir)/Middle/Stat/SNP_dirtribution/$(sampleID).SNP.genome.region.stat.png || echo ok
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_DISTRIBUTION-INFO- ####### SNP ditribution End"
	@echo

SNP_EXON:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_EXON-INFO- ####### SNP in exon Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/SNP_exon
	$(PERL) $(script)/count_snp_in_exon.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/SNP_exon
	$(Rscript) $(script)/barplot.r $(outdir)/Middle/Stat/SNP_exon/$(sampleID).SNP.ExonicFunc.stat.picture.list $(outdir)/Middle/Stat/SNP_exon 1,2,3,4,5,6 'Percentage of SNP in Exon(%)' $(sampleID).SNP.ExonicFunc.stat stack p '' ''
	convert $(outdir)/Middle/Stat/SNP_exon/$(sampleID).SNP.ExonicFunc.stat.pdf $(outdir)/Middle/Stat/SNP_exon/$(sampleID).SNP.ExonicFunc.stat.png || echo ok
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_EXON-INFO- ####### SNP in exon End"
	@echo

SNP_TS_TV:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_TS_TV-INFO- ####### SNP TS and TV Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/SNP_TS-TV
	$(PERL) $(script)/count_snp_ts_tv.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/SNP_TS-TV
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_TS_TV-INFO- ####### SNP TS and TV End"
	@echo

SNP_MUT:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_MUT-INFO- ####### SNP MUT Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/SNP_mut
	$(PERL) $(script)/count_snp_baseMut.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/SNP_mut
	$(Rscript) $(script)/barplot.r $(outdir)/Middle/Stat/SNP_mut/$(sampleID).SNP.mutation.pattern.stat.picture.list $(outdir)/Middle/Stat/SNP_mut 1,2,3,4,5,6,7 'Percentage of SNP Mutations(%)' $(sampleID).SNP.mutation.pattern.stat stack p '' ''
	convert $(outdir)/Middle/Stat/SNP_mut/$(sampleID).SNP.mutation.pattern.stat.pdf $(outdir)/Middle/Stat/SNP_mut/$(sampleID).SNP.mutation.pattern.stat.png || echo ok
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_MUT-INFO- ####### SNP MUT End"
	@echo

CP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### copy Start"
	@echo
	mkdir -p $(outdir)/Result/Stat
	cp $(outdir)/Middle/Stat/SNP_*/$(sampleID).*.pdf $(outdir)/Result/Stat
	cp  $(outdir)/Middle/Stat/SNP_*/$(sampleID).*.png $(outdir)/Result/Stat
	cp $(outdir)/Middle/Stat/SNP_*/$(sampleID).*.picture.list $(outdir)/Result/Stat
	cp $(outdir)/Middle/Stat/SNP_TS-TV/$(sampleID).*.txt $(outdir)/Result/Stat
	rename .picture.list .txt $(outdir)/Result/Stat/*.picture.list
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### copy End"
	@echo
