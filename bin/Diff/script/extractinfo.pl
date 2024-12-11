#!/usr/bin/perl -w
use strict;
use warnings;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw($Bin);
use List::Util qw(max);
use Cwd;

my $help=<<USAGE;

USAGE:

    -indir    <must>    The overlaplist dir
    -group    <must>    The group name
    -type     <must>    SNP or INDEL
    -annodir  <must>    The annofiles dir
    -key      <must>    The key word of the annofile
    -outdir   <must>    The outputdir of the result

USAGE

my ($overlaplistdir,$group,$type,$annodir,$key,$outdir);

GetOptions
(
     "indir:s"   =>\$overlaplistdir,
     "group:s"   =>\$group,
     "type:s"    =>\$type,
     "annodir:s" =>\$annodir,
     "key:s"     =>\$key,
     "outdir:s"  =>\$outdir,
);
die "$help" unless( defined $overlaplistdir);
#------------------------声明变量--------------------------#
my @list=();
my @vars=();
my %sample_hash=();
my %site_hash=();
my %site_sample_hash=();
my @sample=();
my @anno=();
my $i=0;
#------------------------根据差异位点列表提取注释结果--------------------------#

@list=glob("$overlaplistdir/$group.*.overlap.list");

foreach my $file (@list){
    %sample_hash=();
	%site_sample_hash=();

	chomp $file;
	open(VAR, $file) or die;
	@vars=<VAR>;
	close (VAR);
	my $filename=basename $file;
	my $i=0;

	#print $#vars."\n";

	if ($#vars==-1){
		if ($filename=~/all.overlap.list/) {
			open (OUT,">$outdir/$group.all.overlap.$key");
		}
		elsif ($filename=~/1.overlap.list/) {
			open (OUT,">$outdir/$group.uniq.$key");
		}
		else{
			open (OUT,">$outdir/$group.empty.$key");
		}
		print OUT "\n";
		close (OUT);
		next;
	}

	foreach my $var_line (@vars){
		chomp $var_line;
		my @var_site=split(/\t/,$var_line);
		$sample_hash{$var_site[1]}++;
		my $info=$var_site[0];
		$site_sample_hash{$var_site[1]}{$info}++;
	}

	$i=0;
	foreach my $sample_key (keys %sample_hash){
		%site_hash=();
		@sample=split(/,/,$sample_key);
		my $sample_names=join "-",@sample;
		if ($filename=~/all.overlap.list/) {
			open (OUT,">$outdir/$group.$type.all.overlap.$key");
		}
		elsif ($filename=~/1.overlap.list/) {
			open (OUT,">>$outdir/$group.$type.uniq.$key");
		}
		else {
			open (OUT,">$outdir/$group.$type.$sample_names.overlap.$key");
			$i=0;
		}

		foreach my $site_key (keys %{$site_sample_hash{$sample_key}}){
			$site_hash{$site_key}++;
		}

		my $annohead="";
		foreach my $sam (@sample){
			my $annofile=`ls $annodir/$sam.$type.$key`;
			chomp $annofile;
			open ANNO, $annofile or die;
			@anno=<ANNO>;
			close (ANNO);

			foreach my $anno_line (@anno){
				chomp $anno_line;
				my @anno_info=split(/\t/,$anno_line);
				if ($anno_line=~/^Chr/){
					$annohead="#Sample\t$anno_line";
					if ($i==0){
						print OUT "$annohead\n";
						$i++;
						next;
					}else{next;}

				}
				my $anno_var="$anno_info[0]:$anno_info[1]_$anno_info[2]-$anno_info[3]:$anno_info[4]";
				if (exists $site_hash{$anno_var}){
					print OUT "$sam\t$anno_line\n";
				}else{next;}
			}
		}
		close (OUT);
	}
}

