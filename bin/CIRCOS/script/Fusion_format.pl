#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use File::Basename;

#############################Usage##############################
my $help=<<USAGE;
USAGE:
	-indir           //result/      
	-sample_id
	-outdir
USAGE
my ($indir,$sample_id,$outdir);
GetOptions
(
	"indir:s"     =>\$indir,
	"sample_id:s"     =>\$sample_id,
	"outdir:s" =>\$outdir,
);
die "$help" unless(defined $indir);

#######################programme start time######################

my $start_time=localtime(time());
print "Start Time is : $start_time\n";

#################################################################
my @report=glob("$indir/$sample_id".".FusionReport.txt");

foreach my $file(@report) {

	my $sample=(split(/\./,basename $file))[0];

	open (IN,"<$file") or die "No files";
	open (PO,">$outdir/data/fusion.txt");
	open (LAB,">$outdir/data/label.txt");
	while (<IN>) {
		chomp;
		my @a=split(/\t/,$_);
		next if ($a[0] eq "FusionID");
		my $e1=$a[6]+1000;
		my $e2=$a[8]+1000;
		print PO "hs$a[5]\t$a[6]\t$a[6]\ths$a[7]\t$a[8]\t$a[8]\n";
		print LAB "hs$a[5]\t$a[6]\t$e1\t$a[9]\nhs$a[7]\t$a[8]\t$e2\t$a[13]\n";
	}
	close IN;
	close PO;
	close LAB;


}
