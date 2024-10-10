#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);
my $version = "1.0";
###########################################################

my $usage = << "USAGE";

    Description: Count SV and plot.
    Contact:     Meng Hao  <haomeng\@genome.cn>
    Version:     $version

    Usage: perl $0 -indir indir -file annofile -sampleID sanpleID -outdir outdir

        -file       <must|file>      The anno variant file
        -sampleID   <must|str>       Sample name
        -outdir     <must|dir>       The output directory (absolute directory)
USAGE

#GetOptions------------------------------------------------
my ( $file, $outdir,$sampleID );
GetOptions(
    "file=s"   =>   \$file,
    "outdir=s" =>   \$outdir,
    "sampleID=s" => \$sampleID,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

open LIST, "<", "$file";
my $count    = 0;
while (<LIST>) {
    chomp;
    next if $_ =~ /^#/;
    $count++;
}
close LIST;

open OUT, ">", "$outdir/$sampleID.SV.num.txt";
print OUT "Sample\t$sampleID\n";
print OUT "SV\t$count\n";
close OUT;


