#!/usr/bin/env perl
use strict;
die "perl $0 <karyotype file> <SNP vcf> <output> <outputSnpRegNum> <config>" unless @ARGV==5;
my $kt = shift;
my $input = shift;
my $output = shift;
my $outputSnpRegNum = shift;
my $configFile = shift;
my $space = 100000;

my %haxi_faid_hsid;
my %haxi_faid_len;
my %reg_num;
my %haxi_config;

readkt($kt,\%haxi_faid_hsid,\%haxi_faid_len);
readconfig($configFile,\%haxi_config);

$space = $haxi_config{'spaceMax'};
print $space."\n";
open HH,"$input";
open SC,">$output";
while(defined(my $line = <HH>)){
	chomp($line);
	if($line !~ /^#/){
		my @cell = split('\t',$line);
		if($cell[6] eq "PASS"){ # $cell[7] =~ /DP=(.+?);/ && $1 > 30
			#print $line."\n";
			#print $1."\n";
			if($cell[7] =~ /ABHet\=(.+?)\;/ || $cell[7] =~ /ABHom\=(.+?)\;/){
				print SC $haxi_faid_hsid{$cell[0]}." ".($cell[1]-1)." ".($cell[1]-1)." ".$1."\n";
			}
			else{
				#print $cell[0]." ".($cell[1]-1)." ".($cell[1]-1)." ".$cell[7]."\n";	
			}
			my $arrayV = int($cell[1]/$space);
			$reg_num{$cell[0]}[$arrayV]++;
		}
	}
	
	
}
close SC;
close HH;


open SC,">$outputSnpRegNum";
my $maxSnpNum = 0;
foreach my $chromo(sort keys %reg_num){
	#print @{$reg_depth{$chromo}}."\n";
	my $array_len = @{$reg_num{$chromo}};
	my $max_len = $haxi_faid_len{$chromo};
	my $i;
	for($i = 0 ; (($i+1)*$space) < $max_len; $i++){
		print SC $haxi_faid_hsid{$chromo}."\t".($i*$space)."\t".(($i+1)*$space - 1)."\t".(@{$reg_num{$chromo}}[$i]?(log(@{$reg_num{$chromo}}[$i])/log(10)):0)."\n"; #(log(@{$reg_num{$chromo}}[$i])/log(10))
		if(@{$reg_num{$chromo}}[$i]?(log(@{$reg_num{$chromo}}[$i])/log(10)):0 > $maxSnpNum){
			$maxSnpNum = (log(@{$reg_num{$chromo}}[$i])/log(10));
		}
	}
	print SC $haxi_faid_hsid{$chromo}."\t".($i*$space)."\t".$max_len."\t".(@{$reg_num{$chromo}}[$i]?(log(@{$reg_num{$chromo}}[$i])/log(10)):0)."\n";
	if(@{$reg_num{$chromo}}[$i]?(log(@{$reg_num{$chromo}}[$i])/log(10)):0 > $maxSnpNum){
			$maxSnpNum = (log(@{$reg_num{$chromo}}[$i])/log(10));
	}

}
close SC;

open SC,">>$configFile";
print SC "maxSnpNum=>".$maxSnpNum."\n";
close SC;




sub readkt{
	my $filekt = shift;
	my $haxi = shift;
	my $haxi_len = shift;
	
	open HH,"$filekt";
	while(defined(my $line = <HH>)){
		chomp($line);
		my @cell = split(' ',$line);
		#print $cell[6]."\t".$cell[2]."\n";
		${$haxi}{$cell[3]} = $cell[2];
		${$haxi_len}{$cell[3]} = $cell[5];
		
		
	}
	
	
	close HH;
	
	
	
}

sub readconfig{
	my $file = shift;
	my $haxi = shift;
	
	open HH,"$file";
	while(defined(my $line = <HH>)){
		chomp($line);
		my @cell = split('=>',$line);
		${$haxi}{$cell[0]} = $cell[1];
		
	}
	
	close HH;
	
	
}
