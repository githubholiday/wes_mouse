#!/usr/bin/env perl
use strict;
use Getopt::Long;
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);
use POSIX qw(strftime);
#########################################################################
# Author: Ren Xue, xueren@annoroad.com
# Created Time: 2017年06月06日 星期二 17时16分46秒
#########################################################################
my ($indir,$type,$use,$sample);
my $ver="v2.0";
$use=<<USE;
#############################################################################################

Description： 根据质控指标，提供第一次的统计文件路径，对重测序部分文件进行二次统计。
	各变异路径下所需文件。
	SNP:
		*genome.region.stat.txt
        *SNP.mutation.pattern.stat.txt   
		*SNP.ExonicFunc.stat.txt
	INDEL:
		*genome.region.stat.txt
		*INDEL.length.pattern.stat.txt
		*INDEL.ExonicFunc.stat.txt
	SV:
		*genome.region.stat.txt
		*SV.type.stat.txt		
    CNV:
        *CNV.stat.xls
    KO:
       *gene.anno.txt

Version：$ver;
Parameters:
        -i              输入路径，同时也是输出路径                    must be given
        -t              变异类型                                      must be given 
		-s              样本名称                                      must be given


Update:
     20171219  genome_pattern 中exon统计改为了第3列百分比;增加了CNV和KO的质控。

############################################################################################
USE

GetOptions(
        "i=s" =>\$indir,
		"t=s" =>\$type,
		"s=s" =>\$sample,
);

die "there is not enough parameters\n$use" unless ($indir && $type && $sample);

my $time=&TIME;
my $info=$time." - $Script - INFO - ";
my $erro=$time." - $Script - ERROR - ";
my $warn=$time." - $Script - WARNNING - ";

#############################################################################################
print STDOUT "$info##Analysis begin\n";
my %result;
my $input1=glob("$indir/*genome.region.stat.txt") ;
if ($type eq "SNP") {
	my $input2=glob("$indir/*SNP.mutation.pattern.stat.txt") ;
	my $input3=glob("$indir/*SNP.ExonicFunc.stat.txt");
	$result{"exonic SNP exist"}=&genome_pattern($input1);
	$result{"SNP pattern"}=&snp_pattern($input2);
	$result{"Synonymous SNP more than NonSynonymous SNP"}=&nonsy($input3);
}
elsif($type eq "INDEL"){
	my $input2=glob("$indir/*INDEL.length.pattern.stat.txt") ;	
	my $input3=glob("$indir/*INDEL.ExonicFunc.stat.txt") ;
	$result{"exonic INDEL exist"}=&genome_pattern($input1);
	$result{"INDEL length pattern"}=&length_pattern($input2);
	$result{"INDEL variant pattern"}=&variant_pattern($input3);
}
elsif($type eq "SV"){
	my $input2=glob("$indir/*SV.type.stat.txt") ;
	$result{"exonic SV exist"}=&genome_pattern($input1);
	$result{"Five SV pattern"}=&sv_pattern($input2);
}
elsif($type eq "CNV"){
    my $input2=glob("$indir/*.CNV.stat.xls");
    $result{"CNV pattern"}=&cnv_pattern($input2);

}elsif($type eq "KO"){
    my $input2=glob("$indir/*.gene.anno.txt");
    $result{"KO pattern"}=&Moreline_pattern($input2);
}else {print STDERR "$erro## type is wrong and it should be SNP or INDEL or SV or CNV or KO\n";}

open OUT,">$indir/$sample.$type.qc.stat.txt" or print STDERR "$erro##$indir/$type.qc.stat.txt文件不能打开或者不能建立\n";
print OUT "$type\_QC\t$sample\n";
foreach my $k (keys %result) {
	print OUT "$k\t$result{$k}\n";
}
close OUT;
print STDOUT "$info##Analysis End\n";
	
###########################################Sub process############################################
sub genome_pattern {
	my $input=shift;
	my $result;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		my @temp=split("\t",$_);
		if($temp[0]=~/^exonic$/){
			#if (&transnum($temp[1]) >= 0) {$result="YES";}else{$result="NO";} 改为判断数值
            $result=$temp[2];
		}else{next;}
	}
	close IN;
	return $result;
}

sub snp_pattern {
	my $input=shift;
	my $result;
	my $tc=0;
	my $tg=0;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		next if (/^#/);
		my @temp=split("\t",$_);
		if($temp[0]=~/T\-C|C\-T/){
			$tc+=&transnum($temp[1]);
		}else{$tg+=&transnum($temp[1]);}
	}
	if ($tc>$tg) {$result="YES";}else{$result="NO";}
	close IN;
	return $result;
}

	
sub nonsy{
	my $input=shift;
	my $result;
	my ($non,$sy);
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		next if (/^#/);
		my @temp=split("\t",$_);
		if($temp[0]=~/\bnonsynonymous SNV/){$non=&transnum($temp[1]);
		}elsif ($temp[0]=~/\bsynonymous SNV/) {$sy=&transnum($temp[1]);}
	}
	if ($sy>$non) {$result="YES";}else{$result="NO";}
	close IN;
	return $result;
}

sub length_pattern{
	my $input=shift;
	my $result;
	my %info;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		next if (/^#/);
		my @temp=split("\t",$_);
		$info{$temp[0]}=&transnum($temp[2]);
	}
	if ($info{3}>=$info{2} && $info{3}>=$info{4}) {$result="YES";}else{$result="NO";}
	close IN;
	return $result;
}


sub variant_pattern{
	my $input=shift;
	my $result;
	my ($frame,$stop);
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		next if (/^#/);
		my @temp=split("\t",$_);
		if ($temp[0]=~/^frameshift/) {$frame+=&transnum($temp[1]);}
		elsif($temp[0]=~/stop/){$stop+=&transnum($temp[1]);}
	}
	if ($frame>$stop) {$result="YES";}else{$result="NO";}
	close IN;
	return $result;
} 

sub sv_pattern{
	my $input=shift;
	my $num;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		next if (/^Type/);
		my @temp=split("\t",$_);
		if ($temp[1]>0){$num+=1;}
	}
	close IN;
	return $num;
} 


sub cnv_pattern{
	my $input=shift;
	my $num=0;
    my $result;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	while(<IN>){
		chomp;
		my @temp=split("\t",$_);
        if ($temp[0]=~/^Deletion$|^Duplication$/){
		    if ($temp[1]>0){$num+=1;}
        }
	}
	close IN;
    if ($num==2){$result="YES";}else{$result="NO";}
	return $result;
}


sub Moreline_pattern {
	my $input=shift;
	my $result;
	open IN,"$input" or print STDERR "$erro##$input文件不能打开或者不存在\n";
	my @num=<IN>;
    close IN;
    if (@num>2){$result="YES";}else{$result="NO";}
	return $result;
}




sub TIME{
return strftime("%Y\/%m\/%d %H:%M:%S", localtime(time));
}

sub transnum{
	my $num=shift;
	my @temp=split(",",$num);
	my $result;
	for (my $i=0;$i<=$#temp;$i=$i+1) {
		$result+=$temp[$i]*(1000**($#temp-$i));		
	}
    return $result;
}
