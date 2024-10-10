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

my $name     = basename $file;
my @INV = ('INV');
my @DUP = ('DUP');
my @DEL = ('DEL');
my @INS = ('INS');
#my @TRA = ('TRA');

open( IN, "$file" ) || die "can't open file $file \n";
my ( $len, $sv_type );
while (<IN>) {
    next if $_ =~ /^#/;
    next if $_ !~ /^chr/;
    chomp;
    my @line = split (/\t/, $_);
    ( $sv_type = $line[4] ) =~ s/\<(\w+)\>/$1/;   
    my @info = split /;/, $line[7];
    ( $len = $info[0] ) =~ s/SVLEN=(-?)(\d+)/$2/;
    push (@INV, $len) if $sv_type eq "INV";
    push (@DUP, $len) if $sv_type eq "DUP";
    push (@DEL, $len) if $sv_type eq "DEL";
    push (@INS, $len) if $sv_type eq "INS";
    # push (@TRA, $len) if $sv_type eq "TRA";
    #print "$sv_type\t$len\n"; 
}
close IN;

open INV, ">$outdir/$sampleID.inv.tmp";
open DUP, ">$outdir/$sampleID.dup.tmp";
open DEL, ">$outdir/$sampleID.del.tmp";
open INS, ">$outdir/$sampleID.ins.tmp";
#open TRA, ">$outdir/$sampleID.tra.tmp";
print INV join ("\n", @INV);
print DUP join ("\n", @DUP);
print DEL join ("\n", @DEL);
print INS join ("\n", @INS);
#print TRA join ("\n", @TRA);
close INV;
close DUP;
close DEL;
close INS;
#close TRA;
`paste $outdir/$sampleID.inv.tmp $outdir/$sampleID.dup.tmp $outdir/$sampleID.del.tmp $outdir/$sampleID.ins.tmp > $outdir/$sampleID.SV.length.stat.txt`;
`rm $outdir/*.tmp`;
#`$Rscript $Bin/../common/twohist.R $outdir/$sampleID.SV.length.stat.txt $outdir/$sampleID.SV.length.stat.pdf \'$sampleID\'`;
#`convert $outdir/$sampleID.SV.length.stat.pdf $outdir/$sampleID.SV.length.stat.png`;

