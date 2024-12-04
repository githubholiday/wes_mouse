#!/usr/bin/perl
=head
	this program is to draw depth distribution figure for whole genome sequencing.
=cut
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long;
die "usage:\nperl $0 <sampleID> <TRDepthCnt> <cumuDepth> <out_dir> <stat_file>\n" unless(@ARGV>=5);
my($sa_id,$HIS_file,$CUM_file,$out_dir,$stat)=@ARGV;
my ($config,%config);
GetOptions(
    "c=s"=>\$config,
);
$config||="$Bin/../../config/config.txt";
&parse_config($config);

open STAT, "<", "$stat" or die $!;
my $meanDepth = 0;
while (<STAT>) {
    chomp;
    unless (/Mean Depth of Target Region/) {
        next;
    }
    my @line = split/\t/,$_;
    $meanDepth = int($line[1]);
}
close STAT;
my $dep = $meanDepth*4;
print "$meanDepth\n";
print "$dep\n";

open HIS,"$HIS_file" or die $!;
my $max_cov = 0;
my $percent;
<HIS>;
while(<HIS>){
	chomp;
	my @a = split /\s+/;
	$percent = $a[1];
	$max_cov=$percent if($percent>$max_cov);
}

my $ylim = $max_cov;

my ($xbin, $ybin);
$ylim = int($ylim)+2;
#if($ylim <= 3) {$ybin = 0.5;}else {$ybin = int($ylim/5)+1;}
my $xlim = $dep;
my $type="h";
#if($xlim<150){ $type="h";}
if($xlim<100){ $xlim=100;$type="h";}
$xbin=int($xlim/5)+1;
histPlot($out_dir, $sa_id,$HIS_file, $ylim, $xlim, $type);
cumuPlot($out_dir, $sa_id,$CUM_file, $xlim, $xbin);

#`rm -r $out_dir/plot_temp`;

sub histPlot {
	my ($outDir,$sampleName,$dataFile, $ylim, $xlim, $type) = @_;
	my $figFile = "$outDir/$sampleName\_histPlot.pdf";
	my $Rline=<<Rline;
	library(ggplot2)
	data<-read.table("$dataFile",sep="\\t",header=T)
	xlim<-(floor($meanDepth*4/100)+1)*100
	ylim<- max(data[,2])+2
	data<-data[data[,1] <= xlim,-3]

	p<-ggplot(data = data ,aes(x=Depth,y=Percentage,fill=Depth))+geom_bar(stat = "identity",width=0.5)+labs(x = "Sequencing depth(X)",y = "Fraction of bases (%)",fill = "$sampleName",size=5)+coord_cartesian(ylim=c(0,ylim),xlim=c(0,xlim))
	p<-p+theme(legend.position="right",axis.title.x=element_text(size=15),axis.title.y=element_text(size=15),legend.background=element_rect(colour = 'gray90',fill="gray90"),axis.text.x = element_text(colour = "black",size=15,face="bold"),axis.text.y = element_text(colour = "black",size=15,face="bold"))
	p<-p+scale_fill_continuous(low="#2fd5db",high="#2d146f",space="rgb")
	ggsave(p,file="$outDir/$sampleName\_histPlot.png",width=12,height = 9,dpi=150)
	ggsave(p,file="$outDir/$sampleName\_histPlot.pdf",width=12,height = 9,dpi=400)
Rline
	open (ROUT,">$figFile.R");
	print ROUT $Rline;
	close(ROUT);

#	system("$config{R} CMD BATCH  $figFile.R");
	system("$config{Rscript} $figFile.R");
#	system("rm  $figFile.R  $sampleName\_histPlot.pdf.Rout"); #
	system("convert $outDir/$sampleName\_histPlot.pdf $outDir/$sampleName\_histPlot.png");
}

sub cumuPlot {
	my ($outDir,$sampleName,$dataFile, $xlim, $xbin) = @_;
	my $figFile = "$outDir/$sampleName\_cumuPlot.pdf";
	my $Rline=<<Rline;
	library(ggplot2)
	data<-read.table("$dataFile",sep="\\t",header=T)
	xlim<-(floor($meanDepth*4/100)+1)*100
	data<-data[data[,1] <= xlim,-3]
	
	p<-ggplot(data = data,aes(x=Depth,y=Percentage,fill=Depth))+geom_bar(stat = "identity",width=0.5)+labs(x = "Sequencing depth(X)",y = "Fraction of bases (%)",fill = "$sampleName",size=5)
	p<-p+theme(legend.position="right",axis.title.x=element_text(size=15),axis.title.y=element_text(size=15),legend.background=element_rect(colour = 'gray90',fill="gray90"),axis.text.x = element_text(colour = "black",size=15,face="bold"),axis.text.y = element_text(colour = "black",size=15,face="bold"))
	p<-p+scale_fill_continuous(low="#2fd5db",high="#2d146f",space="rgb")+scale_y_continuous(breaks=seq(0,120,20))
	ggsave(p,file="$outDir/$sampleName\_cumuPlot.png",width =12,height = 9,dpi=150)
	ggsave(p,file="$outDir/$sampleName\_cumuPlot.pdf",width =12,height = 9,dpi=400)
Rline
	open (ROUT,">$figFile.R");
	print ROUT $Rline;
	close(ROUT);

	#system("$config{R} CMD BATCH  $figFile.R");
	system("$config{Rscript} $figFile.R");
#	system("rm  $figFile.R  $sampleName\_cumuPlot.pdf.Rout"); #
	system("convert $outDir/$sampleName\_cumuPlot.pdf $outDir/$sampleName\_cumuPlot.png");
}


sub parse_config {
    my $conifg_file = shift;
    open IN,$conifg_file || die "fail open: $conifg_file";
    while (<IN>) {
        chomp;
        next if (/^#/);
        if (/(\S+)\s*=\s*(.*)#*/){
            $config{$1}=$2;
        }
    }
    close IN;
}


