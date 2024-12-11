bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
ifeq ($(strip $(config)),)
Bconfig=$(bindir)/../../config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

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
	$(PERL) $(script)/count_fugene.pl -file $(Fusiondir)/$(sample).FusionReport.txt -sample $(sample) -outdir $(Fusiondir)
	if [ `cat $(Fusiondir)/$(sample).FusionReport.txt|wc -l` -eq 1 ]; \
	then \
		echo "$(sample) get no positive FusionGene result!"; \
		mv $(Fusiondir)/$(sample).FusionReport.txt $(Fusiondir)/$(sample).FusionReport.txt.neg; \
	fi
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Fusion-INFO- ### Fusion End"
	@echo
