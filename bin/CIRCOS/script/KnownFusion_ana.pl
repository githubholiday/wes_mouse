#!/usr/bin/perl
use strict;
use Getopt::Long;
use File::Basename qw(basename dirname);

#############################Usage##############################
my %opts;
GetOptions(\%opts,"infile=s","knowfile=s","outfile=s","bin=s","h");

if (!defined($opts{infile}) || !defined($opts{knowfile})|| !defined($opts{outfile}) || !defined($opts{bin})||defined($opts{h})) {
	
	print << "Usage End.";
	
	Description:
	Usage:
		
		-infile                 must be given ,*.FusionReport.txt 
		-knowfile               must be given,COSMICfusion file
		-outfile 
		-bin
		-h,--h,-help,--help     help document

Usage End.

	exit;
}
#######################programme start time######################
my $start_time=localtime(time());
print "Start Time is : $start_time\n";
#################################################################
my $infile=$opts{infile};         $infile=Absolute_Dir($infile,"file");          
my $knowfile=$opts{knowfile};     $knowfile=Absolute_Dir($knowfile,"file"); 
my $outfile=$opts{outfile};       $outfile=Absolute_Dir($outfile,"file"); 
my $bin=$opts{bin};       $bin=Absolute_Dir($bin,"file"); 
##################################################################
open (IN1,"<$knowfile");
my %hash;
while (<IN1>) {
	chomp;
	my @a=split(/\t/,$_);
	$hash{$a[1].$a[2]}=$_;
}
close IN1;

open (IN2,"<$infile");
open (OUT,">$outfile");
my $know_num=0;
my $num=0;
my $tumor=0;
my @tu;
my $file=basename $infile;
my $sample=(split(/\./,$file))[0];
print OUT "SampleID\t$sample\n";
while (<IN2>) {
	chomp;
	next if ($_=~/^(FusionID)/);
	my @b=split(/\t/,$_);
	$num++;
	if (exists $hash{$b[9].$b[13]}) {
		$know_num++;
		$tumor=(split (/\t/,$hash{$b[9].$b[13]}))[0];
		push @tu,$tumor;
	}elsif (exists $hash{$b[13].$b[9]}) {
		$know_num++;
		$tumor=(split (/\t/,$hash{$b[13].$b[9]}))[0];
		push @tu,$tumor;
	}
}
print OUT "Total number\t$num\n";
print OUT "Known number\t$know_num\n";
print OUT "Related tumor\t";

if (scalar(@tu) eq 0) {
	print OUT "NULL\n";
}else {
	for (my $i=0;$i<scalar(@tu);$i++){	
		if ($i<scalar(@tu)-1){
			print OUT "$tu[$i]".",";
		}else {
			print OUT "$tu[$i]";
		}
	}
}

open (OU,">$outfile".".figure");
print OU "SampleID\t$sample\n";
print OU "Number of fusiongene\t$num\n";

system ("/annoroad/share/software/install/R-3.1.3/bin/Rscript $bin/common/barplot.r $outfile.figure $outfile.pdf '' 'Number of fusiongene' T NULL NULL");
system ("convert $outfile.pdf $outfile.png");

#################programme End Time########################
my $end_time=localtime(time());
print "End Time is :$end_time\n";
####################Sub#####################################

sub Absolute_Dir {
	my ($ff,$type)=@_;
	my $cur_dir=`pwd`;
	chomp $cur_dir;
	if($ff !~/^\// && $type eq "file") {
		$ff=$cur_dir."/".$ff;
	}elsif($ff !~/^\// && $type eq "dir") {
		$ff=$cur_dir."/".$ff;
		if(!-d $ff){`mkdir -p $ff`}
	}elsif($type eq "dir") {
		if(!-d $ff){`mkdir -p $ff`}
	}
	return $ff;
}
