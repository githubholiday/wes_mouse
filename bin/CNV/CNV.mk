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
	@echo Description:
	@echo 生成单个样本的SNP indel 的*.raw.vcf *.filter.vcf
	@echo Usage:
	@echo make -f $(tmpdir)/Saile_SNP_INDEL.mk bam= sample= outdir= ref= ploidy= SELECT Filter extract

.PHONY:CNV
CNV:
	echo CNV start at `date`
	mkdir -p $(outdir)
	$(cnvkit_env) && cnvkit.py batch $(inbam) -n -m hybrid -t $(bed) --annotate $(flat_file) --fasta $(genome) --access $(access_file) --output-reference $(outdir)/mm10.cnn --output-dir $(outdir) --diagram --scatter
	cut -f 1,2,3,4,6,7 $(outdir)/$(sample).sorted.call.cns > $(outdir)/$(sample).CNV.raw.xls
	convert $(outdir)/$(sample).sorted-diagram.pdf $(outdir)/$(sample).sorted-diagram.png
	convert $(outdir)/$(sample).sorted-scatter.pdf $(outdir)/$(sample).sorted-scatter.png
	echo CNV end at `date`

CNV_anno:
	echo CNV anno start at `date`
	mkdir -p $(outdir)
	awk -F "\t" '{print  $$1"\t"$$2"\t"$$3"\t"$$4"\t"$$5"\t"$$6"\t"$$7"\t"$$8"\tGT\t./.\t"$$9"\t-\t-\t-"}' $(infile) |sed '1d' - > $(outdir)/$(sample).CNV.raw.vcf
	$(PERL) $(annovar_perl) $(outdir)/$(sample).CNV.raw.vcf $(annovardb) -outfile $(outdir)/$(sample).CNV -buildver Mus_musculus $(annovar_opt)
	$(PYTHON3) $(script)/format.py -i $(outdir)/$(sample).CNV.Mus_musculus_multianno.txt -o $(outdir)/$(sample).CNV.anno.multianno.xls
	echo CNV anno end at `date`