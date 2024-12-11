#!/usr/bin/env perl
use strict;
die "perl $0 <input deth.gz from bwa alignment> <input karyotype file> <MIN or MAX ,use to set gap of circos> <output> <config for circos>" unless @ARGV == 5;
my $input = shift;
my $kt = shift;
my $space = shift;
my $output = shift;
my $configFile = shift;
my $flag = 0;
print $output."\n";
my %haxi_faid_hsid;
my %haxi_faid_len;
my %haxi_config;
readkt($kt,\%haxi_faid_hsid,\%haxi_faid_len);
readconfig($configFile,\%haxi_config);

if($space eq 'MIN'){
	$flag = 1;
	$space = int($haxi_config{'spaceMin'}/5);
}
elsif($space eq 'MAX'){
	$space = $haxi_config{'spaceMax'};
}
else{
	
}



open HH,"gunzip -c $input |";
my %reg_num;
my %reg_depth;
my $total_depth = 0;

while(defined(my $line = <HH>)){
	chomp($line);
	my @cell = split('\t',$line);
	#print $line."\n";
	my $arrayV = int($cell[1]/$space);
	$reg_num{$cell[0]}[$arrayV]++;
	$reg_depth{$cell[0]}[$arrayV]+=$cell[2];
	$total_depth += $cell[2];
}
close HH;

open SC,">$output";

foreach my $chromo(sort keys %reg_depth){
	#print @{$reg_depth{$chromo}}."\n";
	my $array_len = @{$reg_depth{$chromo}};
	my $max_len = $haxi_faid_len{$chromo};
	my $i;
	for($i = 0 ; (($i+1)*$space) < $max_len; $i++){
		print SC $haxi_faid_hsid{$chromo}."\t".($i*$space)."\t".(($i+1)*$space - 1)."\t".(@{$reg_depth{$chromo}}[$i]?@{$reg_depth{$chromo}}[$i]/$space:0)."\n";
		
	}
	print SC $haxi_faid_hsid{$chromo}."\t".($i*$space)."\t".$max_len."\t".(@{$reg_depth{$chromo}}[$i]?@{$reg_depth{$chromo}}[$i]/($max_len-$i*$space):0)."\n";

}
close SC;

if($flag){
	my $total_genomeLen = 0;
	foreach my $id(sort keys %haxi_faid_len){
		$total_genomeLen += $haxi_faid_len{$id};
	}
	
	open SC,">>$configFile";
	
	print SC "meanDepth=>".($total_depth/$total_genomeLen)."\n";
	
	close SC;
}

sub readkt{
	my $filekt = shift;
	my $haxi = shift;
	my $haxi_len = shift;
	
	open HH,"$filekt";
	while(defined(my $line = <HH>)){
		chomp($line);
		my @cell = split(' ',$line);
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
