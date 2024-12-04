#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Long;
use FindBin qw($Bin);

my ($indir,$sample,$len,$std,@standard,$outdir,$transpose);

GetOptions(
    "h|help|?"=>\&USAGE,
    "i=s"=>\$indir,
    "s=s" => \$sample,
    "l=s"=>\$len,
    "d=s"=>\$std,
    "o=s"=>\$outdir,
    "t=s"=>\$transpose,
);
&USAGE unless ($indir and $sample and $len and $outdir and $transpose);

###################################################################

unless ( $std ){
    @standard = (1,4,10,15,20,25,30,50);
}else{
    @standard = split(/,/,$std);
}

my %cov;
my @cumu_depths = glob("$indir/$sample*sample_cumulative_coverage*");
my @site_depths = glob("$indir/$sample*sample_statistics");
my @summary = glob("$indir/$sample*sample_summary");

#########################统计累计深度分布#########################
open DEPTH, "cat @cumu_depths  |$transpose -t |" or die "$!";
open DEPTHOUT, ">$outdir/$sample.sum.depth.xls" or die "can not write to $outdir/$sample.sum.depth.xls";
print DEPTHOUT "Depth\tPercentage\tSum\n";
<DEPTH>;
while(<DEPTH>){
	chomp;
	my @arr = split /\t/;
	my ($depth) = $arr[0]=~/gte_(\d+)/;
	my $rate = sprintf("%d",$arr[3]*100);
	print DEPTHOUT "$depth\t$rate\t$arr[1]\n";
}
close DEPTH;
close DEPTHOUT;

########################统计碱基深度分布##########################
open SITE, "$transpose -t @site_depths |" or die "$!";
open SITEOUT,">$outdir/$sample.site.depth.xls" or die "can not write to $outdir/$sample.site.depth.xls";
print SITEOUT "Depth\tPercentage\tTotal_Position\n";
while(<SITE>){
	chomp;
	next if $_ =~ /^Source_of_reads/;
	my @arr = split /\t/;
	my ($depth) = $arr[0] =~ /from_(\d+)_to_.*/;
	my $percent = sprintf("%.2f",$arr[1]/$len*100);
	print SITEOUT "$depth\t$percent\t$arr[1]\n";

	foreach my $k ( @standard ){
	    if ( $depth >= $k ){
	 	$cov{$k} += $arr[1];
	    }
	}

}
close SITE;
close SITEOUT;

#######################统计覆盖度#################################
my $meandepth = 0;
my $target_mapped_bases = 0;
open SUMMARY ,$summary[0] or die "$!";
open COVOUT,">$outdir/$sample.coverage.xls" or die "can not write to $outdir/$sample.coverage.xls";

while(<SUMMARY>){
	chomp;
	next if $_ =~ /^sample_id|Total/;
	my @arr = split /\t/;
	$target_mapped_bases = $arr[1];
	$meandepth = $arr[2];
}
close SUMMARY;


print COVOUT "Bases Mapped to Target Region\t$target_mapped_bases\n";
print COVOUT "Mean Depth\t$meandepth\n";


foreach my $key ( sort { $a <=> $b } keys %cov ){
	my $cov_rate = sprintf("%.2f",$cov{$key}/$len*100);
    	print COVOUT "Coverage Rate  (%) (>="."$key"."X)"."\t"."$cov_rate\n";
}
close COVOUT;


########################SUB FUNCTIONS###########################
sub USAGE{
	my $usage=<<"USAGE";
Program : $0

Version: v1

Contactor: jiangdezhi(dezhijiang\@genome.cn);

Usage: perl $0 [options]

Options:
	-help|h|?	help
	-i		input directory (force)
	-l  		exon array length (force)
	-s		sample name (force)
	-o		output directory (force)
	-d 		depth coverage list, separated by "," ( optional) [ default : 1,4,10,20,30,50 ]

Example:
	perl $0 -i /annoroad/data1/bioinfo/PMO/jiangdezhi/test/coverage_mean_stat/cover_by_raw_bam.sh.qsub -l 60456963  -s A -o /annoroad/data1/bioinfo/PMO/jiangdezhi/test/coverage_mean_stat/cover_by_raw_bam.sh.qsub/test  -d 1,4,10,20,30,50

USAGE
	print "$usage\n";
	exit 0;
}
