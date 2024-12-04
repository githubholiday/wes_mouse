#!/annoroad/share/software/install/Python-3.3.2/bin/python3
# -*- coding: utf-8 -*-
__func__ = """
1. 从注释文件gff中提取gene id和gene name对应关系，正则识别格式ID=geneid; Name=genename;
2. 增加gene name到输入文件的指定gene id的后一列，格式同gene id列，列名默认：Gene.name
3. gene name列，gene id存在gene name则进行替换，否则保留gene id信息
"""
import os
import sys
import re
import argparse

__author__ = 'leiguo'
__mail__ = 'leiguo@genome.cn'


def gff_reader(gff, gene_id, gene_name):
    '''
    read gff file, get gene_id and gene_name
    '''
    id_name = {}
    patt = '\W{}=([\w.-]+);?'
    id_patt = patt.format(gene_id)
    name_patt = patt.format(gene_name)

    with open(gff, 'r') as gf:
        for line in gf:
            if not line or line.startswith('#'): continue
            ID = re.findall(id_patt, line)
            name = re.findall(name_patt, line)
            if len(ID) and len(name):
                id_name[ID[0]] = name[0]
    return id_name


def main():
    parser = argparse.ArgumentParser(description='function: {0}\nauthor: {1}\nmail: {2}'.format(__func__, __author__, __mail__),
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-i', '--infile', help='infile that contains the gene id', dest='infile', required=True)
    parser.add_argument('-g', '--gene_id', help='输入文件gene_id所在列的表头名称，默认：Gene.ensGene', dest='gene_id',
                        default='Gene.ensGene')
    parser.add_argument('-n', '--gene_name', help='输出文件gene_name所在列的表头名称，默认：Gene.name', dest='gene_name',
                        default='Gene.name')
    parser.add_argument('-a', '--anno', help='anno file gff', dest='anno', required=True)
    parser.add_argument('-id', '--id', help='gff中gene id的标签名称，默认: ID', dest='id', default='ID')
    parser.add_argument('-name', '--name', help='gff中gene name的标签名称，默认：Name', dest='name', default='Name')
    parser.add_argument('-o', '--outfile', help='out file', dest='outfile', required=True)
    args = parser.parse_args()

    outdir = os.path.dirname(os.path.abspath(args.outfile))
    if not os.path.exists(outdir):
        os.system('mkdir -p {}'.format(outdir))

    id_name = gff_reader(args.anno, args.id, args.name)
    if len(id_name) == 0:
        print('在gff中没有识别到 {}= 和 {}= 信息，请确认'.format(args.id, args.name))
        print('输出结果将gene id拷贝成gene name')
        #sys.exit(1)

    out = open(args.outfile, 'w')
    with open(args.infile, 'r') as inf:
        for index, i in enumerate(inf):
            info = i.strip().split('\t')
            if index == 0:
                gene_id_col = info.index(args.gene_id)
                gene_name_col = gene_id_col + 1
                info.insert(gene_name_col, args.gene_name)
            else:
                gene_ids = re.split(',|;', info[gene_id_col])
                gene_names = info[gene_id_col]
                for i in gene_ids:
                    if i in id_name:
                        gene_names = gene_names.replace(i, id_name[i])
                info.insert(gene_name_col, gene_names)

            out.write('\t'.join(info) + '\n')
    out.close()


if __name__ == '__main__':
    main()

