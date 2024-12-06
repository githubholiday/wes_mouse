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
#my $Rscript = "/annoroad/share/software/install/R-3.1.3/bin/Rscript";

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

my %snp_pattern = (
    "A-T" => "T-A",
    "A-C" => "T-G",
    "A-G" => "T-C",
    "G-C" => "C-G",
    "G-T" => "C-A",
    "G-A" => "C-T",
    "T-A" => "T-A",
    "T-C" => "T-C",
    "T-G" => "T-G",
    "C-A" => "C-A",
    "C-T" => "C-T",
    "C-G" => "C-G",
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
        ($Func_refGene) = grep {$tmp[$_] eq "Func.ensGene"} 0..$#tmp;
        ($Gene_refGene) = grep {$tmp[$_] eq "Gene.ensGene"} 0..$#tmp;
        ($GeneDetail_refGene) = grep {$tmp[$_] eq "GeneDetail.ensGene"} 0..$#tmp;
        ($ExonicFunc_refGene) = grep {$tmp[$_] eq "ExonicFunc.ensGene"} 0..$#tmp;
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
#########
my $stat = "$outdir/$sampleID";
if   ( $indel == 1 ) { $stat .= ".INDEL" }
else                 { $stat .= ".SNP" }
my $output = "";
my $other  = 0;

if ( $indel == 1 ) {
	my $stat5 = $stat . ".length.pattern.stat.txt";
    my $pdf5  = $stat . ".length.pattern.stat.picture.list";
    my $all_len;
    my $exon_len;
    for ( my $s = 1 ; $s <= 10 ; $s++ ) {
		$indel_length{all}{$s}  = 0 if ( !exists $indel_length{all}{$s} );
        $indel_length{exon}{$s} = 0 if ( !exists $indel_length{exon}{$s} );
        $output .= "$s\t"
                . H_format( $indel_length{all}{$s} ) . "\t"
                . H_format( $indel_length{exon}{$s} ) . "\n";
        $all_len  .= "Genome($s)\t$indel_length{all}{$s}\n";
        $exon_len .= "Exonic($s)\t$indel_length{exon}{$s}\n";
        delete $indel_length{all}{$s};
        delete $indel_length{exon}{$s};
    }
    my $len1 = 0;
    my $len2 = 0;
	
    foreach my $s ( sort keys %{ $indel_length{all} } ) {
		$len1 += $indel_length{all}{$s};
    }
    foreach my $s ( sort keys %{ $indel_length{exon} } ) {
		$len2 += $indel_length{exon}{$s};
    }
	
    $output .= ">10\t" . H_format($len1) . "\t" . H_format($len2) . "\n";
    open( O5, ">$stat5" ) || die "can't creat file $stat5\n";
    print O5 "\#$sampleID\tGenome\tExonic\n$output";
    close O5;
    open( P5, ">$pdf5" ) || die "can't creat file $pdf5\n";
    print P5 "Type\t$sampleID\n$all_len"
          . "Genome(>10)\t$len1\n"
          . "$exon_len"
          . "Exonic(>10)\t$len2\n";
    close P5;

	#`$Rscript $Bin/../common/anno.indel_len.r $pdf5 $stat.length.pattern.stat.pdf $sampleID`;
    #`convert $stat.length.pattern.stat.pdf $stat.length.pattern.stat.png`;
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
