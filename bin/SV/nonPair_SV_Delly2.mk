bindir=$(dir $(firstword $(MAKEFILE_LIST)))
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software
#ifeq ($(strip $(config)),)
#Bconfig=$(bindir)/config/config_$(genome).txt
#else
#Bconfig=$(config)
#endif
include $(config)


HELP:
	@echo
	@echo Description:
	@echo "    Detect germline structural variants by DELLY2 using non-pair WES or WGS datasets.   "
	@echo "    Method: Delly: structural variant discovery by integrated paired-end and split-read analysis. Bioinformatics. (2012)."
	@echo Usage:
	@echo "    make -f $(name) genome= type= bam= outdir= DEL DUP TRA INS INV Filter"
	@echo


DEL:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DEL Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2) call -t DEL -g $(REF) -x $($(genome)excl) -o $(outdir)/Middle/$(sample).del.raw.bcf $(bam)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DEL End"
	@echo

DUP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DUP Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2) call -t DUP -g $(REF) -x $($(genome)excl) -o $(outdir)/Middle/$(sample).dup.raw.bcf $(bam)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DUP End"
	@echo

INV:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### INV Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2) call -t INV -g $(REF) -x $($(genome)excl) -o $(outdir)/Middle/$(sample).inv.raw.bcf $(bam)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### INV End"
	@echo

TRA:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### TRA Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2) call -t TRA -g $(REF) -x $($(genome)excl) -o $(outdir)/Middle/$(sample).tra.raw.bcf $(bam)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### TRA End"
	@echo

INS:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### INS Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2) call -t INS -g $(REF) -x $($(genome)excl) -o $(outdir)/Middle/$(sample).ins.raw.bcf $(bam)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### INS End"
	@echo


DELLY2_SV:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DELLY2 Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(DELLY2_238) call -g $(REF) -o $(outdir)/Middle/$(sample).all_SV.bcf $(bam)
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### DELLY2 End"

Filter:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### Filter Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(PYTHON3) $(script)/sv_fusion_filter_238.py --input_list "$(outdir)/Middle/$(sample).all_SV.bcf" --input_BED $(gene_bed) --sample_class $(type) --output_dir $(outdir)/Middle
	mv $(outdir)/Middle/all_SV_filtered.vcf $(outdir)/$(sample).SV.pass.vcf
	mv $(outdir)/Middle/all_SV.vcf $(outdir)/$(sample).SV.raw.vcf
	mv $(outdir)/Middle/all_SV_filtered.bed $(outdir)/$(sample).SV.pass.bed
	mv $(outdir)/Middle/fusion_gene_list.tsv $(outdir)/$(sample).FusionReport.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV-INFO- ### Filter End"
	@echo
