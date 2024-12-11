##########Get the dirframe of pipeline
## |-- bin
## |   |-- config   ：配置文件
## |   |-- makefile ：makefile
## |   |-- pipe
## |   `-- script ：程序
## |-- database
## |-- doc
## `-- software

mkfdir=$(dir $(firstword $(MAKEFILE_LIST)))
name=$(notdir $(firstword $(MAKEFILE_LIST)))
script=$(mkfdir)../script
database=$(mkfdir)../../database
soft=$(mkfdir)../../software
config1=$(config)
ifndef $(config1)
	config1=$(mkfdir)../config/config.txt
endif

##########Define the dirframe of output
outdirf=$(outdir:/=)
middled=$(outdirf)/Middle

include $(config1)
