#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use File::Basename;

#############################Usage##############################
my $help=<<USAGE;
USAGE:
	-indirT tumor sample path
	-indirN normal sample path
	-sample_idT tumor sample id
	-sample_idN normal sample id
	-outdir out directory
USAGE
my ($indirT,$indirN,$sample_idT,$sample_idN,$outdir);
GetOptions
(   
	"indirT:s"     =>\$indirT,
	"indirN:s"    =>\$indirN,
	"sample_idT:s"     =>\$sample_idT,
	"sample_idN:s"     =>\$sample_idN,
	"outdir:s" =>\$outdir,
);
die "$help" unless(defined $indirT && defined $indirN);

#######################programme start time######################

my $start_time=localtime(time());
print "Start Time is : $start_time\n";

#################################################################
my $fileT="$indirT/$sample_idT".".FusionReport.txt";
my $fileN="$indirN/$sample_idN".".FusionReport.txt";
open (IN_tumor,"<$fileT");
open (IN_normal,"<$fileN");
my %tumor;
while (<IN_tumor>){
chomp;
my @itemT=split(/\t/,$_);
$tumor{$itemT[0]}=0;
}
close (IN_tumor);
while (<IN_normal>){
chomp;
my @itemN=split(/\t/,$_);
if(exists $tumor{$itemN[0]}){
$tumor{$itemN[0]}=1;
}else{
$tumor{$itemN[0]}=0;
}
}
close (IN_normal);
open (IN_tumor1,"<$fileT");
open (PO,">$outdir/data/fusion.txt");
open (LAB,">$outdir/data/label.txt");
while (<IN_tumor1>){
chomp;
my @itemT=split(/\t/,$_);
if($tumor{$itemT[0]} == 0){
my $e1=$itemT[6]+1000;
my $e2=$itemT[8]+1000;
   $itemT[5]=lc($itemT[5]);
   $itemT[7]=lc($itemT[7]);
	print PO "hs$itemT[5]\t$itemT[6]\t$itemT[6]\ths$itemT[7]\t$itemT[8]\t$itemT[8]\n";
print LAB "hs$itemT[5]\t$itemT[6]\t$e1\t$itemT[9]\nhs$itemT[7]\t$itemT[8]\t$e2\t$itemT[13]\n";
}
else{
}
}

