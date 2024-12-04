#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);

my $usage = <<USAGE;

 USAGE:

 perl $Script -o <outdir> -c <config.ini>

      -o     The web report directory
      -c     The config.ini

USAGE

#GetOptions------------------------------------------------

my ( $outdir, $config );
GetOptions(
    "o=s" => \$outdir,
    "c=s" => \$config,
    "h"
);
die $usage if ( !defined $outdir || !defined $config );

#Main----------------------------------------------------------

my (%config, @samples, $sampleNum, $example, @joblist);

`mkdir -p $outdir/upload`;
my $upload_config = "$outdir/upload.config";
my $report_config = "$outdir/report.config";
my $repdir        = "$outdir/upload";

#读入config文件
open CONF, "$config" or die "Failed open $config!\n";
while (<CONF>) {
    chomp;
    next if $_ =~ /^\s*$/;
    my @line;
    if ( /=/ ) {
    	@line = split /=/, $_;
    }
    else {
    	next;
    }
    $line[0] =~ s/\s+//g;       #如果\s*则必须加g
    $line[1] =~ s/\s+//g;
    $config{$line[0]} = $line[1];
}
close CONF;

#读入样品文件
open SAML, "$config{Para_samplelist}" or die "Failed open $config{Para_samplelist}!\n";
while (<SAML>) {
    chomp;
    my $name = (split/\t/, $_)[1];
    push @samples, $name;
}
close SAML;
$sampleNum = @samples;
$example = shift @samples;

#写入report_config
open REPORT, ">", "$report_config";
print REPORT "PROJECT_NAME:$config{Para_project}\nPROJECT_ID:$config{Para_projectID}\nPROJECT_TYPE:Human Single-Cell Whole Genome Sequence Analysis Report\nSAMPLE_NUM:$sampleNum\nREPORT_DIR:$repdir\n";
close REPORT;

#Creat upload.conf------------------------
open JOB, "<", "$config{Para_joblist}" or die "Failed open $config{Para_joblist}!\n";
while (<JOB>) {
	chomp;
	next if /^\s*$/ || /^#/;
	push @joblist, $_;
}
close JOB;

#写入upload_config
open UPLOAD, ">", "$upload_config" or die "Failed open $upload_config\n";
if ( grep { "FQ" eq $_ } @joblist ) {
    print UPLOAD "[M]=数据处理\t1\n";
    print UPLOAD "[S]=原始数据过滤\t1\n";
    print UPLOAD "INDIR/FQ/Analysis/report/upload/1_filter/1_1_stat_table/filter*\tOUTDIR/upload/FQ/\tcopy\t1\n";
    print UPLOAD "[S]=过滤后数据量统计\t1\n";
    print UPLOAD "INDIR/FQ/Analysis/report/upload/1_filter/1_1_stat_table/*Bases.p*\tOUTDIR/upload/FQ/\tcopy\t1\n";
    print UPLOAD "[S]=过滤后数据的碱基含量分布\t1\n";
    print UPLOAD "INDIR/FQ/Analysis/report/upload/1_filter/1_3_base_content/*.base.p*\tOUTDIR/upload/FQ/\tcopy\t1\n";
    print UPLOAD "[S]=过滤后数据的碱基质量值分布\t1\n";
    print UPLOAD "INDIR/FQ/Analysis/report/upload/1_filter/1_2_base_quality/*.quality.p*\tOUTDIR/upload/FQ/\tcopy\t1\n";
    print UPLOAD "INDIR/FQ/Analysis/report/upload/1_filter/1_1_stat_table/Q30.p*\tOUTDIR/upload/FQ/\tcopy\t1\n";
}
if ( grep { "BWA" eq $_ } @joblist ) {
    print UPLOAD "[M]=比对及质控\t1\n";
    print UPLOAD "[S]=比对信息统计\t1\n";
    print UPLOAD "INDIR/Stat/All.map.stat.xls\tOUTDIR/upload/MAP/\tcopy\t1\n";
    print UPLOAD "INDIR/Stat/All.map.stat.p*\tOUTDIR/upload/MAP/\tcopy\t1\n";
    print UPLOAD "[S]=测序深度分布\t1\n";
    print UPLOAD "INDIR/Alignment/*/*_histPlot.png\tOUTDIR/upload/MAP/\tcopy\t1\n";
    print UPLOAD "INDIR/Alignment/*/*_histPlot.pdf\tOUTDIR/upload/MAP/\tcopy\t1\n";
    print UPLOAD "INDIR/Alignment/*/*_cumuPlot.png\tOUTDIR/upload/MAP/\tcopy\t1\n";
    print UPLOAD "INDIR/Alignment/*/*_cumuPlot.pdf\tOUTDIR/upload/MAP/\tcopy\t1\n";
}
if ( grep { "Uniformity" eq $_ } @joblist ) {
    print UPLOAD "[S]=测序均一性和覆盖度评估\t1\n";
    print UPLOAD "INDIR/Read_Distribution/*.reads.distribution.p*\tOUTDIR/upload/MAP/Uniformity/\tcopy\t1\n";
}
if ( grep { "SNP_INDEL" eq $_ } @joblist ) {
    print UPLOAD "[M]=变异检测注释\t1\n";
    print UPLOAD "[S]=SNP检测及注释\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/*.SNP.hg19_multianno.txt\tOUTDIR/upload/SNP/\tlink\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/*/*Format*.SNP.hg19_multianno.xls\tOUTDIR/upload/SNP/Samples/\tlink\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/Stat/*.SNP.TS_TV.stat.txt\tOUTDIR/upload/SNP/Stat/\tcopy\t1\n";
    print UPLOAD "INDIR/Stat/All.snp.*\tOUTDIR/upload/SNP/Stat/\tcopy\t1\n";

    print UPLOAD "[S]=InDel检测及注释\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/*.INDEL.hg19_multianno.txt\tOUTDIR/upload/InDel/\tlink\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/*/*Format*.INDEL.hg19_multianno.xls\tOUTDIR/upload/InDel/Samples/\tlink\t1\n";
    print UPLOAD "INDIR/Stat/All.indel.*\tOUTDIR/upload/InDel/Stat/\tcopy\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/Stat/*.INDEL.length.pattern.stat.png\tOUTDIR/upload/InDel/Stat/\tcopy\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_ANNO/Result/Stat/*.INDEL.length.pattern.stat.pdf\tOUTDIR/upload/InDel/Stat/\tcopy\t1\n";
}
if ( grep{"CNV_ControlFreec" eq $_} @joblist ) {
    print UPLOAD "[S]=CNV的检测及注释\t1\n";
    print UPLOAD "INDIR/CNV_ControlFreec/*/*.CNV.hg19_multianno.txt\tOUTDIR/upload/CNV_ControlFreec/\tcopy\t1\n";
    print UPLOAD "INDIR/CNV_ControlFreec/*/*.CNV.raw.xls\tOUTDIR/upload/CNV_ControlFreec/\tcopy\t1\n";
    print UPLOAD "INDIR/Stat/All.CNVs.num*\tOUTDIR/upload/CNV_ControlFreec/Stat/\tcopy\t1\n";
    print UPLOAD "INDIR/CNV_ControlFreec/*/*.CNV.pattern.p*\tOUTDIR/upload/CNV_ControlFreec/Stat/\tcopy\t1\n";
    print UPLOAD "INDIR/CNV_ControlFreec/*/*.CNV.stat.*\tOUTDIR/upload/CNV_ControlFreec/Stat/\tcopy\t1\n";
}
if ( grep{"SV" eq $_} @joblist ) {
    print UPLOAD "[S]=SV检测及注释\t1\n";
    print UPLOAD "INDIR/SV/*/*.SV.hg19_multianno.txt\tOUTDIR/upload/SV/\tcopy\t1\n";
    print UPLOAD "INDIR/Stat/All.sv.*\tOUTDIR/upload/SV/Stat/\tcopy\t1\n";
}
if ( grep{"Fusion" eq $_} @joblist ) {
    print UPLOAD "[S]=融合基因分析\t1\n";
    print UPLOAD "INDIR/Stat/All.Fugene*\tOUTDIR/upload/FusionGene/\tcopy\t1\n";
    print UPLOAD "INDIR/FusionGene/*FusionReport.txt\tOUTDIR/upload/FusionGene/\tcopy\t1\n";
}
if ( grep{"CIRCOS" eq $_} @joblist ) {
    print UPLOAD "[S]=变异总览\t1\n";
    print UPLOAD "INDIR/circos/*/*/*.png\tOUTDIR/upload/CIRCOS/\tcopy\t1\n";
}
if ( grep { "Somatic_SNP" eq $_ } @joblist ) {
	print UPLOAD "[M]=体细胞突变筛选\t1\n";
	print UPLOAD "[S]=Somatic-SNV筛选\t1\n";
	print UPLOAD "INDIR/Somatic_Variants/*/*SNP.somatic.hg19_multianno.txt\tOUTDIR/upload/Somatic_SNP/\tcopy\t1\n";
	print UPLOAD "INDIR/Stat/All.SomaticSNV.num*\tOUTDIR/upload/Somatic_SNP/\tcopy\t1\n";
}
if ( grep { "Somatic_INDEL" eq $_ } @joblist ) {
	print UPLOAD "[S]=Somatic-InDel筛选\t1\n";
	print UPLOAD "INDIR/Somatic_Variants/*/*INDEL.somatic.hg19_multianno.txt\tOUTDIR/upload/Somatic_INDEL/\tcopy\t1\n";
	print UPLOAD "INDIR/Stat/All.SomaticINDEL.num*\tOUTDIR/upload/Somatic_INDEL/\tcopy\t1\n";
}
if ( grep { "Conservation" eq $_ } @joblist ) {
	print UPLOAD "[S]=Somatic-SNV保守性预测和致病性分析\t1\n";
	print UPLOAD "INDIR/Conservation/*/*damage.hg19_multianno*\tOUTDIR/upload/Conservation/\tcopy\t1\n";
}
if ( grep { "DIFF" eq $_ } @joblist ) {
    print UPLOAD "[S]=体细胞突变差异分析\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_DIFF/SNP/Result/*\tOUTDIR/upload/SNP_INDEL_DIFF/SNP/\tcopy\t1\n";
    print UPLOAD "INDIR/SNP_INDEL_DIFF/INDEL/Result/*\tOUTDIR/upload/SNP_INDEL_DIFF/INDEL/\tcopy\t1\n";
}

if ( grep{"FNR_FPR" or "MUTATION_SIGNATURE" or "MutsigCV" or "Music" or "GisticCNV" or "PCA" or "oncoNEM" or "Phylip" or "Drug" or "Driver" eq $_} @joblist ) {
    print UPLOAD "[M]=高级分析\t1\n";
}
if ( grep{"FNR_FPR" eq $_} @joblist ) {
    print UPLOAD "[S]=ADO和FPR评估\t1\n";
    print UPLOAD "INDIR/FNR_FPR/ADO/Allelic_dropout_rate.p*\tOUTDIR/upload/FNR_FPR/ADO/\tcopy\t1\n";
    print UPLOAD "INDIR/FNR_FPR/FPR/False_positive_rate.p*\tOUTDIR/upload/FNR_FPR/FPR/\tcopy\t1\n";
}
if ( grep{"Driver" eq $_} @joblist ) {
    print UPLOAD "[S]=驱动基因分析\t1\n";
    print UPLOAD "INDIR/Driver/All_DriverGene.*\tOUTDIR/upload/Driver/\tcopy\t1\n";
}
if ( grep{"Drug" eq $_} @joblist ) {
    print UPLOAD "[S]=靶向药物分析\t1\n";
    print UPLOAD "INDIR/Gene_Drug/Drug_Target/*/*.xls\tOUTDIR/upload/Gene_Drug/Drug_Target/\tcopy\t1\n";
    print UPLOAD "[S]=药物反应分析\t1\n";
    print UPLOAD "INDIR/Gene_Drug/Drug_Response/*/*.xls\tOUTDIR/upload/Gene_Drug/Drug_Response/\tcopy\t1\n";
}
if ( grep{"MUTATION_SIGNATURE" eq $_} @joblist ) {
    print UPLOAD "[S]=体细胞突变特征分析\t1\n";
    print UPLOAD "INDIR/Mutation_Signature/Result/plotSignatures.*\tOUTDIR/upload/Mutation_Signature/\tcopy\t1\n";
    print UPLOAD "INDIR/Mutation_Signature/Result/cosine_similarity*.p*\tOUTDIR/upload/Mutation_Signature/\tcopy\t1\n";
    print UPLOAD "INDIR/Mutation_Signature/Result/signature_cosmic_anno.xls\tOUTDIR/upload/Mutation_Signature/\tcopy\t1\n";
}
if ( grep{"PCA_All" eq $_} @joblist ) {
    print UPLOAD "[S]=所有样品PCA分析\t1\n";
    print UPLOAD "INDIR/PCA_All/somatic_snp.PCA1_PCA2.*\tOUTDIR/upload/PCA/PCA_All/\tcopy\t1\n";
}
if ( grep{"PCA_Somatic" eq $_} @joblist ) {
    print UPLOAD "[S]=所有样品PCA分析\t1\n";
    print UPLOAD "INDIR/PCA_Somatic/somatic_snp.PCA1_PCA2.*\tOUTDIR/upload/PCA/PCA_Somatic/\tcopy\t1\n";
}
if ( grep{"oncoNEM" eq $_} @joblist ) {
    print UPLOAD "[S]=oncoNEM单细胞进化树分析\t1\n";
    print UPLOAD "INDIR/oncoNEM/*\tOUTDIR/upload/oncoNEM/\tcopy\t1\n";
}
if ( grep{"Phylip" eq $_} @joblist ) {
    print UPLOAD "[S]=Phylip单细胞进化树分析\t1\n";
    print UPLOAD "INDIR/Phylip/evoTree_phylip_format.p*\tOUTDIR/upload/Phylip/\tcopy\t1\n";
}
if ( grep{"Mutsigcv" eq $_} @joblist ) {
    print UPLOAD "[S]=高频突变分析\t1\n";
    print UPLOAD "INDIR/Mutsig/SMG.all.*\tOUTDIR/upload/Mutsig/\tcopy\t1\n";
}
if ( grep{"Music" eq $_} @joblist ) {
    print UPLOAD "[S]=高频突变基因互斥和协同性分析\t1\n";
    print UPLOAD "INDIR/Music/Mutation_relation.*\tOUTDIR/upload/Music/\tcopy\t1\n";
}
if ( grep{"GisticCNV" eq $_} @joblist ) {
    print UPLOAD "[S]=CNV分布和重现性分析\t1\n";
    print UPLOAD "INDIR/Gistic/*\tOUTDIR/upload/Gistic/\tcopy\t1\n";
}
# Phylip
close UPLOAD;
