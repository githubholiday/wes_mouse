#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import sys
import argparse
import configparser
import subprocess

__author__ = 'menghao'
__mail__ = 'haomeng@genome.cn'

bindir = os.path.abspath(os.path.dirname(__file__))
pat1 = re.compile('^\s*$')


class myconf(configparser.ConfigParser):

    def __init__(self, defaults=None):
        configparser.ConfigParser.__init__(self, defaults=None, allow_no_value=True)

    def optionxform(self, optionstr):
        return optionstr


def check_exists(content, Type):
    if Type == "file":
        if not os.path.isfile(content):
            sys.stderr.write('\n' + content + '文件不存在！\n')
            sys.exit(1)
    elif Type == 'dir':
        if not os.path.exists(content):
            os.makedirs(content)
    else:
        pass


def read_joblist(joblist):
    JOB = []
    with open(joblist) as jl:
        for line in jl:
            if line.startswith('#') or re.search(pat1, line):
                continue
            JOB.append(line.rstrip())
    return JOB


def read_template(template):
    Temp, Head = [], []
    with open(template) as temp:
        for line in temp:
            if line.startswith('#') or re.search(pat1, line):
                Head = line.rstrip().split('\t')
            else:
                Temp.append(line.rstrip().split('\t'))
    return Temp, Head


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog='author:\t{0}\nmail:\t{1}'.format(__author__, __mail__))
    parser.add_argument('-i', '--indir', help='readme dir', dest='indir', required=True)
    parser.add_argument('-o', '--outdir', help='outdir', dest='outdir', required=True)
    parser.add_argument('-c', '--config', help='config file', dest='config', required=True)
    parser.add_argument('-p', '--pipetype', help='pipetype', dest='pipetype', choices=['single', 'pair'], required=True)
    parser.add_argument('-d', '--datatype', help='datatype', dest='datatype', choices=['wgs', 'wes', 'target'], required=True)
    parser.add_argument('-t', '--template', help='template file', dest='template', default=os.path.join(bindir, 'readme_template.config'))
    args = parser.parse_args()

    check_exists(args.template, 'file')
    check_exists(args.config, 'file')

    # 获取并读取joblist
    config = myconf()
    config.readfp(open(args.config, 'r'))
    joblist = read_joblist(config.get("Para", "Para_joblist"))

    # 读取模板
    template, header = read_template(args.template)

    for job in joblist:
        if job in [i[0] for i in template]:
            index = [i[0] for i in template].index(job)
            readme = template[index][header.index('{0}_{1}'.format(args.pipetype, args.datatype))]
            Dir = template[index][header.index('upload_dir')]
            From = '{0}/{1}'.format(args.indir, readme)
            To = '{0}/{1}'.format(args.outdir, Dir)
            if os.path.exists(From) & os.path.exists(To):
                if subprocess.call('cp {0} {1}'.format(From, To), shell=True) != 0:
                    sys.stderr.write('cp {0} {1} failed!'.format(From, To))
            else:
                if not os.path.exists(From):
                    sys.stderr.write('{0} do not exists!\n'.format(From))
                if not os.path.exists(To):
                    sys.stderr.write('{0} do not exists!\n'.format(To))


if __name__ == "__main__":
    main()
