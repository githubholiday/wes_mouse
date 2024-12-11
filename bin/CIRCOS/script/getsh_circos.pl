#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;
use Data::Dumper;

my $Description=my $usage =<<usage;
Usage :
        Function :
            The data of CIRCOS
        Author  :
                Jing Wang
        Date :
                20161015
		Usage:
				perl thisperl -joblist -bin -outdir_sh -type -include -chomys and the inputfiles in joblist file ;

usage

my ($joblist,$include,$SAMPLE,$config1,$fusion_infile,$fusion_sample,$outdir_sh,$snp_infile,$chomys,$outdir,$indel_infile,$fusion_normal_indir,$fusion_tumor_indir,$tumor_sample,$normal_sample,$CNV_infile,$LOH_infile,$SV_infile,$bin,$type,$help);
$config1="";
GetOptions(
    "joblist:s"=>\$joblist,
	"include:s"=>\$include,
	"type:s"=>\$type,
	"snp_infile:s"=>\$snp_infile,
	"chomys:s"=>\$chomys,
	"outdir:s"=>\$outdir,
	"indel_infile:s"=>\$indel_infile,
	"fusion_normal_indir:s"=>\$fusion_normal_indir,
	"fusion_tumor_indir:s"=>\$fusion_tumor_indir,
	"tumor_sample:s"=>\$tumor_sample,
	"normal_sample:s"=>\$normal_sample,
	"CNV_infile:s"=>\$CNV_infile,
	"LOH_infile:s"=>\$LOH_infile,
	"SV_infile:s"=>\$SV_infile,
	"fusion_infile:s"=>\$fusion_infile,
	"fusion_sample:s"=>\$fusion_sample,
	"bin:s"=>\$bin,
	"outdir_sh:s"=>\$outdir_sh,
	"config1:s"=>\$config1,
	"SAMPLE:s"=>\$SAMPLE,
    "help:s"=>\$help);
die "$Description" unless (($joblist && $outdir && $bin && $outdir_sh && $include && $type && $SAMPLE)|| $help );
open Joblist,"<$joblist" or die $!;
open Joblist_out,">$outdir_sh/circos.sh" or die $!;
my $row=0;
while(<Joblist>){
	chomp;
	my @job=split/\t/,$_;
	if ($row == 0){
		print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include  outdir=$outdir DATA1";
		print Joblist_out ";\n";
   }else{
		if($job[0] eq "SNP_INDEL"){
			print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include outdir=$outdir snp_infile=$snp_infile indel_infile=$indel_infile chomys=$chomys outdir=$outdir SNP_INDEL";
			print Joblist_out ";\n";
		}
		elsif ($job[0] eq "Fusion"){
			if ($type eq "pair"){
				print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include fusion_normal_indir=$fusion_normal_indir fusion_tumor_indir=$fusion_tumor_indir tumor_sample=$tumor_sample normal_sample=$normal_sample outdir=$outdir Fusion_pair";
				print Joblist_out ";\n";}
			elsif($type eq "single"){
				print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include fusion_infile=$fusion_infile fusion_sample=$fusion_sample outdir=$outdir Fusion_single";
				print Joblist_out ";\n";
			}
		}
		elsif ($job[0] eq "CNV"){
			print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include  CNV_infile=$CNV_infile outdir=$outdir CNV";
			print Joblist_out ";\n";
		}
		elsif($job[0] eq "LOH"){
			print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include LOH_infile=$LOH_infile outdir=$outdir LOH";
			print Joblist_out ";\n";
		}
		elsif($job[0] eq "SV"){
			print Joblist_out "make -f $bin/makefile_CIRCOS_DATA.mk --include-dir $include SV_infile=$SV_infile outdir=$outdir SV";
			print Joblist_out ";\n";
		}
		elsif(($job[0] ne "SNP_INDEL") && ($job[0] ne "Fusion") && ($job[0] ne "CNV") && ($job[0] ne "LOH") && ($job[0] ne "SV")){
			next;
		}
		else{
		}
	}
	$row++;
}

if( $config1 ne ""){
	print  Joblist_out "make -f $bin/makefile_CIRCOS_Figure.mk --include-dir $include joblist=$joblist outdir=$outdir chomys=$chomys config1=$config1 SAMPLE=$SAMPLE CIRCOS1;" ;}
elsif ($config1 eq ""){
	print Joblist_out "make -f $bin/makefile_CIRCOS_Figure.mk --include-dir $include joblist=$joblist outdir=$outdir chomys=$chomys SAMPLE=$SAMPLE  CIRCOS1;" ;
}
close Joblist;
close Joblist_out;


