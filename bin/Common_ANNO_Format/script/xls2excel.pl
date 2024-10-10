#!/usr/bin/perl -w
###############################################
#The script is used to add hyperlinks in the k-
#egg pathway enrichment list.Certainly,it also
#can be appled for other lists
################################################
# version = 1.0 
# contactor = jiangdezhi(dezhijiang@annoroad.com)
use strict;
use Excel::Writer::XLSX;

unless(@ARGV==2){
	print "\n\tUsage:\n\t\tperl $0 <pathway_enrichment.xls> <out.xls>\n";
	print "\n\tExample:\n\t\tperl $0 group1_group2_BP.report.xls group1_group2_BP.report.md.xls\n\n";
	exit;
}
 
my ($infile,$outfile)=@ARGV;
my $row=0;
my $col=0;

# Create a new workbook called simple.xls and add a worksheet
my $workbook  = Excel::Writer::XLSX->new($outfile);
my $worksheet = $workbook->add_worksheet();

open IN,$infile or die;
while(<IN>){
     chomp;
     $row++;
     my @arr=split /\t/;
     if($row==1){
	$col=@arr;
	# The general syntax is write($row, $column, $token). Note that row and
	# column are zero indexed
	for(my $i=1;$i<=$col;$i++){
		$worksheet->write($row-1,$i-1,$arr[$i-1]);
	}
     }else{
	for(my $i=1;$i<=$col-1;$i++){
		$worksheet->write($row-1,$i-1,$arr[$i-1]);
	}
		#Write hyperlinks
		$worksheet->write($row-1,$col-1,$arr[$col-1]);
    }
}           
close IN;
