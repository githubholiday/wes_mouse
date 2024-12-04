#! /usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use FindBin qw/$Bin/;

#my$Rscript='/annoroad/share/software/install/R-3.0.2/bin/Rscript';
my($file1,$file2,$prefix,$sample,$Rscript);
GetOptions("r1:s"=>\$file1,
		   "r2:s"=>\$file2,
		   "prefix:s"=>\$prefix,
		   "sample:s"=>\$sample,
		   "rscript:s"=>\$Rscript,
	 );

die "perl $0 --r1 --r2 --prefix\n" unless(defined ($prefix));
$sample ||= 'NA';
my(%base,%quality);
my$length1=0;my$tag=0;
open IN,$file1||die "cannot open $file1\n";
open OUT,">$prefix.temp"||die;
while(<IN>){
	next if(/^#/);
	my@tmp=split /\s+/,$_;
	if($tmp[0]==0){
		$tag=1;
	}
	if($tag==1){
		$tmp[0]+=1;
	}
	my$output=join "\t" ,@tmp[0..5];
	my($mean,$median)=STAT(@tmp[6..$#tmp]);
	print OUT "$output\t$mean\t$median\n";
	$length1++ unless (/^#/);
}
close IN;

my$length2=0;$tag=0;
if(defined $file2){
	open IN,$file2||die "cannot open $file2\n";
	while(<IN>){
		next if(/^#/);
		my@tmp=split /\s+/,$_;
		if($tmp[0]==0){
			$tag=1;
		}
		if($tag==1){
			$tmp[0]+=$length1+1;
		}else{
			$tmp[0]+=$length1;
		}
		my$output=join "\t" ,@tmp[0..5];
		my($mean,$median)=STAT(@tmp[6..$#tmp]);
		print OUT "$output\t$mean\t$median\n";
		$length2++ unless (/^#/);
	}
	close IN;
}
close OUT;
if(defined $file2){
	if(system ("$Rscript $Bin/draw.r $prefix.temp $prefix.base.pdf $length1 $length2 $prefix.quality.pdf $sample")){
#if(system ("$Rscript $Bin/draw.r $prefix.temp $prefix.base.pdf $length1 $length2 $prefix.quality.pdf $sample&& rm $prefix.temp"))
		print STDERR "draw error\n";
	}
}else{
	if(system ("$Rscript $Bin/draw.r $prefix.temp $prefix.base.pdf $length1 0 $prefix.quality.pdf  $sample")){
		print STDERR "draw error\n";
	}
}


sub STAT{
	my(@array)=@_;
	my($total_base,$total_quality,$mean);
	foreach my$i(0..$#array){
		$total_quality+=$i*$array[$i];
		$total_base+=$array[$i];
	}
	my$n=0;my$tag=0;my$median;
	foreach my$i(0..$#array){
		next if($tag>0);
		$n+=$i*$array[$i];
		if($n>=$total_base/2){
			$tag=1;
			$median=$i;
		}
	}
	$mean=$total_quality/$total_base;
	return($mean,$median);
}


