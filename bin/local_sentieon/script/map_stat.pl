#!/usr/bin/env perl
use strict;
#########################################################################
# Author: SanyangLiu,sanyangliu@annoroad.com
# Created Time: 2016年05月17日 星期二 12时05分08秒
# Modifierd Time: 2017年09月02日 星期日 22时
#########################################################################
unless(@ARGV >=6 and @ARGV <=7){
    print "\nUsage:\n\tperl $0 <Uniq_stat> <rmdup.metrics> <Sample_ID> <Clean_stat><Genome_length> <Coverage> <Exome_dir>\n";
    print "\n\t<Exome_dir>:\t\t该参数可选填，适用于外显子测序中统计捕获效率等指标\n\n";
    exit;
}

my $uniq    = shift;      # 读取uniq base 信息用于计算uniq 率；
my $map     = shift;      # 读取rmdup 文件，用于统计rmdup信息；
my $name    = shift;      # 样品名
my $fqstat  = shift;      # 读取测序数据量信息
my $genome_len = shift;   # 基因组长度
my $coverage= shift;      # 读取coverage文件；
my $exome_dir = shift;      # 读取外显子分析目录，选填,适用于外显子分析；
my ($ur,$cb,$cr,$mrd,$mre,$depth,$cov,$dup,$dep,%sample,$map_base,$rmdup_base);
my ($map_region_reads,$cap,$flank_mapped_bases,$mean_flank,$cover_1,$cover_4);
print "Sample\t$name\n";
$sample{$name}=1;
open IN,"$uniq" or die "无法打开$uniq:$!\n";
<IN>;
$ur=<IN>;
chomp $ur;
my $uniq_base=(split/\t/,$ur)[1];
$uniq_base=~s/,//g;       # 去除数字中的千分位符，如果有的话；
#print "$uniq_base\n";
chomp(my $mapped_reads = <IN>);
$mapped_reads=(split/\t/,$mapped_reads)[1];
chomp($map_base=<IN>);
$map_base=(split/\t/,$map_base)[1];
close IN;

open IN,"$fqstat" or die "无法读取$fqstat:$!\n";
my $line=<IN>;
chomp $line;
my @l = split(/\t/,$line);
my $num=0;
foreach my $k (@l){
    if (exists $sample{$k}){
        last;
    }
    $num++;
}
while(<IN>){
    chomp;
    if(/Clean Reads Number/){
        my @l = split (/\t/,$_);
        $cr=$l[$num];
        $cr="Clean Reads\t".$cr."\n";
    }
    elsif(/Clean Bases Number/){
        my @l = split (/\t/,$_);
        $cb=$l[$num];
        $cb="Clean Bases\t".$cb."\n";
    }
}
close IN;

die"没有正确读取到Clean Bases数和Clean Reads数\n" unless ($cr and $cb);

my $dup_rate="";
open IN,"$map" or die "无法读取$map:$!\n";    # 读取 Dup率 统计文件；
while(<IN>){
    if(/#/){
		next;
    }
    elsif(/^LIBRARY/){
		chomp;
		my $dup=(split(/\t/,<IN>))[8];
        $dup_rate=sprintf ("%.2f",$dup*100);
    }
}
close IN;


my $clean_base=&split_number($cb);
my $clean_reads=&split_number($cr);
my $map_rate = sprintf ("%.2f",$mapped_reads/$clean_reads*100);
1 while ($clean_reads =~ s/(\d+)(\d\d\d)/$1,$2/g);
1 while ($mapped_reads =~ s/(\d+)(\d\d\d)/$1,$2/g);


for($map_rate){ /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; };
for($genome_len){ /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; };

close IN;


<IN>;
$mrd=<IN>;
my $rm_map_reads=(split(/\t/,$mrd))[1];
chomp $rm_map_reads;
$mrd=&qianfen($mrd);
$mre=<IN>;
$mre=&qianfen($mre);
$cov=<IN>;
$cov=&qianfen($cov);
my $uniq_rate = sprintf ("%.2f",100*$uniq_base/$map_base);

unless ( $exome_dir ) {
	for($map_base){ /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; };
	$ur="Uniq Rate(%)\t".$uniq_rate."\n";
	print "Genome Length\t$genome_len\n";
	print "$cr";
	print "$cb";
	print "Mapped Reads\t$mapped_reads\n";
	print "Mapped Bases\t$map_base\n";
	print "Mapping Rate (%)\t$map_rate\n";
	print "Duplication Rate (%)\t$dup_rate\n";
	print "$ur";

	open IN,"$coverage" or die"无读取$coverage:$!\n";
	while(<IN>){
    		print "$_";
	}
	close IN;
}else {
	($map_region_reads,$cap,$flank_mapped_bases,$mean_flank,$cover_1,$cover_4) =get_exome($exome_dir);
	&exome_stat;
}

sub qianfen{
     my $line=shift @_;
     chomp $line;
     my ($item,$number) = split (/\t/,$line);
     for ( $number ) { /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; }
     $line="$item\t$number\n";
     return $line; 
}

sub split_number{
    my $line= shift @_;
    chomp $line;
    my ($item,$number) = split (/\t/,$line);
    $number =~ s/,//g;
    return $number;
}

sub get_exome{
    my $indir = shift;
    my $capture = (glob("$indir/*.capture.xls"))[0];
    my $flank_coverage = (glob("$indir/*flank.coverage.xls"))[0];
    
    open CAP,$capture or die "Can not find $capture" ;
    chomp( my $map_region_reads = <CAP>);
    1 while $map_region_reads =~ s/(\d+)(\d\d\d)/$1,$2/g ;
    chomp( my $cap = <CAP>);
    close IN;

    open COV,$flank_coverage or die "Can not find $flank_coverage" ;
    my ($mean_flank,$cover_1,$cover_4);
    while(<COV>){
	chomp;
	my @arr = split /\t/;
	if ( $_=~/Mean Depth\t([\.\d]+)/){
		$mean_flank = $1;
	}
	if ( $_=~/Bases Mapped to Target Region\t([\.\d]+)/){
                $flank_mapped_bases = $1;
        }
	if ( $_=~/overage Rate\s+\(%\)\s+\(>=1X\)\t([\.\d]+)/){
		$cover_1 = $1;
	}
	if ( $_=~/overage Rate\s+\(%\)\s+\(>=4X\)\t([\.\d]+)/){
		$cover_4 = $1;
	}
    }
    close COV;	

    return($map_region_reads,$cap,$flank_mapped_bases,$mean_flank,$cover_1,$cover_4);
} 

sub exome_stat{
	1 while ($map_base =~ s/(\d+)(\d\d\d)/$1,$2/g);
	1 while ($flank_mapped_bases =~ s/(\d+)(\d\d\d)/$1,$2/g);
	print "Target Region (bp)\t$genome_len\n";
	print "$cr";
	print "$cb";
	print "Mapped Reads\t$mapped_reads\n";
	print "Mapped Bases\t$map_base\n";
	print "Mapping Rate (%)\t$map_rate\n";
	print "$map_region_reads\n";
	print "$cap\n";
	print "Duplication Rate (%)\t$dup_rate\n";
	print "Uniq Rate(%)\t$uniq_rate\n";

	open IN,"$coverage" or die"无读取$coverage:$!\n";
	while(<IN>){
		chomp;
		my @arr=split /\t/;
		if ( $_ =~ /^Mean Depth/){
			print "Mean Depth of Target Region\t$arr[1]\n";
		}elsif ( $_ =~ /^Bases Mapped to Target Region/){
			1 while ($arr[1] =~ s/(\d+)(\d\d\d)/$1,$2/g);
		        print "Bases Mapped to Target Region\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=1X\)/){
		        print "Coverage of Target Region (%)\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=4X\)/){
		        print "Fraction of Target Covered >=4X\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=10X\)/){
		        print "Fraction of Target Covered >=10X\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=20X\)/){
		        print "Fraction of Target Covered >=20X\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=30X\)/){
		        print "Fraction of Target Covered >=30X\t$arr[1]\n";
		}elsif ( $_ =~ /^Coverage Rate  \(%\) \(>=50X\)/){
		        print "Fraction of Target Covered >=50X\t$arr[1]\n";
		}
	}
	close IN;

	print "Bases Mapped to Flanking Region\t$flank_mapped_bases\n";
	print "Mean Depth of Flanking Region\t$mean_flank\n";
	print "Coverage of Flanking Region (%)\t$cover_1\n";
	print "Fraction of Flanking Covered >=4X\t$cover_4\n";
}
