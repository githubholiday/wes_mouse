#!/usr/bin/perl -w
use strict;									#强制要求定义变量
use warnings;								#提示报错信息
use Getopt::Long;							#Getopt引参
use Data::Dumper;							#给出一个或多个变量，包括引用，以PERL语法的方式返回这个变量的内容
use FindBin qw($Bin $Script);				#获取脚本的路径和脚本的名称
use File::Basename qw(basename dirname);	#获取文件的名称和绝对路径
my $BEGIN_TIME=time();						#开始时间
my $version="1.0.0";						#版本号
#######################################################################################
# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fsample,$flujing,$fOut,%hash,%hash1,%hash2,$hangshu);							#定义GetOptions中的变量
GetOptions(
				"help|?" =>\&USAGE,
				"s:s"=>\$fsample,			#输入样本名列表
				"i:s"=>\$flujing,			#输入样本路径模版
				"l:s"=>\$hangshu, 			#对应样品数据的具体行数
				"o:s"=>\$fOut,				#'='表示此参数一定要有参数值, 若改用':'代替表示参数不一定要有参数值
				##"n:s"=>\$fn,				#'s'表示传递字串参数, 若为'i'表传递整数参数, 若为'f'表传递浮点数
				) or &USAGE;
&USAGE unless ($fsample and $flujing);				#强制变量
#######################################################################################
# ------------------------------------------------------------------
# 脚本正文
# ------------------------------------------------------------------
my $lis = $hangshu-1;
open (IN,$fsample) or die $!;
open (OUT,">$fOut") or die $!;
#$/=">";
	
while(<IN>){
	chomp;
	next if (/^$/);
	my @in=split/\t/,$_;
	my $aa="$flujing";
    $aa =~ s/#/$in[1]/g;
    if (-e $aa){
        $hash{$in[1]}=$aa;
    }
    else{
        die "$aa不存在\n";
    }
}
close IN;
my @header;
foreach my $k(keys %hash){
	open ONE,"$hash{$k}" or die "$hash{$k}:$!";
	<ONE>;
    @header=();
    push @header,"Sample";
	while(<ONE>){
		chomp;
		my @list = split/\t/,$_;
		$hash1{sample} = "Sample";
		$hash1{$list[0]} = $list[0];
        push @header,"$list[0]";
	}
    close ONE;
}

foreach my $k1(keys %hash){
	open TWO,"$hash{$k1}" or die $!;
	<TWO>;
	while(<TWO>){
		chomp;
		my @list2 = split/\t/,$_;
        my $test=@list2;
        die "指定列数超出文件的列数\n" if ($lis >=@list2);
		$hash2{sample} = $k1;
		$hash2{$list2[0]} = $list2[$lis];
	}
	close TWO;
	foreach my $k2(keys %hash1){
			if (exists $hash2{$k2} and $hash2{$k2}){
				$hash1{$k2} .= "\t".$hash2{$k2};
			}
			else{
				$hash1{$k2} .= "\t".0;
			}
	}
}

print OUT "$hash1{sample}\n";
foreach my $k3(@header){
	next if ($k3=~/Sample/);
	print OUT "$hash1{$k3}\n";
}

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------

# ---------------------获取绝对路径---------------------------------
sub ABSOLUTE_DIR{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
# ----------------------获取时间------------------------------------
sub GetTime {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}
# ----------------------脚本说明------------------------------------
sub USAGE {#
	my $usage=<<"USAGE";
Program:
Version: $version
Contact:Xue Gao <gaogaoxue\@annoroad.com> 
Description:
Usage:
  Options:
  	-o #输出文件路径与文件名 
	-s #输入样本名列表
	-i #输入样本路径模版
	-l #对应样品数据的具体列数
 
    -h         Help
例子：
perl bulit_list.pl -s /annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/DNA/Resequence/ANSN160001/SN160001-01/liqingyuan/Pipe_test_SD/pre/html.xls -l 2 -i /annoroad/data1/bioinfo/PROJECT/Commercial/Cooperation/DNA/Resequence/ANSN160001/SN160001-01/liqingyuan/Pipe_test_SD/out_result/Alignment/#/#.map.stat.xls -o /annoroad/data1/bioinfo/PROJECT/RD/Cooperation/DNA/Resequence/ngs_bioinfo/mic-111/xuegao/Analysis/Result/All.map.stat.xls

USAGE
	print $usage;
	exit;
}

