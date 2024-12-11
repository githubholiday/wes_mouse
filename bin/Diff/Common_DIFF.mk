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
	$(Python3) $(script)/Common_DIFF/preDIFF.py -g $(group) -s $(sample) -i $(annodir) -o $(outdir)/Middle -t $(type) -k $(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Prepare End"
	@echo

	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Extract ANNO Start"
	@echo
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(script)/Common_DIFF/extractinfo.pl -indir $(outdir)/Middle/ -group $(group) -type $(type) -annodir $(annodir) -key $(key) -outdir $(outdir)/Middle
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### Extract ANNO End"
	@echo

	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### STAT Start"
	@echo
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(script)/Common_DIFF/stat.pl -uniqfile $(outdir)/Middle/$(group).$(type).uniq.$(genome)_multianno.txt -commonfile $(outdir)/Middle/$(group).$(type).all.overlap.$(genome)_multianno.txt -outfile $(outdir)/Middle/$(group).$(type).stat.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### STAT End"
	@echo

	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### VEEN Start"
	@echo
	$(Rscript) $(script)/Common_DIFF/venn.r $(outdir)/Middle/$(group).$(type).venn.png $(outdir)/Middle/$(group).venn OverlapSite
	convert $(outdir)/Middle/$(group).$(type).venn.png $(outdir)/Middle/$(group).$(type).venn.pdf
	convert $(outdir)/Middle/$(group).$(type).venn.pdf $(outdir)/Middle/$(group).$(type).venn.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### VEEN End"
	@echo

	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### CP Start"
	@echo
	cp $(outdir)/Middle/$(group).*$(genome)_multianno.txt $(outdir)/Result
	cp $(outdir)/Middle/$(group).*venn.png $(outdir)/Result
	cp $(outdir)/Middle/$(group).*venn.pdf $(outdir)/Result
	cp $(outdir)/Middle/$(group).*stat.txt $(outdir)/Result
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-DIFF-INFO- ### CP End"
	@echo
