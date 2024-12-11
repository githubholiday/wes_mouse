#!/usr/bin/perl -w
#
#copyright (c) 2016
# Writer: Qingyuan Li
# Program Date: 2016.
# Modifier: name
# Last Modified: 2016.

use strict;
use warnings;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw($Bin);
use List::Util qw(max);
use Cwd;

my $help=<<USAGE;

Note:

	*******************************************************
		Source: Annoroad
		Editor: Qingyuan Li
		date:  20161117

	*******************************************************

USAGE:

	-uniqfile	<must>	The uniq anno file
	-commonfile	<must>	The group name
	-outfile  <must>	    The outputfile

Example1: perl  Script  -uniqfile A.uniq.hg19_multianno.txt -commonfile A.all.overlap.hg19_multianno.txt -outfile A.stat.txt

USAGE

my ($uniqfile,$commonfile,$outfile);

GetOptions
(
	 "uniqfile:s"	    =>\$uniqfile,
	 "commonfile:s"		=>\$commonfile,
	 "outfile:s"     =>\$outfile,
);
die "$help" unless( defined $uniqfile);
#------------------------声明变量--------------------------#
my @uniq=();
my @comm=();
my @samples=();
my $sam='';
my $head="ITEM";
my $UTR3='UTR3';
my $UTR5='UTR5';
my $UTR35="UTR5;UTR3";
my $downstream="Downstream";
my $exonic="Exonic";
my $exonic_splicing="Exonic;splicing";
my $intergenic="Intergenic";
my $intronic="Intronic";
my $ncRNA_UTR3="NcRNA_UTR3";
my $ncRNA_UTR5="NcRNA_UTR5";
my $ncRNA_UTR35="NcRNA_UTR5;ncRNA_UTR3";
my $ncRNA_exonic="NcRNA_exonic";
my $ncRNA_intronic="NcRNA_intronic";
my $ncRNA_splicing="NcRNA_splicing";
my $splicing="Splicing";
my $upstream="Upstream";
my $up_down="Upstream;downstream";
my $total="Total";
my $UTR3_n='0';
my $UTR5_n='0';
my $UTR35_n='0';
my $downstream_n='0';
my $exonic_n='0';
my $exonic_splicing_n='0';
my $intergenic_n='0';
my $intronic_n='0';
my $ncRNA_UTR3_n='0';
my $ncRNA_UTR5_n='0';
my $ncRNA_UTR35_n='0';
my $ncRNA_exonic_n='0';
my $ncRNA_intronic_n='0';
my $ncRNA_splicing_n='0';
my $splicing_n='0';
my $upstream_n='0';
my $up_down_n='0';
my $total_n='0';

#------------------------统计数量--------------------------#
unless( open(UNIQ,"<$uniqfile") ) {
	print STDERR "Cannot open file \"$uniqfile\"\n\n";
	exit;
}
@uniq=<UNIQ>;
close (UNIQ);

unless( open(COMM,"<$commonfile") ) {
	print STDERR "Cannot open file \"$commonfile\"\n\n";
	exit;
}
close (COMM);

unless( open(STAT,">$outfile") ) {
	print STDERR "Cannot open file \"$outfile\"\n\n";
	exit;
}

@samples=`grep -v '^#Sample' $uniqfile|cut -f 1|sort -u`;
print @samples;
foreach $sam (@samples){
	chomp $sam;
	$UTR3_n='0';
	$UTR5_n='0';
	$UTR35_n='0';
	$downstream_n='0';
	$exonic_n='0';
	$exonic_splicing_n='0';
	$intergenic_n='0';
	$intronic_n='0';
	$ncRNA_UTR3_n='0';
	$ncRNA_UTR5_n='0';
	$ncRNA_UTR35_n='0';
	$ncRNA_exonic_n='0';
	$ncRNA_intronic_n='0';
	$ncRNA_splicing_n='0';
	$splicing_n='0';
	$upstream_n='0';
	$up_down_n='0';
	$total_n='0';


	foreach my $uniq_line (@uniq){

		chomp $uniq_line;

		my @uniq_var=split(/\t/,$uniq_line);

		if ($uniq_var[0] eq $sam){

			$total_n++;
			my $anno_u=$uniq_var[12];
			if ($anno_u eq "UTR3"){
				$UTR3_n++;
			}elsif($anno_u eq "UTR5"){
				$UTR5_n++;
			}elsif($anno_u eq "UTR5;UTR3"){
				$UTR35_n++;
			}elsif($anno_u eq "downstream"){
				$downstream_n++;
			}elsif($anno_u eq "exonic"){
				$exonic_n++;
			}elsif($anno_u eq "exonic;splicing"){
				$exonic_splicing_n++;
			}elsif($anno_u eq "intergenic"){
				$intergenic_n++;
			}elsif($anno_u eq "intronic"){
				$intronic_n++;
			}elsif($anno_u eq "ncRNA_UTR3"){
				$ncRNA_UTR3_n++;
			}elsif($anno_u eq "ncRNA_UTR5"){
				$ncRNA_UTR5_n++;
			}elsif($anno_u eq "ncRNA_UTR5;ncRNA_UTR3"){
				$ncRNA_UTR35_n++;
			}elsif($anno_u eq "ncRNA_exonic"){
				$ncRNA_exonic_n++;
			}elsif($anno_u eq "ncRNA_intronic"){
				$ncRNA_intronic_n++;
			}elsif($anno_u eq "ncRNA_splicing"){
				$ncRNA_splicing_n++;
			}elsif($anno_u eq "splicing"){
				$splicing_n++;
			}elsif($anno_u eq "upstream"){
				$upstream_n++;
			}elsif($anno_u eq "upstream;downstream"){
				$up_down_n++;
			}else{next;}

		}else{next;}
	}

	$head.="\t".$sam."_specific";
	$UTR3.="\t".&qianfen($UTR3_n);
	$UTR5.="\t".&qianfen($UTR5_n);
	$UTR35.="\t".&qianfen($UTR35_n);
	$downstream.="\t".&qianfen($downstream_n);
	$exonic.="\t".&qianfen($exonic_n);
	$exonic_splicing.="\t".&qianfen($exonic_splicing_n);
	$intergenic.="\t".&qianfen($intergenic_n);
	$intronic.="\t".&qianfen($intronic_n);
	$ncRNA_UTR3.="\t".&qianfen($ncRNA_UTR3_n);
	$ncRNA_UTR5.="\t".&qianfen($ncRNA_UTR5_n);
	$ncRNA_UTR35.="\t".&qianfen($ncRNA_UTR35_n);
	$ncRNA_exonic.="\t".&qianfen($ncRNA_exonic_n);
	$ncRNA_intronic.="\t".&qianfen($ncRNA_intronic_n);
	$ncRNA_splicing.="\t".&qianfen($ncRNA_splicing_n);
	$splicing.="\t".&qianfen($splicing_n);
	$upstream.="\t".&qianfen($upstream_n);
	$up_down.="\t".&qianfen($up_down_n);
	$total.="\t".&qianfen($total_n);
}

@comm=`cut -f 2-6,13 $commonfile |sort -u`;

$UTR3_n='0';
$UTR5_n='0';
$UTR35_n='0';
$downstream_n='0';
$exonic_n='0';
$exonic_splicing_n='0';
$intergenic_n='0';
$intronic_n='0';
$ncRNA_UTR3_n='0';
$ncRNA_UTR5_n='0';
$ncRNA_UTR35_n='0';
$ncRNA_exonic_n='0';
$ncRNA_intronic_n='0';
$ncRNA_splicing_n='0';
$splicing_n='0';
$upstream_n='0';
$up_down_n='0';
$total_n='0';

$head.="\tCommon\n";

if ($#comm==0){
	$UTR3.="\t".&qianfen($UTR3_n)."\n";
	$UTR5.="\t".&qianfen($UTR5_n)."\n";
	$UTR35.="\t".&qianfen($UTR35_n)."\n";
	$downstream.="\t".&qianfen($downstream_n)."\n";
	$exonic.="\t".&qianfen($exonic_n)."\n";
	$exonic_splicing.="\t".&qianfen($exonic_splicing_n)."\n";
	$intergenic.="\t".&qianfen($intergenic_n)."\n";
	$intronic.="\t".&qianfen($intronic_n)."\n";
	$ncRNA_UTR3.="\t".&qianfen($ncRNA_UTR3_n)."\n";
	$ncRNA_UTR5.="\t".&qianfen($ncRNA_UTR5_n)."\n";
	$ncRNA_UTR35.="\t".&qianfen($ncRNA_UTR35_n)."\n";
	$ncRNA_exonic.="\t".&qianfen($ncRNA_exonic_n)."\n";
	$ncRNA_intronic.="\t".&qianfen($ncRNA_intronic_n)."\n";
	$ncRNA_splicing.="\t".&qianfen($ncRNA_splicing_n)."\n";
	$splicing.="\t".&qianfen($splicing_n)."\n";
	$upstream.="\t".&qianfen($upstream_n)."\n";
	$up_down.="\t".&qianfen($up_down_n)."\n";
	$total.="\t".&qianfen($total_n)."\n";

	print STAT $head;
	print STAT $UTR3;
	print STAT $UTR5;
	print STAT $UTR35;
	print STAT $downstream;
	print STAT $exonic;
	print STAT $exonic_splicing;
	print STAT $intergenic;
	print STAT $intronic;
	print STAT $ncRNA_UTR3;
	print STAT $ncRNA_UTR5;
	print STAT $ncRNA_UTR35;
	print STAT $ncRNA_exonic;
	print STAT $ncRNA_intronic;
	print STAT $ncRNA_splicing;
	print STAT $splicing;
	print STAT $upstream;
	print STAT $up_down;
	print STAT $total;

	close (STAT);

}else{

	foreach my $comm_line (@comm){

		chomp $comm_line;

		my @comm_var=split(/\t/,$comm_line);

			$total_n++;

		my $anno_comm=$comm_var[7];

		if ($anno_comm eq "UTR3"){
			$UTR3_n++;
		}elsif($anno_comm eq "UTR5"){
			$UTR5_n++;
		}elsif($anno_comm eq "UTR5;UTR3"){
			$UTR35_n++;
		}elsif($anno_comm eq "downstream"){
			$downstream_n++;
		}elsif($anno_comm eq "exonic"){
			$exonic_n++;
		}elsif($anno_comm eq "exonic;splicing"){
			$exonic_splicing_n++;
		}elsif($anno_comm eq "intergenic"){
			$intergenic_n++;
		}elsif($anno_comm eq "intronic"){
			$intronic_n++;
		}elsif($anno_comm eq "ncRNA_UTR3"){
			$ncRNA_UTR3_n++;
		}elsif($anno_comm eq "ncRNA_UTR5"){
			$ncRNA_UTR5_n++;
		}elsif($anno_comm eq "ncRNA_UTR5;ncRNA_UTR3"){
			$ncRNA_UTR35_n++;
		}elsif($anno_comm eq "ncRNA_exonic"){
			$ncRNA_exonic_n++;
		}elsif($anno_comm eq "ncRNA_intronic"){
			$ncRNA_intronic_n++;
		}elsif($anno_comm eq "ncRNA_splicing"){
			$ncRNA_splicing_n++;
		}elsif($anno_comm eq "splicing"){
			$splicing_n++;
		}elsif($anno_comm eq "upstream"){
			$upstream_n++;
		}elsif($anno_comm eq "upstream;downstream"){
			$up_down_n++;
		}else{next;}
	}

    $total_n--;
	$UTR3.="\t".&qianfen($UTR3_n)."\n";
	$UTR5.="\t".&qianfen($UTR5_n)."\n";
	$UTR35.="\t".&qianfen($UTR35_n)."\n";
	$downstream.="\t".&qianfen($downstream_n)."\n";
	$exonic.="\t".&qianfen($exonic_n)."\n";
	$exonic_splicing.="\t".&qianfen($exonic_splicing_n)."\n";
	$intergenic.="\t".&qianfen($intergenic_n)."\n";
	$intronic.="\t".&qianfen($intronic_n)."\n";
	$ncRNA_UTR3.="\t".&qianfen($ncRNA_UTR3_n)."\n";
	$ncRNA_UTR5.="\t".&qianfen($ncRNA_UTR5_n)."\n";
	$ncRNA_UTR35.="\t".&qianfen($ncRNA_UTR35_n)."\n";
	$ncRNA_exonic.="\t".&qianfen($ncRNA_exonic_n)."\n";
	$ncRNA_intronic.="\t".&qianfen($ncRNA_intronic_n)."\n";
	$ncRNA_splicing.="\t".&qianfen($ncRNA_splicing_n)."\n";
	$splicing.="\t".&qianfen($splicing_n)."\n";
	$upstream.="\t".&qianfen($upstream_n)."\n";
	$up_down.="\t".&qianfen($up_down_n)."\n";
	$total.="\t".&qianfen($total_n)."\n";

	print STAT $head;
	print STAT $UTR3;
	print STAT $UTR5;
	print STAT $UTR35;
	print STAT $downstream;
	print STAT $exonic;
	print STAT $exonic_splicing;
	print STAT $intergenic;
	print STAT $intronic;
	print STAT $ncRNA_UTR3;
	print STAT $ncRNA_UTR5;
	print STAT $ncRNA_UTR35;
	print STAT $ncRNA_exonic;
	print STAT $ncRNA_intronic;
	print STAT $ncRNA_splicing;
	print STAT $splicing;
	print STAT $upstream;
	print STAT $up_down;
	print STAT $total;

	close (STAT);
}

#------------------------SUB--------------------------#
sub qianfen{
     my $number=shift @_;
     for ( $number ) { /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; }
     return $number;
}

