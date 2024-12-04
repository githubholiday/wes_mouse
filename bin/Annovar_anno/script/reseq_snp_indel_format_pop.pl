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
		#my $new_head= join "\t",@head[0..4],"Depth","Allele_Balance","GT:AD",@head[5..($#head-1)];
        my $new_head=join "\t",@head[0..($#head-1)];  ###群call文件不需要"Depth","Allele_Balance","GT:AD"
		print OUT "$new_head\n";
		next;
	}
#	next unless ($info[5]=~/exonic|splicing/);
#	if($file=~/-SNP/ && $info[5]=~/exonic/){
#		next unless ($_=~/nonsynonymous|stoploss|stopgain/);
#	}
	my ($DP)=($_=~/DP=(\d+);/);
	my $AB="-";
	($AB)= ($info[-3]=~/^(ABH[oe][mt]=\S+);AC/);
	if(!$AB){
		$AB="-";
	}
	my ($GTAD) = ($info[-1]=~/^(\S+:\S+):\S+:\S+:\S+/);
	#my $line = join "\t",@info[0..4],$DP,$AB,$GTAD,@info[5..($#info-13)];
    my $line = join "\t",@info[0..4],$DP,$AB,$GTAD,@info[5..9];  ##---modified by renxue  因为改成群call文件注释，所以后面内容不一定是13，直接定为10列
	print OUT "$line\n";
}
close IN;

close OUT;
