#!/usr/bin/env perl
use strict;
die "perl $0 <input indel vcf> <input karyotype file> <output>\n" unless @ARGV==3;

my $input = shift;
my $kt = shift;
my $output = shift;

my %haxi_faid_hsid;
my %haxi_faid_len;
readkt($kt,\%haxi_faid_hsid,\%haxi_faid_len);


open HH,"$input";
open SC,">$output";
while(defined(my $line = <HH>)){
	chomp($line);
	my @cell = split('\t',$line);
	
	if($line !~ /^#/){
		
		if($cell[6] eq "PASS"){
			#print $line."\n";
			#print SC $haxi_faid_hsid{$cell[0]}." ".$cell[1]." ".($cell[1]+1)."\n";
			my $tmp = (length($cell[3]) - length($cell[4]))*10;
			
			if($tmp > 0){
				print SC $haxi_faid_hsid{$cell[0]}." ".$cell[1]." ".($cell[1]+1)." "."r0=0.77r,r1=0.77r+".$tmp."p".",stroke_thickness=4,stroke_color=vdblue"."\n";#",stroke_thickness=1,stroke_color=dgreen".
			}
			elsif($tmp < 0){
				print SC $haxi_faid_hsid{$cell[0]}." ".$cell[1]." ".($cell[1]+1)." "."r0=0.77r".$tmp."p,r1=0.77r".",stroke_thickness=4,stroke_color=vdpyellow"."\n";#",stroke_thickness=1,stroke_color=dred".
			}
			else{
				#print $line."\n";	
			}
			
		}
		
		
	}
	
	
	
}

close SC;
close HH;




















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
