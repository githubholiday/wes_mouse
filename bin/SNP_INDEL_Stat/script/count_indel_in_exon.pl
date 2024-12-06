#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);
my $version = "1.0";
###########################################################

my $usage = << "USAGE";

    Description: Count INDEL in Exon.
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
    "file=s"     => \$file,
    "outdir=s"   => \$outdir,
    "sampleID=s" => \$sampleID,
    "config=s"   => \$config,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

my %TS_TV = (    #ת�����ۻ�
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

my %snp_pattern = (    #ͻ�����ͣ�ͻ��Ƶ��
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
### 2 snp or in exon stat
my @snp_exon_type = (
	"nonsynonymous SNV", "synonymous SNV",
    "stopgain",          "stoploss",
    "unknown"
);
my @indel_exon_type = (
	"frameshift deletion",
	"frameshift insertion",
	"nonframeshift deletion",
	"nonframeshift insertion",
	"stopgain",
	"stoploss",
	"unknown"
);
my $stat2 = $stat . ".ExonicFunc.stat.txt";
my $pdf2  = $stat . ".ExonicFunc.stat.picture.list";
open( P2, ">$pdf2" ) || die "can't creat file $pdf2\n";
print P2 "Type\t$sampleID\n";

my $output = "";
my $total2 = 0;
my $other  = 0;

foreach my $s ( keys %var_exon ) {
	$total2 += $var_exon{$s};
}

if ( $indel == 1 ) {
	foreach my $s (@indel_exon_type) {
		$var_exon{$s} = 0 if ( !exists $var_exon{$s} );
        my $per;
        if ( $total2 == 0 ) { $per = 0 }
        else { $per = H_format( $var_exon{$s} / $total2 * 100 ); }
        $output .= "$s\t" . H_format( $var_exon{$s} ) . "\t" . $per . "\n";
        $other += $var_exon{$s};
        print P2 "$s\t$per\n";
	}
}else {
    foreach my $s (@snp_exon_type) {
		$var_exon{$s} = 0 if ( !exists $var_exon{$s} );
        my $per;
        if ( $total2 == 0 ) { $per = 0 }
        else { $per = H_format( $var_exon{$s} / $total2 * 100 ); }
        $output .= "$s\t" . H_format( $var_exon{$s} ) . "\t" . $per . "\n";
        $other += $var_exon{$s};
        print P2 "$s\t$per\n";
    }
}
close P2;

$other = $total2 - $other;
if ( $other != 0 ) {
	print "ExonicFunc pattern is strange,the other type number is $other\n";
}

open( O2, ">$stat2" ) || die "can't creat file $stat2\n";
print O2 "#$sampleID\tNumber\tPercent(%)\nTotal\t$total2\t100.00\n$output";
close O2;

if ( $total2 != 0 ) {
	#`$Rscript $Bin/../common/anno.pie.r $pdf2 $stat.ExonicFunc.stat.pdf $sampleID T 0 1`;
	#`convert $stat.ExonicFunc.stat.pdf $stat.ExonicFunc.stat.png`;
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
