bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
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
	@echo "    SV Count and Stat"
	@echo
	@echo Usage:
	@echo "    make -f $(name) infile= sampleID= outdir= SV_COUNT SV_DISTRIBUTION SV_TYPE"
	@echo "    make -f $(name) outdir= resultdir= SV_CP"
	@echo


SV_COUNT:
	@echo "################## SV Count Begin:" `date`
	mkdir -p $(outdir)
	$(PERL) $(script)/count_sv.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)
	$(Rscript) $(script)/barplot.r $(outdir)/$(sampleID).SV.num.txt $(outdir) 1,2 'Number of SV' $(sampleID).SV.num stack n '' ''
	convert $(outdir)/$(sampleID).SV.num.pdf $(outdir)/$(sampleID).SV.num.png
	@echo "################## SV Count End:" `date`

SV_DISTRIBUTION:
	@echo "################## SV Distribution Begin:" `date`
	mkdir -p $(outdir)
	$(PERL) $(script)/count_sv_distribution.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)
	$(Rscript) $(script)/barplot.r $(outdir)/$(sampleID).SV.genome.region.stat.picture.list $(outdir) 1,2,3,4,5,6,7,8,9,10,11 'Percentage of SV(%)' $(sampleID).SV.genome.region.stat stack p '' ''
	convert $(outdir)/$(sampleID).SV.genome.region.stat.pdf $(outdir)/$(sampleID).SV.genome.region.stat.png
	@echo "################## SV Distribution End:" `date`

SV_LEN:
	@echo "################## SV Length Begin:" `date`
	mkdir -p $(outdir)
	$(PERL) $(script)/count_sv_len.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)
	$(Rscript) $(script)/breakseq.twohist.R $(outdir)/$(sampleID).SV.length.stat.txt $(outdir)/$(sampleID).SV.length.stat.pdf $(sampleID)
	convert $(outdir)/$(sampleID).SV.length.stat.pdf $(outdir)/$(sampleID).SV.length.stat.png
	@echo "################## SV Length End:" `date`

SV_TYPE:
	@echo "################## SV Type Begin:" `date`
	mkdir -p $(outdir)
	$(PERL) $(script)/count_sv_type.pl -file $(infile) -sampleID $(sampleID) -outdir $(outdir)
	$(Rscript) $(script)/barplot.r $(outdir)/$(sampleID).SV.type.stat.picture.list $(outdir) 1,2,3,4,5,6 'Percentage of SV Type(%)' $(sampleID).SV.type.stat stack p '' ''
	convert $(outdir)/$(sampleID).SV.type.stat.pdf $(outdir)/$(sampleID).SV.type.stat.png
	@echo "################## SV Type End:" `date`

SV_CP:
	@echo "################## SV CP Begin:" `date`
	mkdir -p $(outdir)
	[ -d $(resultdir) ] || mkdir -p $(resultdir)
	cp $(outdir)/SV_*/*.p* $(resultdir)
	cp $(outdir)/SV_count/*.SV.count $(resultdir)
	cp $(outdir)/SV_*/*.picture.list $(resultdir)
	rename SV.count SV.count.txt $(resultdir)/*.SV.count
	@rename .picture.list .txt $(resultdir)/*.picture.list
	@echo "################## SV CP End:" `date`

