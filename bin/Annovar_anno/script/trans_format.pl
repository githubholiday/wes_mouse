#!/usr/bin/perl
use strict;
use warnings;
my $usage =<<usage;

Usage :  
    perl $0 class (CNV,LOH,SV) in ,out
Function :
    Format of SV,LOH,CNV in annovar
Author  :
    Jing Wang
Date :
    20161213

usage

unless (@ARGV == 3) {
    print "$usage\n";
    exit 1;
}
my ($class,$in,$out) = @ARGV;
my $a=$class;
open IN,"<$in" or die "fail read $in:$!\n";
open OUT,">$out" or die "fail output $out:$!\n";
my $row=0;
while (<IN>) {
    chomp;
my @array = split /\t/;
my $columns= @array-1;
if($class eq "CNV"){
	next if /^Chr/;              #孟昊20170721添加
	print OUT "$array[0]\t$array[1]\t$array[2]\t0\t0\t",join("\t",@array[3..$columns]),"\n";
}
elsif ($class eq "LOH"){
	my $information=$array[-1];
	my @ChrPos=split/:/,$information;
	my @StartEnd=split/-/,$ChrPos[1];
	my $Start=$StartEnd[0]+1;
	my $End=$StartEnd[1]+1;
	print OUT "$ChrPos[0]\t$Start\t$End\t0\t0\t",join("\t",@array[2..$columns]),"\n";
}
elsif ($class eq "SV"){
	if ($row > 0){
		if ($array[0] eq $array[4]){
			print OUT "$array[0]\t$array[1]\t$array[5]\t0\t0\t",join("\t",@array[2..$columns]),"\n";
     	}else{
     		print OUT "$array[0]\t$array[1]\t$array[1]\t0\t0\t",join("\t",@array[2..$columns]),"\n";
     		print OUT "$array[4]\t$array[5]\t$array[5]\t0\t0\t",join("\t",@array[2..$columns]),"\n";
     	}
     }else{
	 } 
}else{
	print STDERR "Wrong : input file format is not correct\n";
	exit;
    } 
$row++;
}
close IN;


