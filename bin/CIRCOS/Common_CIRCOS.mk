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

###targets###
HELP:
	@echo Description:
	@echo "to Get the circos result"
	@echo Usage: config1 is a optional parameter.
	@echo make -f this_makefile snp_infile= chomys= indel_infile= fusion_normal_indir= fusion_tumor_indir= CNV_infile= LOH_infile= SV_infile= tumor_sample= normal_sample SAMPLE= outdir= config1= DATA1 CIRCOS1

joblist?=$(script)/../pipe/circos.list
ifndef $(config1)
	config1=$(script)/../config/config_$(genome).txt
endif

ex= export PERL5LIB=/home/hougy/src/perl/lib/site_perl/5.16.2/x86_64-linux-thread-multi:/home/hougy/src/perl/lib/site_perl/5.16.2

.PHONY:DATA1
DATA1:
	mkdir -p ${outdir}/data/
	$(PERL) $(script)/Common_CIRCOS/faSortByLength.pl $(ref_circos) $(outdir)/data/faSortByLen.txt $(outdir)/data/karyotype.txt $(outdir)/data/config

SNP_INDEL:
	${PERL} $(script)/Common_CIRCOS/SNP2site_update.pl ${snp_infile} ${outdir} ${chomys} ${window} ${fai_circos}
	${PERL} $(script)/Common_CIRCOS/Indel2site_update.pl ${indel_infile} ${outdir} ${chomys}

Fusion_Gene:
	${PERL} $(script)/Common_CIRCOS/Fusion_format_update.pl -indirN ${fusion_normal_indir} -indirT ${fusion_tumor_indir} -sample_idT ${tumor_sample} -sample_idN ${normal_sample} -outdir ${outdir}
CNV:
	${PERL} $(script)/Common_CIRCOS/CNV_region.pl ${CNV_infile} $(outdir)/data/cnv_region.txt
LOH:
	${PERL} $(script)/Common_CIRCOS/LOH_site.pl $(LOH_infile) ${outdir}/data/LOH_site.txt
SV:
	${PERL} $(script)/Common_CIRCOS/SV_site.pl $(SV_infile) ${outdir}/data/sv_INS.txt ${outdir}/data/sv_DEL.txt ${outdir}/data/sv_DUP.txt ${outdir}/data/sv_CTX.txt ${outdir}/data/sv_INV.txt
	#[ -s $(SV_indir) ] && ${PERL} $(script)/Common_CIRCOS/sv_delly.pl -indir $(SV_indir) -outdir $(outdir)/data -sample $(SAMPLE) || echo $(SV_indir) does not exist

.PHONY:CIRCOS1
CIRCOS1:
	mkdir -p ${outdir}/conf/
	mkdir -p ${outdir}/fig/
	$(ex) && ${PERL} ${script}/Common_CIRCOS/circos_V2.pl -joblist ${joblist} -outdir ${outdir}/conf/ -chr ${chomys} -config_radius_defined ${config1} -karyotype ${karyotype}
	$(ex) && ${PERL} $(circos) -conf ${outdir}/conf/circos.conf -outputdir ${outdir}/fig/ -outputfile ${SAMPLE}
	convert ${outdir}/fig/${SAMPLE}.svg ${outdir}/fig/${SAMPLE}.pdf
	convert ${outdir}/fig/${SAMPLE}.pdf ${outdir}/fig/${SAMPLE}.png
