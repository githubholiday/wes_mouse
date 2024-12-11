#!/annoroad/share/software/install/perl-5.16.2/bin/perl-w
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my %opts;
GetOptions(\%opts,"indir=s","outdir=s","bin=s","h");

if (!defined($opts{indir})||!defined($opts{outdir}) || !defined($opts{bin})|| defined($opts{h})) {	
	print << "Usage End.";	
	Description:
	Usage:	
		-indir           FusionGene/Intermediate/*     
		-outdir          FusionGene/Intermediate/
		-bin
		-h,--h,-help,--help     help document
Usage End.
	exit;
}
#################################################################
my $indir=$opts{indir};     $indir=Absolute_Dir($indir,"file");     
my $outdir=$opts{outdir};   $outdir=Absolute_Dir($outdir,"file");  
my $bin=$opts{bin};         $bin=Absolute_Dir($bin,"file");  
##################################################################
my $Rscript="/annoroad/share/software/install/R-3.1.3/bin/Rscript";

my @figure=glob("$indir/*/*.FusionReport.txt.stat.figure");
my %hash;
foreach my $file (@figure){
	next unless $file=~/\w/;
	chomp $file;
	my $name=basename $file;
	my @a = split(/\./,$name);
	my $sampleID= "$a[0]";
	open (IN,"<$file");
	my @line=<IN>;
	my $num=(split(/\t/,$line[1]))[1];
	chomp $num;
	$hash{$sampleID}=$num;
	close IN;
}

open (OUT,">$outdir/ALL.FusionGene.sum.figure");
print OUT "Sample\t";
foreach my $key (sort keys %hash){
	print OUT "$key\t";
}
print OUT "\n";

print OUT "Number of FusionGene\t";
foreach my $key (sort keys %hash){
	print OUT "$hash{$key}\t";
}
print OUT "\n";

system ("$Rscript $bin/common/barplot.r $outdir/ALL.FusionGene.sum.figure $outdir/ALL.FusionGene.sum.pdf '' 'Number of FusionGene' F 10 NULL");
system ("convert $outdir/ALL.FusionGene.sum.pdf  $outdir/ALL.FusionGene.sum.png");


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