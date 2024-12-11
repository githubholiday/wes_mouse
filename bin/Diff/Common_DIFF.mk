bindir=$(dir $(firstword $(MAKEFILE_LIST)))
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software

ifeq ($(strip $(config)),)
Bconfig=$(bindir)/../../config/config_$(genome).txt
else
Bconfig=$(config)
endif
include $(Bconfig)


Usage:
	@echo
	@echo Description:
	@echo "    to get the common and special SNV or INDEL among 2-5 samples"
	@echo
	@echo Usage:
	@echo "    make -f $(name) annodir= outdir= group= sample= type= key= DIFF"
	@echo

DIFF:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Prepare Start"
	@echo
	#-rm -r $(outdir)
	mkdir -p $(outdir)/{Middle,Result}
	$(Python3) $(script)/preDIFF.py -g $(group) -s $(sample) -i $(annodir) -o $(outdir)/Middle -t $(type) -k $(genome)_multianno.txt
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Prepare End"
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Extract ANNO Start"
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(script)/extractinfo.pl -indir $(outdir)/Middle/ -group $(group) -type $(type) -annodir $(annodir) -key $(key) -outdir $(outdir)/Middle
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Extract ANNO End"
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### STAT Start"
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(script)/stat.pl -uniqfile $(outdir)/Middle/$(group).$(type).uniq.$(genome)_multianno.txt -commonfile $(outdir)/Middle/$(group).$(type).all.overlap.$(genome)_multianno.txt -outfile $(outdir)/Middle/$(group).$(type).stat.txt
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### STAT End"
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### VEEN Start"
	$(Rscript) $(script)/venn.r $(outdir)/Middle/$(group).$(type).venn.png $(outdir)/Middle/$(group).venn OverlapSite
	convert $(outdir)/Middle/$(group).$(type).venn.png $(outdir)/Middle/$(group).$(type).venn.pdf
	convert $(outdir)/Middle/$(group).$(type).venn.pdf $(outdir)/Middle/$(group).$(type).venn.png
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### VEEN End"
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### CP Start"
	cp $(outdir)/Middle/$(group).*$(genome)_multianno.txt $(outdir)/Result
	cp $(outdir)/Middle/$(group).*venn.png $(outdir)/Result
	cp $(outdir)/Middle/$(group).*venn.pdf $(outdir)/Result
	cp $(outdir)/Middle/$(group).*stat.txt $(outdir)/Result
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### CP End"
