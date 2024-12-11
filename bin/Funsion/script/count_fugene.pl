#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);
my $version = "1.0";
###########################################################

my $usage = << "USAGE";

    Usage: perl $0 -indir indir -file annofile -sample sampleID -outdir outdir

        -file      <must|file>      The anno variant file 
        -sample    <must|str>       The sample name 
        -outdir    <must|dir>       The output directory (absolute directory)
USAGE

#GetOptions------------------------------------------------
my ( $file, $outdir,$sample );
GetOptions(
    "file=s"   => \$file,
    "outdir=s" => \$outdir,
	"sample=s" => \$sample,
    "h"
);
die $usage if ( !defined $file || !defined $sample|| !defined $outdir );

#----------------------------------------------------------

open LIST, "<", "$file";
my $count= 0;
while (<LIST>) {
    chomp;
    next if $_ =~ /^SV_type/;
    $count++;
}
close LIST;
 
open OUT, ">", "$outdir/$sample.FuGene.stat.txt";
print OUT "Sample\t$sample\n";
print OUT "Fusion Gene\t$count\n";
close OUT;
