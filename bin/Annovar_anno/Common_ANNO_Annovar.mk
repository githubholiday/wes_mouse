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
	@echo "    Annotation variants by ANNOVAR."
	@echo
	@echo Usage:
	@echo "    make -f $(name) type={sv,cnv} file= outfile= TransFormat"
	@echo "    make -f $(name) vcf= sample= outdir= ANNOVAR_CNV_SV"
	@echo "    make -f $(name) vcfdir= sample= outdir= ANNOVAR_VCF OMIM KOGO HGMD cal_ADF split_ADF CP"
	@echo

TransFormat:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation-INFO- ### Transform non-VCF File Start"
	@echo
	mkdir -p $(outdir)
	$(PERL) $(script)/Common_ANNO_Annovar/trans_format.pl $(type) $(file) $(outfile)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation-INFO- ### Transform non-VCF File End"
	@echo

ANNOVAR_nonVCF:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation-INFO- ####### Annotation CNV_SV by ANNOVAR Start"
	@echo
	mkdir -p $(outdir)
	$(PERL) $(ANNOVAR) $(vcf) $(ANNODB) $(annovar_command_novcf) --outfile $(outdir)/$(sample).$(type)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation-INFO- ####### Annotation CNV_SV by ANNOVAR End"
	@echo

ANNOVAR_VCF:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Annotation SNP_INDEL by ANNOVAR Start"
	@echo
	mkdir -p $(outdir)/Middle
	$(PERL) $(ANNOVAR) $(vcf) $(ANNODB) $(annovar_command) --outfile $(outdir)/Middle/$(sample).$(type)
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Annotation SNP_INDEL by ANNOVAR End"
	@echo

ANNOVAR_CytoBand:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-cytoBand Annotation-INFO- ####### Annotation cytoBand by ANNOVAR Start"
	@echo
	$(Python3) $(script)/Common_ANNO_Annovar/format_sv_vcf.py -vcf $(vcf) -o $(vcf).format
	$(PERL) $(ANNOVAR) $(vcf).format $(ANNODB) $(annovar_command_cytoBand) --outfile $(outdir)/Middle/$(sample).$(type).cytoBand
	$(Python3) $(script)/Common_ANNO_Annovar/merge_cytoBand.py -cyto $(outdir)/Middle/$(sample).$(type).cytoBand.$(genome)_multianno.txt -anno $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt -o $(outdir)/Middle/$(sample).$(type).$(genome)_multianno_merged.txt
	mv $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt $(outdir)/Middle/$(sample).$(type).$(genome)_multianno_raw.txt
	mv $(outdir)/Middle/$(sample).$(type).$(genome)_multianno_merged.txt $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-cytoBand Annotation-INFO- ####### Annotation cytoBand by ANNOVAR End"
	@echo



ANNOVAR_Raw:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Annotation Raw SNP_INDEL by ANNOVAR Start"
	@echo
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(ANNOVAR) $(vcf) $(ANNODB) $(annovar_command) --outfile $(outdir)/Middle/$(sample).raw.$(type)
	cp $(outdir)/Middle/$(sample).raw.$(type).$(genome)_multianno.txt $(outdir)/Result/$(sample).raw.$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Annotation Raw SNP_INDEL by ANNOVAR End"
	@echo

ANNOVAR_Fast:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Fast Annotation by ANNOVAR Start"
	@echo
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(ANNOVAR) $(vcf) $(ANNODB) $(annovar_command_fast) --outfile $(outdir)/Middle/$(sample).$(type)
	#cp $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt $(outdir)/Result/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SNP_INDEL Annotation-INFO- ####### Fast Annotation by ANNOVAR End"
	@echo

ANNOVAR_Germline:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Germline_SNP_INDEL Annotation-INFO- ####### Annotation by ANNOVAR Start"
	@echo
	mkdir -p $(outdir)/{Middle,Result}
	$(PERL) $(ANNOVAR) $(vcf) $(ANNODB) $(annovar_command_germline) --outfile $(outdir)/Middle/$(sample).$(type)
	cp $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt $(outdir)/Result/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Germline_SNP_INDEL Annotation-INFO- ####### Annotation by ANNOVAR End"
	@echo

OMIM:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-OMIM-INFO- ####### OMIM database Annotation Start"
	@echo
	$(PERL) $(script)/Common_ANNO_Annovar/add_anno.pl $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt $(OMIM) 7 dot $(outdir)/Middle/$(sample).$(type).OMIM.$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-OMIM-INFO- ####### OMIM database Annotation End"
	@echo

KOGO:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-KOGO-INFO- ####### KOGO database Annotation Start"
	@echo
	$(PERL) $(script)/Common_ANNO_Annovar/add_anno.pl $(outdir)/Middle/$(sample).$(type).OMIM.$(genome)_multianno.txt $(UNIPROT) 7 dot $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-KOGO-INFO- ####### KOGO database Annotation End"
	@echo

HGMD:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-HGMD-INFO- ####### HGMD database Annotation Start"
	@echo
	$(PERL) $(script)/Common_ANNO_Annovar/HGMD_annovation.pl -hgmd $(HGMD) -annovar $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.$(genome)_multianno.txt -position 16 -result $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-HGMD-INFO- ####### HGMD database Annotation End"
	@echo

cal_ADF:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-ADF_calculate-INFO- ####### Calculate AlleleDepthFreq Start"
	@echo
	$(PERL) $(script)/Common_ANNO_Annovar/cal_AlleleDepthFreq.pl $(class) $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.$(genome)_multianno.txt $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.calADF.$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-ADF_calculate-INFO- ####### Calculate AlleleDepthFreq End"
	@echo

split_ADF:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-split_ADF-INFO- ####### Split AlleleDepthFreq Start"
	@echo
	$(PERL) $(script)/Common_ANNO_Annovar/split_AlleleDepthFreq.pl -adf $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.calADF.$(genome)_multianno.txt -result $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.splitADF.$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-split_ADF-INFO- ####### Split AlleleDepthFreq End"
	@echo

SNP_INDEL_CP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### cp Start"
	@echo
	mkdir -p $(outdir)/Result
	cp $(outdir)/Middle/$(sample).$(type).OMIM.KOGO.HGMD.splitADF.$(genome)_multianno.txt $(outdir)/Result/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### cp End"
	@echo

SNP_INDEL_FAST_CP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### cp Start"
	@echo
	mkdir -p $(outdir)/Result
	cp $(outdir)/Middle/$(sample).$(type).OMIM.$(genome)_multianno.txt $(outdir)/Result/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CP-INFO- ####### cp End"
	@echo

SV_CP:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV_CP-INFO- ####### cp Start"
	@echo
	mkdir -p $(outdir)/Result
	cp $(outdir)/Middle/$(sample).$(type).$(genome)_multianno.txt $(outdir)/Result/$(sample).$(type).$(genome)_multianno.txt
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-SV_CP-INFO- ####### cp End"
	@echo
