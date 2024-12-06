bindir=$(dir $(firstword $(MAKEFILE_LIST)))/../
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software

ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config_$(genome).txt
else
Bconfig=$(config)
endif
include $(Bconfig)

Usage:
	@echo
	@echo Description:
	@echo "    INDEL Stat"
	@echo
	@echo Usage:
	@echo "    make -f $(name) vcf= infile= sampleID= outdir= INDEL_COUNT INDEL_DISTRIBUTION INDEL_EXON INDEL_LEN CP"
	@echo

INDEL_COUNT:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_COUNT-INFO- ####### INDEL Count Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/INDEL_count/
	$(PERL) $(script)/Common_SNPINDEL_Stat/count_indel.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/INDEL_count
	$(Rscript) $(script)/Common_Stat/barplot.r $(outdir)/Middle/Stat/INDEL_count/$(sampleID).INDEL.count.picture.list $(outdir)/Middle/Stat/INDEL_count 1,2 'Number of InDel' $(sampleID).INDEL.count stack n '' ''
	convert $(outdir)/Middle/Stat/INDEL_count/$(sampleID).INDEL.count.pdf $(outdir)/Middle/Stat/INDEL_count/$(sampleID).INDEL.count.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_COUNT-INFO- ####### INDEL Count End"
	@echo

INDEL_DISTRIBUTION:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_DISTRIBUTION-INFO- ####### INDEL ditribution Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/INDEL_dirtribution
	$(PERL) $(script)/Common_SNPINDEL_Stat/count_indel_distribution.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/INDEL_dirtribution
	$(Rscript) $(script)/Common_Stat/barplot.r $(outdir)/Middle/Stat/INDEL_dirtribution/$(sampleID).INDEL.genome.region.stat.picture.list $(outdir)/Middle/Stat/INDEL_dirtribution 1,2,3,4,5,6,7,8,9,10,11 'Percentage of InDel(%)' $(sampleID).INDEL.genome.region.stat stack p '' ''
	convert $(outdir)/Middle/Stat/INDEL_dirtribution/$(sampleID).INDEL.genome.region.stat.pdf $(outdir)/Middle/Stat/INDEL_dirtribution/$(sampleID).INDEL.genome.region.stat.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_DISTRIBUTION-INFO- ####### INDEL ditribution End"
	@echo

INDEL_EXON:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_EXON-INFO- ####### INDEL in Exon Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/INDEL_exon
	$(PERL) $(script)/Common_SNPINDEL_Stat/count_indel_in_exon.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/INDEL_exon
	$(Rscript) $(script)/Common_Stat/barplot.r $(outdir)/Middle/Stat/INDEL_exon/$(sampleID).INDEL.ExonicFunc.stat.picture.list $(outdir)/Middle/Stat/INDEL_exon 1,2,3,4,5,6,7,8 'Percentage of InDel in Exon(%)' $(sampleID).INDEL.ExonicFunc.stat stack p '' ''
	convert $(outdir)/Middle/Stat/INDEL_exon/$(sampleID).INDEL.ExonicFunc.stat.pdf $(outdir)/Middle/Stat/INDEL_exon/$(sampleID).INDEL.ExonicFunc.stat.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_EXON-INFO- ####### INDEL in Exon End"
	@echo

INDEL_LEN:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_LEN-INFO- ####### INDEL length Start"
	@echo
	mkdir -p $(outdir)/Middle/Stat/INDEL_len
	$(PERL) $(script)/Common_SNPINDEL_Stat/count_indel_length.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)/Middle/Stat/INDEL_len
	$(Rscript) $(script)/Common_SNPINDEL_Stat/anno.indel_len.r $(outdir)/Middle/Stat/INDEL_len/$(sampleID).INDEL.length.pattern.stat.picture.list $(outdir)/Middle/Stat/INDEL_len/$(sampleID).INDEL.length.pattern.stat.pdf $(sampleID)
	convert $(outdir)/Middle/Stat/INDEL_len/$(sampleID).INDEL.length.pattern.stat.pdf $(outdir)/Middle/Stat/INDEL_len/$(sampleID).INDEL.length.pattern.stat.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-INDEL_LEN-INFO- ####### INDEL length End"
	@echo

CP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### copy Start"
	@echo
	mkdir -p $(outdir)/Result/Stat
	cp $(outdir)/Middle/Stat/INDEL_*/$(sampleID).*.pdf $(outdir)/Result/Stat
	cp  $(outdir)/Middle/Stat/INDEL_*/$(sampleID).*.png $(outdir)/Result/Stat
	cp $(outdir)/Middle/Stat/INDEL_*/$(sampleID).*.picture.list $(outdir)/Result/Stat
	rename .picture.list .txt $(outdir)/Result/Stat/*.picture.list
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### copy End"
	@echo
