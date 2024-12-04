#!/annoroad/share/software/install/perl-5.16.2/bin/perl-w
use strict;
use warnings;
use File::Basename;
#edit by wuboxin;
die  "\nUsage: $0 <_multianno.txt><Outdir>\n" unless (@ARGV == 2);
open     IN,"$ARGV[0]"  or die "$!" ;
my $file=basename $ARGV[0];
my $out=$file;
$out=~s/txt$/xls/;
my $sample = (split /-/,$file)[0];
#N1_C1-INDEL-Filter.hg19_multianno.txt
open OUT ,">$ARGV[1]/$out" or  die "$!" ;
my @head;
while(<IN>)
{
	chomp ;
	my @info=split /\t/;
	if($_=~/Func\./ && $_=~/Ref/ && $_=~/Alt/){
		@head=@info;
#		print $#head;
		my $new_head= join "\t",@head[0..4],"Ref_Depth","Alt_Depth","Genotype",@head[5..($#head-1)];
		print OUT "$new_head\n";
		next;
	}
#	next unless ($info[5]=~/exonic|splicing/);
#	if($file=~/-SNP/ && $info[5]=~/exonic/){
#		next unless ($_=~/nonsynonymous|stoploss|stopgain/);
#	}
	#my ($DP)=($_=~/DP=(\d+);/);
	#my $AB="-";
	#($AB)= ($info[-3]=~/^(ABH[oe][mt]=\S+);AC/);
	#if(!$AB){
	#	$AB="-";
	#}
	#my ($GTAD) = ($info[-1]=~/^(\S+:\S+):\S+:\S+:\S+/);
    my @GATD=split(":",$info[-1]);
    my @depths=split(",",$GATD[1]);
    my $Ref_depth=$depths[0];
    shift @depths;
    my $Alt_depth;
    my $geno=" ".$GATD[0];
    if (@depths==1){$Alt_depth=$depths[0];}else{$Alt_depth=join ",",@depths;}
	#my $line = join "\t",@info[0..4],$Ref_depth,$Alt_depth,$GATD[0],@info[5..($#info-13)];
	my $line = join "\t",@info[0..4],$Ref_depth,$Alt_depth,$geno,@info[5..($#info-13)];
	print OUT "$line\n";
}
close IN;

close OUT;
