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

my %TS_TV = (    #转换、巅换
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

my %snp_pattern = (    #突变类型，突变频谱
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
###
my $stat = "$outdir/$sampleID";
if   ( $indel == 1 ) { $stat .= ".INDEL" }
else                 { $stat .= ".SNP" }
#### 1 snp in genome region stat
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

#`$Rscript $Bin/../common/anno.pie.r $pdf1 $stat.genome.region.stat.pdf $sampleID T 0 1`;
#`convert $stat.genome.region.stat.pdf $stat.genome.region.stat.png`;

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
