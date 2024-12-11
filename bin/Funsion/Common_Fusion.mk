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

ifeq ($(genome),hg19)
	REF=$(REF_hg19)
endif
ifeq ($(genome),hg38)
	REF=$(REF_hg38)
endif

HELP:
	@echo
	@echo Description:
	@echo "    Select Fusion gene based on SV results detected by DELLY2."
	@echo "    Method: in-house script."
	@echo Usage:
	@echo "    make -f $(name) SVdir= Fusiondir= sample= Fusion"
	@echo


Fusion:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Fusion-INFO- ### Fusion Start"
	@echo
	mkdir -p $(Fusiondir)
	cp $(SVdir)/$(sample).FusionReport.txt $(Fusiondir)
	$(PERL) $(script)/Common_FUSION_Stat/count_fugene.pl -file $(Fusiondir)/$(sample).FusionReport.txt -sample $(sample) -outdir $(Fusiondir)
	if [ `cat $(Fusiondir)/$(sample).FusionReport.txt|wc -l` -eq 1 ]; \
	then \
		echo "$(sample) get no positive FusionGene result!"; \
		mv $(Fusiondir)/$(sample).FusionReport.txt $(Fusiondir)/$(sample).FusionReport.txt.neg; \
	fi
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Fusion-INFO- ### Fusion End"
	@echo
