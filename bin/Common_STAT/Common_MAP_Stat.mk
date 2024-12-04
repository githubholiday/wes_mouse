bindir=$(dir $(firstword $(MAKEFILE_LIST)))/
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(bindir)/script/
database=$(bindir)../database
software=$(bindir)../software

ifeq ($(strip $(config)),)
Bconfig=$(bindir)/config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)

HELP:
	@echo Description:
	@echo 报告中多样品统计图表生成
	@echo Usage:
	@echo make -f $(tmpdir)/mk_Stat samplelist= indir= outdir= MAP_STAT_QC

MAP_STAT_QC:
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-MAP_STAT_QC-INFO- ####### MAP_STAT_QC Start"
	@echo
	mkdir -p $(outdir)
	$(PYTHON3) $(script)/overlap.py -c 1 -f $(indir)/Alignment/*/*.map.stat.xls |grep -v "#name"|sed 's/miss/0/g' > $(outdir)/All.map.stat.raw.xls
	sed -i '/Uniq/d' $(outdir)/All.map.stat.raw.xls
	sed '/Duplication/d' $(outdir)/All.map.stat.raw.xls >$(outdir)/All.map.stat.xls
	$(Rscript) $(script)/barplot.r $(outdir)/All.map.stat.xls $(outdir) 1,7,14 'Percentages(%)'  All.map.stat dodge p '' ''
	convert $(outdir)/All.map.stat.pdf $(outdir)/All.map.stat.png
	@echo
	@echo `date "+%Y-%m-%d %H:%M:%S"` "-MAP_STAT_QC-INFO- ####### MAP_STAT_QC End"
	@echo
