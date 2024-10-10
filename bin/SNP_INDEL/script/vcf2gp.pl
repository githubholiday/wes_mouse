#!/usr/bin/env perl
use strict;
#########################################################################
# Author: SanyangLiu,sanyangliu@annoroad.com
# Created Time: 2016年08月22日 星期一 10时33分26秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
my ($vcf,@samples,@vgs,$out,$use);
GetOptions(
    "v=s"=>\$vcf,
    "o=s"=>\$out,
);
$use=<<USE;
   Description: 
        根据VCF文件，提取每个个体的基因型。
   Update：
        v2.0  RenXue  20170831  ：增加了*位点的处理，并增加了说明和输出文件
   
   Usage：
        perl $0 -v *.vcf -o out.xls

USE
die $use unless ($vcf && $out);

open IN,"$vcf" or die "无法读取VCF文件\n";
open OUT,">$out" or die "can't open $out:$!\n";

while(<IN>){
    chomp;
    my @l = split (/\t/);
    next if (/^##/);
    if (/^#/){
        @samples=&get_sample($_);
        print OUT "CHROM\tPOS\tREF\t";
        print OUT join "\t",@samples,"\n";
    }
    else{
        &indel2gp($_);
        print OUT join "\t",@vgs,"\n";
    }
}
close IN;
close OUT;



sub get_sample (){
    my $line = shift;
    my @l = split (/\t/,$_);
    my $num = @l;
    for (my $i=9;$i<$num;$i++){
        push @samples,$l[$i];
    }
    return @samples;
}

sub indel2gp (){
    my $line = shift @_;
    my @l = split (/\t/,$_);
    @vgs=();
    #$l[4]=~s/\*/\-/g;
    push @vgs,($l[0],$l[1],$l[3]);
    my @alts = split (/,/,$l[4]);
    unshift @alts, $l[3];
    my $num = @l;
    for (my $i=9;$i<$num;$i++){
        $l[$i]=~ /^([\.\d]+)\/([\.\d]+)/ or die "请检查VCF文件:$l[$i]\n";
        if ($1 eq "."){
            push @vgs,"-";
        }
        elsif($1 eq $2){
            push @vgs,$alts[$1];
        }
        else{
            push @vgs,"$alts[$1],$alts[$2]";
        }
    }
    return @vgs;
}
