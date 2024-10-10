#!usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $Description=<<USAGE;

Note:

	********************************************
		Source: Annoroad
		Editor: Jing Wang
		date:   20160720

USAGE:
	-hgmd   <must|file> 	/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/DNA/Resequence/ngs_bioinfo/dna-3/hanxuelian/Analysis/modified_20160519/HGMD/HGMD.2011.2.SNP-hg19.database
	-annovar <must|file> 	/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/DNA/Exome/ANYN160001/YN160001-01/hanxuelian/Analysis/result/Ftp/SNP_INDEL_Combined/BL45-PASS-SNP_INDEL-Filter.hg19_multianno.xls
	-result <must|file> 	/annoroad/data1/bioinfo/PMO/wangjing/annovar_annotation.txt
	-position <must|parameter>	the place of the added columns (the range from 0 to 146)

	Example1: perl $0 -hgmd ./col6.list -annovar sample1.vcf -result ./result.xls -position 5
USAGE

my ($hgmd,$annovar,$result,$help,$position);
GetOptions(
	"result:s"=>\$result,
	"hgmd:s"=>\$hgmd,
	"annovar:s"=>\$annovar,
	"help:s"=>\$help,
	"position:s"=>\$position);
die "$Description" unless (($hgmd && $annovar && $result && $position) || $help);
open HGMD,"<$hgmd" or  die "fail read $hgmd:$!\n";
open ANNOVAR,"<$annovar" or  die "fail read $annovar:$!\n";
open RESULT,">$result" or  die "fail read $result:$!\n";
my $row_no=0;
my %disease=();
my %pubmed=();
my $col=0;
my $position1=$position+1;
while(<HGMD>){
	s/[\n\r]//g;
	my @entry=split/\t/,$_;
	$disease{$entry[0]}=$entry[12];
	$pubmed{$entry[0]}=$entry[14];
	}
my $row=0;
open ANNOVAR,"<$annovar" or  die "fail read $annovar:$!\n";
while(<ANNOVAR>){
	s/[\n\r]//g;
	my@mutation=split/\t/,$_;
	my $genotype=pop @mutation;
	if ($row_no > 0){
		foreach(@mutation[0..$position]){
			print RESULT "$_\t";
		}
		if (exists $disease{$mutation[$col]}){
			print RESULT "$disease{$mutation[$col]}\t";
		}else{ 
			print RESULT "\.\t";
		}
		if (exists $pubmed{$mutation[$col]}){
			print RESULT "$pubmed{$mutation[$col]}\t";
		}else{
			print RESULT "\.\t";
		}
		foreach(@mutation[$position1..$#mutation]){
			print RESULT "$_\t";
		}
		print RESULT "$genotype\n"
	}else{
		foreach(@mutation[0..$position]){
			print RESULT "$_\t";
		}
#------HGMD database------# 
		print RESULT "HGMD_Disease_ID\tHGMD_Pubmed\t";
		foreach(@mutation[$position1..$#mutation]){
			print RESULT  "$_\t";
		}
		print RESULT "$genotype\n";
		for(my $position_col=0;$position_col<@mutation;$position_col++){
			if($mutation[$position_col] eq "snp138"){
			$col=$position_col;
			print "$col\n";
			}else{
			}
		}
		if ($col==0){
		print "Error Nofind snp138 database\n";
		}
	}
	$row_no++;
}
close HGMD;
close ANNOVAR;
close RESULT;
