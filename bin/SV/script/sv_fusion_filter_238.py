#Function: extract fusion gene from SV result

import argparse
import os
import re

#Parse arguments
parser = argparse.ArgumentParser(description="Extract fusion gene from SV result")
help_desc = "The input list of files containing different kinds of SV results, seperated by one space and enclosed by \"\", required"
parser.add_argument("--input_list", help=help_desc, required=True)
help_desc = "The input file containing gene model annotation at hg19 version in BED format, required"
parser.add_argument("--input_BED", help=help_desc, required=True)
help_desc = "The sample class, required, please input \"single\" or \"pair\""
parser.add_argument("--sample_class", help=help_desc, required=True, choices=["single", "pair"])
help_desc = "The output directory, required"
parser.add_argument("--output_dir", help=help_desc, required=True)
args = parser.parse_args()

input_list = args.input_list
input_BED = args.input_BED
sample_class = args.sample_class
output_dir = args.output_dir

#Step 1: concatenate all input files containing different kinkds of SV results into one
os.system("/annoroad/data1/software/bin/miniconda/envs/WES_circos/bin/bcftools view  %s >%s/all_SV.vcf" %(input_list,output_dir))

#Step 2: extract reliable SV result and transform it into BED format
with open("%s/all_SV.vcf" %output_dir) as input_file, open("%s/all_SV_filtered.bed" %output_dir, "w") as output_bed_file, open("%s/all_SV_filtered.vcf" %output_dir, "w") as output_vcf_file:
  for line in input_file:
    if re.search("^##", line):
      output_vcf_file.write(line)
    elif re.search("^#", line):
      output_vcf_file.write(line)
      field = line.strip("\n").split("\t")
    else:
      content = line.strip("\n").split("\t")
      items = zip(field, content)
      item = {}
      for (name, value) in items:
        item[name] = value
      filter1 = item["FILTER"]
      filter2 = item["INFO"].split(";")[0]
      #Filter 1
      if filter1 == "PASS":
        chrom = item["#CHROM"]
        pos = item["POS"]
        id = item["ID"] + "_1"
        id2 = item["ID"] + "_2"
        type = re.search("(\S+?)\d+", id).group(1)
        info_set = item["INFO"].split(";")
        info_name__info_value = {}
        for each_info in info_set:
          if len(each_info.split("=")) == 2:
            info_name, info_value = each_info.split("=")
            info_name__info_value[info_name] = info_value
        if "CHR2" in info_name__info_value:
            chrom2 = info_name__info_value["CHR2"]
        else:
            chrom2 = chrom
        pos2 = info_name__info_value["END"]
        format_set = item["FORMAT"].split(":")
        if sample_class == "pair":
          value_set = content[-2].split(":")
        if sample_class == "single":
          value_set = content[-1].split(":")
        GT = value_set[format_set.index("GT")]
        #Filter 2
        if GT == "0/0":
          continue
        pair_depth = int(value_set[format_set.index("DR")]) + int(value_set[format_set.index("DV")])
        if pair_depth == 0:
          pair_freq = "NA"
        else:
          pair_freq = float(value_set[format_set.index("DV")]) / float(pair_depth)
          pair_freq = "%.4f" %pair_freq
        read_depth = int(value_set[format_set.index("RR")]) + int(value_set[format_set.index("RV")])
        if read_depth == 0:
          read_freq = "NA"
        else:
          read_freq = float(value_set[format_set.index("RV")]) / float(read_depth)
          read_freq = "%.4f" %read_freq
        output_info = ";".join(["GT=%s" %GT, "pair_depth=%s" %pair_depth, "pair_freq=%s" %pair_freq, "read_depth=%s" %read_depth, "read_freq=%s" %read_freq])
        output_content1 = "\t".join([chrom,str(int(pos)-1),pos,id,type,output_info])
        output_content2 = "\t".join([chrom2,str(int(pos2)-1),pos2,id2,type,output_info])  
        #For input single sample, more filters should be added
        #Filter 3
        if sample_class == "single" and read_freq != "NA" and int(read_depth) >= 50 and float(read_freq) >= 0.5 and filter2 == "PRECISE":
          output_vcf_file.write(line)
          output_bed_file.write("%s\n" %output_content1)
          output_bed_file.write("%s\n" %output_content2)
        if sample_class == "pair":
          output_vcf_file.write(line)
          output_bed_file.write("%s\n" %output_content1)
          output_bed_file.write("%s\n" %output_content2)

#Step 3: intersect BED format SV result with gene model
os.system("/annoroad/data1/software/bin/miniconda/envs/WES_circos/bin/bedtools intersect -a %s/all_SV_filtered.bed -b %s -wao > %s/all_SV_filtered.overlap.gene_model.tsv" %(output_dir,input_BED,output_dir))

#Step 4: extract fusion gene and output it
#Step 4.1: extract SV information and its related gene name, while store them into dictionaries
with open("%s/all_SV_filtered.overlap.gene_model.tsv" %output_dir) as input_file:
  id__break__info = {}
  id__break__gene = {}
  for line in input_file:
    content = line.strip("\n").split("\t")
    id = content[3]
    id_head = re.search("(\S+)_[12]", id).group(1)
    SVInfo = "\t".join([content[0],content[2],content[4],content[5]])
    gene = content[9]
    if not id_head in id__break__info.keys():
      id__break__info[id_head] = {}
      id__break__gene[id_head] = {}
    if re.search("_1", id):
      id__break__info[id_head]["1"] = SVInfo
      if not "1" in id__break__gene[id_head].keys():
        id__break__gene[id_head]["1"] = []
      id__break__gene[id_head]["1"].append(gene)
    if re.search("_2", id):
      id__break__info[id_head]["2"] = SVInfo
      if not "2" in id__break__gene[id_head].keys():
        id__break__gene[id_head]["2"] = []
      id__break__gene[id_head]["2"].append(gene)
#Step 4.2: output fusion gene
with open("%s/fusion_gene_list.tsv" %output_dir, "w") as output_file:
  output_file.write("SV_type\tfusion_gene1\tfusion_gene2\tfusion_break1\tfusion_break2\n")
  for each_id in sorted(id__break__gene.keys()):
    for each_gene1 in id__break__gene[each_id]["1"]:
      for each_gene2 in id__break__gene[each_id]["2"]:
        #Filter 4
        if each_gene1 == each_gene2:
          continue
        output_content = "\t".join([id__break__info[each_id]["1"].split("\t")[2], each_gene1, each_gene2, ":".join(id__break__info[each_id]["1"].split("\t")), ":".join(id__break__info[each_id]["2"].split("\t"))])
        output_file.write("%s\n" %output_content)
