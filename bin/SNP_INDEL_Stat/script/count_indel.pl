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
    Contact:     Meng Hao  <haomeng\@annoroad.com>
    Version:     $version

    Usage: perl $0 -file annofile -sampleID sanpleID -outdir outdir -config config.txt

        -file       <must|file>        The anno variant file 
        -sampleID   <must|sampleID>
        -outdir     <must|dir>         The output directory (absolute directory)
        -config     <choose|file>

USAGE

#GetOptions------------------------------------------------
my ( $file, $outdir,$sampleID, $config );
GetOptions(
    "file=s"   => \$file,
    "outdir=s" => \$outdir,
	"sampleID=s" => \$sampleID,
    "config=s" => \$config,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

my $name     = basename $file;
my $count    = 0;
open IN, "<", "$file";
while (<IN>) {
	chomp;
	next if $_ =~ /^#/;
	next if $_ =~ /^Chr/;
	$count++;
}
close IN;

open OUT, ">", "$outdir/$sampleID.INDEL.count.picture.list";
print OUT "Sample\t$sampleID\n";
print OUT "InDel\t$count\n";
close OUT;
