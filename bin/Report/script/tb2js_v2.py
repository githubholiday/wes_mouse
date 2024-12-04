#! /usr/bin/env python3
import argparse
import time
import sys
import re
import os
import json
import glob
import pandas as pd
from collections import OrderedDict
bindir = os.path.abspath(os.path.dirname(__file__))

__author__ = 'Liu Huiling'
__mail__ = 'huilingliu@genome.cn'
__doc__ = 'the description of program'

'''
将tab分隔的文本文件转换为js格式
读取数据时第一行和第一列作为header和index
通过 -t 参数可以设置表格文件转置行列后再转换js
'''
pat1 = re.compile('^\s+$')


def main():
    parser = argparse.ArgumentParser(usage='Convert text file to json file.',
                                     description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-i', '--indir', help='indir', dest='indir', required=True)
    parser.add_argument('-c', '--config', help='config file', dest='config', required=True)
    args = parser.parse_args()

    with open(args.config) as IN:
        for line in IN:
            if line.startswith('#'):
                continue
            tmp = line.rstrip().split('\t')
            files = glob.glob(tmp[0].replace('INDIR', args.indir))
            trans = tmp[1]
            for file in files:
                if not os.path.exists(file):
                    continue
                output = os.path.splitext(file)[0] + '.json'
                raw_df = pd.read_table(file, header=0, index_col=0, low_memory=False)
                if trans == 'yes':
                    tmp = output + '.tmp'
                    raw_df.T.to_csv(tmp, sep='\t', index_name=raw_df.index.name)
                    df = pd.read_table(tmp, header=0, index_col=0, low_memory=False)
                else:
                    df = raw_df

                df = pd.to_numeric(df, errors='ignore')
                flag = OrderedDict()
                flag.setdefault(raw_df.index.name, 0)
                dtype = OrderedDict()

                for col in df.columns:
                    dtype[col] = df[col].dtype

                for key, value in dtype.items():
                    flag[key] = 0
                    if str(value) == 'float64' or str(value) == 'int64':
                        flag[key] = 1

                dict = OrderedDict()
                dict = df.to_dict(orient='split')

                result = OrderedDict()
                title_list = []
                for key, value in flag.items():
                    title_list.append('{0}:{1}'.format(key, value))
                result['title'] = title_list

                for index, value in enumerate(dict['data']):
                    dict['data'][index].insert(0, df.index[index])

                result['data'] = dict['data']
                json.dump(result, skipkeys=True, ensure_ascii=False, indent=4, fp=open(output, 'w'))

                if trans == 'yes':
                    os.system('rm -rf {0}'.format(tmp))


if __name__ == '__main__':
    main()
