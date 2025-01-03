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
    "file=s"   =>   \$file,
    "outdir=s" =>   \$outdir,
	"sampleID=s" => \$sampleID,
    "h"
);
die $usage if ( !defined $file || !defined $sampleID|| !defined $outdir );

#----------------------------------------------------------

my $name     = basename $file;
my %sv_types;
my $total = 0;
my $type  = ();
open( IN, "$file" ) || die "can't open file $file \n";
while (<IN>) {
	chomp;
    next if $_ =~ /^#/;
	next if $_ !~ /^chr/;
    my @line = split /\t/, $_;
    $line[7] =~ s/SVTYPE=(\w+)?;/$1/;
    $type = $1;
	$total++;
	$sv_types{$type}++;
}

my $stat = "$outdir/$sampleID" . ".SV";
my $output;
my $other = 0;
my %pdf;
my $stat2 = "$stat.type.stat.txt";
my $pdf2  = "$stat.type.stat.picture.list";

open( O2, ">$stat2" ) || die "can't creat file $stat2\n";
open( P2, ">$pdf2" )  || die "can't creat file $pdf2\n";
print O2 "Type\t$sampleID\n";
print P2 "Type\t$sampleID\n";

my @type = ( "DEL", "DUP", "INS", "INV", "BND" );

foreach my $t (@type) {
	if ($total==0) {
		print O2 "$t\t0\n";
	}else {
		$sv_types{$t} = 0 if ( !exists $sv_types{$t} );
		my $per = H_format( $sv_types{$t} / $total * 100 );
		print O2 "$t\t" . H_format( $sv_types{$t} ) . "\n";
		print P2 "$t\t$per\n";
	}

}
close O2;
close P2;

#`$Rscript $Bin/../common/anno.pie.r $pdf2 $stat.type.stat.pdf $sampleID T 0 1`;
#`convert $stat.type.stat.pdf $stat.type.stat.png`;

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
