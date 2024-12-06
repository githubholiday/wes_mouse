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

    Usage: perl $0 -indir indir -file annofile -sampleID sanpleID -outdir outdir

        -file   <must|file>      The anno variant file 
		-sampleID <must|sampleID>
        -outdir  <must|dir>      The output directory (absolute directory)
USAGE

#GetOptions------------------------------------------------
my ( $file, $outdir,$sampleID );
GetOptions(
    "file=s"   => \$file,
    "outdir=s" => \$outdir,
	"sampleID=s" => \$sampleID,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

open LIST, "<", "$file";
my $count= 0;
while (<LIST>) {
    chomp;
    next if $_ =~ /^#/;
    $count++;
}
close LIST;
 
open OUT, ">", "$outdir/$sampleID.SNP.count.picture.list";
print OUT "Sample\t$sampleID\n";
print OUT "SNP\t$count\n";
close OUT;

#system("$Rscript $Bin/../common/barplot.r $outdir/$sampleID.SNP.count.picture.list $outdir/$sampleID.SNP.count.pdf '' 'Number of SNP' T NULL NULL");
#system("convert $outdir/$sampleID.SNP.count.pdf $outdir/$sampleID.SNP.count.png");


