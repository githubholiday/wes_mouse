bindir=$(dir $(firstword $(MAKEFILE_LIST)))/../
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)/../database
software=$(bindir)/../software
ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config_$(genome).txt
else
Bconfig=$(config)
endif
include $(Bconfig)
title_document=$(bindir)/config/$(genome).title_document.txt

Usage:
	@echo
	@echo Description:
	@echo "    to annotation variants by ANNOVAR"
	@echo
	@echo Usage:
	@echo "    make -f $(name) indir= Cut_Anno_file"
	@echo "    make -f $(name) infile= type= chr1 "
	@echo

Cut_Anno_file:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Cut_Anno_file-INFO- ####### Cut Annotation File By Chr Start"
	$(python3) $(script)/Common_ANNO_Format/CutFileByChr.py -i $(indir) -t $(type) -s $(sample) -g $(genome)
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Cut_Anno_file-INFO- ####### Cut Annotation File By Chr End"
	@echo

chr1:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr1> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr1.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr1.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr1> End"
	@echo
chr2:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr2> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr2.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr2.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr2> End"
	@echo
chr3:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr3> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr3.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr3.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr4> End"
	@echo
chr4:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr4> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr4.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr4.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr4> End"
	@echo
chr5:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr5> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr5.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr5.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr5> End"
	@echo
chr6:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr6> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr6.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr6.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr6> End"
	@echo
chr7:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr7> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr7.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr7.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr7> End"
	@echo
chr8:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr8> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr8.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr8.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr8> End"
	@echo
chr9:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr9> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr9.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr9.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr9> End"
	@echo
chr10:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr10> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr10.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr10.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr10> End"
	@echo
chr11:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr11> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr11.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr11.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr11> End"
	@echo
chr12:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr12> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr12.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr12.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr12> End"
	@echo
chr13:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr13> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr13.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr13.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr13> End"
	@echo
chr14:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr14> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr14.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr14.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr14> End"
	@echo
chr15:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr15> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr15.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr15.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr15> End"
	@echo
chr16:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr16> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr16.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr16.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr16> End"
	@echo
chr17:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr17> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr17.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr17.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr17> End"
	@echo
chr18:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr18> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr18.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr18.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr18> End"
	@echo
chr19:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr19> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr19.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr19.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr19> End"
	@echo
chr20:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr20> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr20.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr20.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr20> End"
	@echo
chr21:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr21> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr21.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr21.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr21> End"
	@echo
chr22:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr22> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chr22.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chr22.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chr22> End"
	@echo
chrX:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chrX> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chrX.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chrX.$(type).$(genome)_multianno.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chrX> End"
	@echo
chrY:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chrY> Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).chrY.$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).Format.chrY.$(type).$(genome)_multianno.xls
	
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format <chrY> End"
	@echo

chr_all:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format Start"
	@echo
	-$(PERL_ANNO) $(script)/Common_ANNO_Format/Format.pl -annovar $(infile).$(type).$(genome)_multianno.txt -title $(title_document) -output $(infile).$(type).$(genome)_multianno.Format.xls
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Annotation Format CHR-INFO- ####### Annotation Format End"
	@echo
