#! /usr/perl/bin -w
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;


my $help=<<USAGE;
USAGE:
        -infile
		-outfile_INS
		-outfile_DEL
		-outfile_DUP
		-outfile_CTX
		-outfile_INV
USAGE
#print $help;
my $infile = shift;
my $outfile_INS = shift;
my $outfile_DEL = shift;
my $outfile_DUP = shift;
my $outfile_CTX = shift;
my $outfile_INV = shift;
open IN,"$infile" or die $!;
open OUT_INS,">$outfile_INS" or die $!;
open OUT_DEL,">$outfile_DEL" or die $!;
open OUT_CTX,">$outfile_CTX" or die $!;
open OUT_DUP,">$outfile_DUP" or die $!;
open OUT_INV,">$outfile_INV" or die $!;

while (<IN>){
	chomp;
	next if /^#/;
	my @SV=split(/\t/,$_);
	$SV[0]=~s/chr/hs/i;
	$SV[7] =~ /CHR2=(\w+);/;
	my $chr2 = $1;
	$chr2 =~ s/chr/hs/i;
	$SV[7] =~ /END=([0-9]+);/;
	my $chr2_end = $1;
	if ($SV[2] =~ "DEL"){
		print OUT_DEL "$SV[0]\t$SV[1]\t$chr2_end\n";
	}
	if($SV[2] =~ "TRA"){
		print OUT_CTX "$SV[0]\t$SV[1]\t$SV[1]\t$chr2\t$chr2_end\t$chr2_end\n";
	}
	if($SV[2] =~ "INV"){
		print OUT_INV "$SV[0]\t$SV[1]\t$SV[1]\t$chr2\t$chr2_end\t$chr2_end\n";
	}
	if($SV[2] =~ "INS"){
		print OUT_INS "$SV[0]\t$SV[1]\t$chr2_end\n";
	}
	if($SV[2] =~ "DUP"){
		print OUT_DUP "$SV[0]\t$SV[1]\t$chr2_end\n";
	}
}
close IN;
close OUT_INS;
close OUT_CTX;
close OUT_DEL;
close OUT_DUP;
close OUT_INV;
