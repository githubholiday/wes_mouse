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

        -file       <must|file>      The anno variant file
        -sampleID   <must|str>       Sample name
        -outdir     <must|dir>       The output directory (absolute directory)
USAGE

#GetOptions------------------------------------------------
my ( $file, $outdir,$sampleID );
GetOptions(
    "file=s"     => \$file,
    "outdir=s"   => \$outdir,
	"sampleID=s" => \$sampleID,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

my %var_region;
my %sv_length;

########load file;

my $name     = basename $file;
my $total = 0;
open( IN, "$file" ) || die "can't open file $file \n";
while (<IN>) {
	chomp;
    next if ( /^$/ || /^\#/ || /Alt/ );
    my ( $chr, $start, $end, $ref, $alt, $Func_knownGene, $Gene_knownGene, $GeneDetail_knownGene, $ExonicFunc_knownGene, @tmp ) = split /\t/, $_;
    $total++;
    $var_region{$Func_knownGene}++;
    my $len = ( length($ref) > length($alt) ) ? length($ref) : length($alt);
    $sv_length{$len}++;
}

###
my $stat = "$outdir/$sampleID" . ".SV";
my @stand = (
	"UTR5",                "UTR3",
    "UTR5;UTR3",           "exonic",
    "splicing",            "exonic;splicing",
    "upstream",            "downstream",
    "upstream;downstream", "intronic",
    "intergenic",          "ncRNA_UTR3",
    "ncRNA_UTR5",          "ncRNA_exonic",
    "ncRNA_splicing",      "ncRNA_intronic"
);
my $output;
my $other = 0;
my %pdf;

if ($total==0){
	my $stat1        = $stat . ".genome.region.stat.txt";
	open( O1, ">$stat1" ) || die "can't creat file $stat1\n";
	print O1 "#$sampleID\tNumber\tPercent(%)\nTotal\t0\t0\n";
	close O1;
}else {
	foreach my $s (@stand) {
		$var_region{$s} = 0 if ( !exists $var_region{$s} );
		my $per = H_format( $var_region{$s} / $total * 100 );
		$output .= "$s\t" . H_format( $var_region{$s} ) . "\t" . $per . "\n";
		$pdf{ ( split /;|_/, $s )[0] } += $var_region{$s};
		delete $var_region{$s};
	}

	foreach my $s ( keys %var_region ) {
		$other += $var_region{$s};
	}

	my $per = $other / $total * 100;
	$output .= "other\t" . H_format($other) . "\t" . H_format($per) . "\n";
	my $format_total = H_format($total);
	my $stat1        = $stat . ".genome.region.stat.txt";
	open( O1, ">$stat1" ) || die "can't creat file $stat1\n";
	print O1 "#$sampleID\tNumber\tPercent(%)\nTotal\t$format_total\t100.00\n$output";
	close O1;

	my $pdf1 = $stat . ".genome.region.stat.picture.list";
	open( P, ">$pdf1" ) || die "can't creat file $pdf1\n";
	print P "Type\t$sampleID\n";
	foreach my $s ( sort keys %pdf ) {
		my $p = 0;
		$p = H_format( $pdf{$s} / $total * 100 ) if ( $total != 0 );
		print P "$s\t$p\n";
	}

	my $p = 0;
	$p = H_format( $other / $total * 100 ) if ( $total != 0 );
	print P "other\t$p\n";
	close P;
}

sub H_format {
    my $tmp = $_[0];

    if ( $tmp =~ /^\d*\.\d*$/ ) {
        $tmp = sprintf( "%0.2f", $tmp );
        return $tmp;
    }
    elsif ( $tmp =~ /^\d+$/ ) {
        $tmp = reverse $tmp;
        $tmp =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
        return reverse($tmp);
    }
    else {
        return $tmp;
    }
}
