#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import sys
import argparse
import configparser
import collections
__author__ = 'menghao'
__mail__ = 'haomeng@genome.cn'

bindir = os.path.abspath(os.path.dirname(__file__))
pat1 = re.compile('^\s*$')


class myconf(configparser.ConfigParser):

    def __init__(self, defaults=None):
        configparser.ConfigParser.__init__(self, defaults=None, allow_no_value=True)

    def optionxform(self, optionstr):
        return optionstr


def get_conf(config_file):
    LIST = []
    JOB = config_file.get('Para', 'Para_joblist')
    Pipetype = config_file.get('Para', 'Para_pipetype')
    Datatype = config_file.get('Para', 'Para_datatype')
    with open(JOB) as IN:
        for line in IN:
            if line.startswith('#') or re.search('^\s*$', line):
                continue
            LIST.append(line.rstrip())
    return LIST, Pipetype, Datatype


def get_title(joblist, match):
    Title = {}
    with open(match) as IN:
        for line in IN:
            if line.startswith('#') or re.search('^\s*$', line):
                continue
            tmp = line.rstrip().split('\t')
            if tmp[0] in joblist:
                Title.setdefault(tmp[1], [])
                Title[tmp[1]].extend(tmp[2].split(','))
    return Title


def get_template(template, pipetype, datatype):
    Dict = collections.OrderedDict()   #it does not work
    SUB = []
    with open(template) as IN:
        for line in IN:
            if line.startswith('#') or re.search('^\s*$', line):
                continue
            tmp = line.rstrip().split('\t')
            if not pipetype in tmp[-2].split(','):
                continue
            if not datatype in tmp[-1].split(','):
                continue
            if tmp[0].startswith('[M]'):
                main = re.search('\[M\]=(.*)', tmp[0]).group(1)
                Dict.setdefault(main, {})
                #Dict[main]
            elif tmp[0].startswith('[S]'):
                sub = re.search('\[S\]=(.*)', tmp[0]).group(1)
                SUB.append(sub)
                Dict.setdefault(main, {}).setdefault(sub, [])
                #Dict[main][sub] = []
            elif tmp[0].startswith('INDIR'):
                files = tmp[:-2]
                Dict[main][sub].append(files)
            else:
                continue
    return Dict, SUB


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog='author:\t{0}\nmail:\t{1}'.format(__author__, __mail__))
    parser.add_argument('-c', help='config.ini', dest='config', required=True)
    parser.add_argument('-o', help='outdir', dest='outdir', required=True)
    parser.add_argument('-m', help='item and title match file', dest='match', default=os.path.join(bindir, 'item_and_title.config'))
    parser.add_argument('-t', help='upload.config', dest='template', default=os.path.join(bindir, 'upload.config'))
    parser.add_argument('-cli', help='clinical', dest='clinical', action = 'store_true')
    args = parser.parse_args()

    os.makedirs(args.outdir,exist_ok=True)

    config = myconf()
    config.readfp(open(args.config, 'r'))

    joblist, pipetype, datatype = get_conf(config)
    
    genome = config.get('Para', 'Para_genome').lower()
    baoshou = "PolyPhen2_HDIV"
    baoshou_score = "0.957"
    if genome == "hg38":
        baoshou="ClinPred"
        baoshou_score="0.5"

    #########是否为动态报告###################
    if args.clinical:
        pipetype = 'clinical'
        datatype = 'report'

    title = get_title(joblist, args.match)

    template, SubMenu = get_template(args.template, pipetype, datatype)

    with open('{0}/upload.config'.format(args.outdir), 'w') as OUT:
        for main_title in template:
            if main_title in title:
                OUT.write('[M]={0}\t1\n'.format(main_title))
                for sub_title in [i for i in SubMenu if i in template[main_title]]:
                    if sub_title in title[main_title]:
                        OUT.write('[S]={0}\t1\n'.format(sub_title))
                        for file in template[main_title][sub_title]:
                            OUT.write('\t'.join(file) + '\n')

    with open('{0}/report.conf'.format(args.outdir), 'w') as OUT:
        PROJECT_NAME = config.get('Para', 'Para_project')
        PROJECT_ID = config.get('Para', 'Para_projectID')
        SAMPLE_NUM = config.get('Para', 'Para_samplenum')
        REPORT_DIR = args.outdir + '/upload'
        SNV_SOFTWARE = 'MuTect2(Cibulskis et al., 2013)'
        OUT.write('PROJECT_NAME:{0}\nPROJECT_ID:{1}\nSAMPLE_NUM:{2}\nSNV_SOFTWARE:{3}\nGENOME:{5}\nBAOSHOU:{6}\nBAOSHOU_SCORE:{7}\nREPORT_DIR:{4}\n'.format(PROJECT_NAME, PROJECT_ID, SAMPLE_NUM, SNV_SOFTWARE, REPORT_DIR,genome,baoshou,baoshou_score))
        #OUT.write('PROJECT_NAME:{0}\nPROJECT_ID:{1}\nSAMPLE_NUM:{2}\nREPORT_DIR:{3}\n'.format(PROJECT_NAME, PROJECT_ID, SAMPLE_NUM, REPORT_DIR))

if __name__ == "__main__":
    main()
