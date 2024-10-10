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
	-annovar <must|file>	/annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/DNA/Exome/ANYN160001/YN160001-01/hanxuelian/Analysis/result/Ftp/SNP_INDEL_Combined/BL45-PASS-SNP_INDEL-Filter.hg19_multianno.xls
	-result <must|dir>	/annoroad/data1/bioinfo/PMO/wangjing/annovar_annotation.txt

	Example1: perl $0 -hgmd ./col6.list -annovar sample1.vcf -result ./result.xls
USAGE

my ($adf,$result,$help);
GetOptions(
	"result:s"=>\$result,
	"adf:s"=>\$adf,
	"help:s"=>\$help);
die "$Description" unless (($adf && $result) || $help);
open ADF,"<$adf" or  die "fail read $adf:$!\n";
open RESULT,">$result" or  die "fail read $result:$!\n";
my $row_no=0;
while(<ADF>){
	s/[\n\r]//g;
	my @mutation=split/\t/,$_;
#-------replace '/','(',')'-------#
	$mutation[5]=~s/\//\t/;
	$mutation[5]=~s/\(/\t/;
	$mutation[5]=~s/\)//;
#-------the last element of array-------#
	 my $genotype=pop @mutation;
	my $Hom=0;
	my $Hem=0;
#------- define the homozygote or heterozygous------#
	if($genotype=~m/1\/1/){
		$Hom=1;
	}else{
		$Hem=1;
	}
	if ($row_no > 0){
		foreach(@mutation[0..5]){
			print RESULT "$_\t";
		}
		print RESULT "$Hom\t$Hem\t";
		foreach(@mutation[6..$#mutation]){
			print RESULT "$_\t";
		}
		print RESULT "$genotype\n"
	}
	else
	{
		foreach(@mutation[0..4]){
			print RESULT "$_\t";
		}
		print RESULT "RefDepth\tAltDepth\tAltFre\tHom\tHem\t";
		foreach(@mutation[6..$#mutation]){
			print RESULT "$_\t";
		}
		print RESULT "$genotype\n";
	}
	$row_no++;
}

close ADF;
close RESULT;
