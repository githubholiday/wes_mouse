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

    Usage: perl $0 -file annofile -sampleID sanpleID -outdir outdir

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

my %TS_TV = (
    "AT" => "TV",
    "TA" => "TV",
    "GC" => "TV",
    "CG" => "TV",
    "AC" => "TV",
    "TG" => "TV",
    "CA" => "TV",
    "GT" => "TV",
    "AG" => "TS",
    "GA" => "TS",
    "TC" => "TS",
    "CT" => "TS",
);

#my %snp_pattern = (
#    "A-T" => "T-A",
#    "A-C" => "T-G",
#    "A-G" => "T-C",
#    "G-C" => "C-G",
#    "G-T" => "C-A",
#    "G-A" => "C-T",
#    "T-A" => "T-A",
#    "T-C" => "T-C",
#    "T-G" => "T-G",
#    "C-A" => "C-A",
#    "C-T" => "C-T",
#    "C-G" => "C-G",
#);

my %snp_pattern = (
    "A-T" => "A>T/T>A",
    "A-C" => "A>C/T>G",
    "A-G" => "A>G/T>C",
    "G-C" => "G>C/C>G",
    "G-T" => "G>T/C>A",
    "G-A" => "G>A/C>T",
    "T-A" => "A>T/T>A",
    "T-C" => "A>G/T>C",
    "T-G" => "A>C/T>G",
    "C-A" => "G>T/C>A",
    "C-T" => "G>A/C>T",
    "C-G" => "G>C/C>G",
);
########load file;

my %var_region;
my %var_exon;
my %snp_ts_tv;
my %var_homo_hete;
my %indel_length;
my %snp_base;
my $Func_refGene;
my $Gene_refGene;
my $GeneDetail_refGene;
my $ExonicFunc_refGene;
my $chr;
my $start;
my $end;
my $ref;
my $alt;

my $name     = basename $file;
my $total    = 0;
my $indel    = 0;
$indel = 1 if ( $name =~ /INDEL/i );
open( IN, "$file" );
while (<IN>) {
    chomp;
    next if ( /^$/ || /^\#/ );
    if (/^Chr/){
        my @tmp = split /\t/, $_;
        ($chr) = grep {$tmp[$_] eq "Chr"} 0..$#tmp;
        ($start) = grep {$tmp[$_] eq "Start"} 0..$#tmp;
        ($end) = grep {$tmp[$_] eq "End"} 0..$#tmp;
        ($ref) = grep {$tmp[$_] eq "Ref"} 0..$#tmp;
        ($alt) = grep {$tmp[$_] eq "Alt"} 0..$#tmp;
        ($Func_refGene) = grep {$tmp[$_] eq "Func.refGene"} 0..$#tmp;
        ($Gene_refGene) = grep {$tmp[$_] eq "Gene.refGene"} 0..$#tmp;
        ($GeneDetail_refGene) = grep {$tmp[$_] eq "GeneDetail.refGene"} 0..$#tmp;
        ($ExonicFunc_refGene) = grep {$tmp[$_] eq "ExonicFunc.refGene"} 0..$#tmp;
        next;
    }
    my @tmp = split /\t/, $_;
    $total++;
    $var_region{$tmp[$Func_refGene]}++;
    $var_exon{$tmp[$ExonicFunc_refGene]}++ if ( $tmp[$Func_refGene] eq "exonic" );
    if ( $indel == 1 ) {
        my $len =( length($tmp[$ref]) > length($tmp[$alt]) ) ? length($tmp[$ref]) : length($tmp[$alt]);
        $indel_length{all}{$len}++;
        $indel_length{exon}{$len}++ if ( $tmp[$Func_refGene] eq "exonic" );
    }else {
        #next if($tmp[$alt] =~/,/);
        my @alt = split /,|\//, $tmp[$alt];
        foreach my $a (@alt) {
            if ( exists $TS_TV{"$tmp[$ref]$a"} ) {
                $snp_ts_tv{all}{ $TS_TV{"$tmp[$ref]$a"} }++;
                $snp_ts_tv{exon}{ $TS_TV{"$tmp[$ref]$a"} }++ if ( $tmp[$Func_refGene] eq "exonic" );
            }else {
                die "there is strange mutation type $tmp[$ref] to $tmp[$alt] in $chr,$start\n";
            }
            $snp_base{ $snp_pattern{ $tmp[$ref] . "-" . $a } }++;
         }

    }
}
###
my $stat = "$outdir/$sampleID";
if   ( $indel == 1 ) { $stat .= ".INDEL" }
else                 { $stat .= ".SNP" }

######  snp_base
my $output = "";
my $other  = 0;
if ( $indel != 1 ) {
	my $stat6 = $stat . ".mutation.pattern.stat.txt";
    my $pdf6  = $stat . ".mutation.pattern.stat.picture.list";
    my $tt    = 0;
    foreach my $t ( keys %snp_base ) { $tt += $snp_base{$t} }
    open( P6, ">$pdf6" ) || die "can't creat file $pdf6\n";
    print P6 "Type\t$sampleID\n";
    my @pattern = ( "A>T/T>A", "A>C/T>G", "A>G/T>C", "G>C/C>G", "G>T/C>A", "G>A/C>T" );
    foreach my $s (@pattern) {
        $snp_base{$s} = 0 if ( !exists $snp_base{$s} );
        $output .= "$s\t" . H_format( $snp_base{$s} ) . "\n";
        my $p = 0;
        $p = H_format( $snp_base{$s} / $tt * 100 ) if ( $tt != 0 );
        print P6 "$s\t$p\n";
    }
    open( O6, ">$stat6" ) || die "can't creat file $stat6\n";
    print O6 "\#Sample\t$sampleID\n$output";
    close O6;
    close P6;
	#`$Rscript $Bin/../common/anno.pie.r $pdf6 $stat.mutation.pattern.stat.pdf $sampleID T 0 1`;
	#`convert $stat.mutation.pattern.stat.pdf $stat.mutation.pattern.stat.png`;
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
