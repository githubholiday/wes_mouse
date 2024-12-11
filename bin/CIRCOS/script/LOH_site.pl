#! /usr/perl/bin -w
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;


my $help=<<USAGE;
USAGE:
	-infile           //result/      
	-outfile
USAGE
print $help;
my $infile = shift;
my $outfile = shift;
open IN,"$infile" or die $!;
open OUT,">$outfile" or die $!;
while (<IN>){
chomp;
my @CNV=split(/\t/,$_);
print OUT "hs$CNV[0]\t$CNV[1]\t$CNV[1]\t$CNV[2]\t"."fill_color=\(255,116,140\),stroke_color=\(255,116,140\)\n";
}
close IN;
close OUT;
