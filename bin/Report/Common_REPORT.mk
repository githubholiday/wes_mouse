bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software
configd=$(bindir)/config/
ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

store_dir?=/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/Stat/Medical/

ifeq ($(pipetype),single)
	Dir = $(store_dir)/MonoDisease
else ifeq ($(pipetype),pair)
	Dir = $(store_dir)/Tumor
endif

Usage:
	@echo
	@echo Description:
	@echo "    Prepare files and generate web report or clinical report"
	@echo
	@echo Usage:
	@echo "    make -f $(name) indir= outdir= pipetype= datatype= UPLOAD WEB"
	@echo "    make -f $(name) indir= outdir= CLINIC"

UPLOAD:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Get Upload Start"
	@echo
	-rm -r $(outdir)/*
	mkdir -p $(outdir)/upload/common
	$(PYTHON3) $(script)/get_config.py -o $(outdir) -c $(indir)/../pre/config.ini
	$(PERL) $(script)/get_upload.pl -i $(indir) -o $(outdir) -m $(configd)/template.txt -c $(configd)/upload.config -k $(configd)/keep.list -l $(outdir)/../../pre/sample.list
	cp -r $(configd)/upload.config  $(outdir)/
	@echo
	find $(outdir)/upload -name "*txt" -exec rename txt xls {} \;
	@echo
	$(PYTHON3) $(script)/get_readme.py -i $(script)/../doc/readme -o $(outdir)/upload -c $(indir)/../pre/config.ini -p $(pipetype) -d $(datatype)
	cp $(script)/../doc/common/$(platform)/* $(outdir)/upload/common/
	
	@echo
	$(PERL) $(script)/folder_rank.pl -i $(outdir)/upload
	@echo
	cd $(outdir) && find ./upload -type f -exec md5sum {} \; >$(outdir)/md5.txt && echo Check md5 done!
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Get Upload End"
	@echo

WEB:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Generate Web-Report Start"
	@echo
	mkdir -p $(outdir)
	ssh 192.168.1.3 $(python3_report) $(Report_PY) -i $(outdir)/MonoDisease.template -c $(outdir)/report.conf -u admin -t cloud 
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Generate Web-Report Finish"


WEB_Raw:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Generate Web-Report Start"
	@echo
	mkdir -p $(outdir)
	#ssh c0008 $(PYTHON3) $(script)/Report.py -i $(outdir)/MonoDisease.template -c $(outdir)/report.conf -u admin && echo Generate Web-Report Success!
	make -f /annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/Public/Pipeline/Stable/Public/Report/Report_local/current/Public_webreport/makefile config=$(config) report_dir=$(outdir) projectType=MonoDisease Web_Report
	@echo
	@mkdir -p $(Dir)/$(project_id)
	@-cp $(outdir)/upload/*FQ/filter_stat.xls $(Dir)/$(project_id)/$(project_id)_$(project)_Filter.xls
	@-cp $(outdir)/upload/*MAP/All.map.stat.xls $(Dir)/$(project_id)/$(project_id)_$(project)_MAP.xls
	#@echo "ssh c0008 $(PYTHON3) $(script)/Report.py -i $(outdir)/MonoDisease.template -c $(outdir)/report.conf -u admin" > $(outdir)/creat_report.sh
	@echo "make -f /annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/Public/Pipeline/Stable/Public/Report/Report_local/current/Public_webreport/makefile report_dir=$(outdir) projectType=MonoDisease Web_Report" $(outdir)/creat_report.sh
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-Web_Report-INFO- ### Generate Web-Report End"
	@echo
	#for i in `find $(outdir)/upload -name '*xls'`;do /usr/bin/iconv -c -f utf-8 -t gb2312 $$i >$${i}.bak && mv $${i}.bak $$i;done

CLINIC_Static:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CLINIC_Report-INFO- ### Get Upload Start"
	@echo
	-rm -r $(outdir)/*
	mkdir -p $(outdir)/upload/common
	@echo
	$(PYTHON3) $(script)/get_config.py -o $(outdir) -c $(indir)/../pre/config.ini -cli
	@echo
	$(PERL) $(script)/get_upload.pl -i $(indir) -o $(outdir) -m $(configd)/clinical_static_report_template.txt -c $(outdir)/upload.config -k $(configd)/keep.list -l $(outdir)/../../pre/sample.list
	@echo
	find $(outdir)/upload -name "*.txt" -exec rename .txt .xls {} \;
	cp $(script)/../../doc/common/* $(outdir)/upload/common
	$(PERL) $(script)/folder_rank.pl -i $(outdir)/upload
	make -f /annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/Public/Pipeline/Stable/Public/Report/Report_local/current/Public_webreport/makefile report_dir=$(outdir) projectType=MonoDisease Web_Report
	#ssh c0008 $(PYTHON3) $(script)/Report.py -i $(outdir)/MonoDisease.template -c $(outdir)/report.conf -u admin && echo Generate CLINIC_Static-Report Success!
	for i in `find $(outdir)/upload -name '*xls'`;do /usr/bin/iconv -c -f utf-8 -t gb2312 $${i} >$${i}.bak && mv $${i}.bak $$i;done

CLINIC:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-CLINIC_Report-INFO- ### Get Upload Start"
	@echo
	-rm -r $(outdir)/*
	mkdir -p $(outdir)/upload/common
	cp $(outdir)/../CLINIC_Static_Report/*.pdf $(outdir)/
	@echo
	$(PYTHON3) $(script)/get_config.py -o $(outdir) -c $(pipe_conf) -cli
	@echo
	$(PERL) $(script)/get_upload.pl -i $(indir) -o $(outdir) -m $(configd)/clinical_report_template.txt -c $(outdir)/upload.config -k $(configd)/keep.list -l $(outdir)/../../pre/sample.list
	@echo
	find $(outdir)/upload -name "*txt" -exec rename txt xls {} \;
	cp $(script)/../../doc/common/* $(outdir)/upload/common
	cd $(outdir) && zip -r $(outdir)/report.zip upload
	mkdir $(outdir)/upload/download && mv $(outdir)/report.zip $(outdir)/upload/download
	$(PERL) $(script)/folder_rank.pl -i $(outdir)/upload
	$(PYTHON3) $(script)/tb2js.py -i $(outdir)/MonoDisease.template
	ssh c0021 $(PYTHON3) $(script)/Report_V3_fortest.py -i $(outdir)/MonoDisease.template -c $(outdir)/report.conf -u admin && echo Generate Clinical-Report Success!
	$(PYTHON3) $(script)/get_url.py -p $(project_id) -o $(outdir)/url
	for i in `find $(outdir)/upload -name '*xls'`;do /usr/bin/iconv -c -f utf-8 -t gb2312 $$i >$${i}.bak && mv $${i}.bak $$i;done

