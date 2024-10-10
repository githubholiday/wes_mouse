#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Excel::Writer::XLSX;    #menghao    20171206
use utf8;
use POSIX qw(strftime);

my $usage = << "USAGE";

    ***********************************************************************************
     Source:   Annoroad
     Author:   Wangjing
     Modifier: Menghao
     Date:     2017年 02月 10日 星期五 13:31:41 CST
    ***********************************************************************************

     Description: Format Annovar Annotation File.

     Usage: perl $Script -annovar <Anno File> -title <title_document.txt> -output <output>

            -annovar       The annovar annotation file.
            -title         The title info.
            -output        The output file.

USAGE

#GetOptions------------------------------------------------

my ( $annovar, $output, $title );
GetOptions(
    "annovar=s" => \$annovar,
    "output=s"  => \$output,
    "title=s"   => \$title,
    "h"
);
die $usage if ( !defined $annovar || !defined $output || !defined $title );

if ( !-e $annovar ){
	print ("$annovar not exists, exit!!\n");
	exit();
}
#Mainroutine-----------------------------------------------

my $Start_Time = &TIME;
print "Start Time: $Start_Time\n";

my $workbook    = Excel::Writer::XLSX->new($output);
my $result      = $workbook->add_worksheet("Results");

my ( %title, @title, @title_out, $col_titile, $col_num, @same_col_num, $same_col_num );

#读入配置文件
open TITLE, "<:encoding(utf8)", $title or die $!;
while(<TITLE>){
	chomp;
	my @info=split/\t/,$_;
	$title{$info[0]}{description} = $info[1];
	$title{$info[0]}{type}        = $info[2];
	$title{$info[0]}{color}       = $info[3];
	push @title, $info[0];
}
close TITLE;

#写入表头
$col_titile = @title;
# $result -> set_column(0, $col_titile, 15);
# for ( my $col=0; $col<@title; $col++ ) {
	# my $format = $workbook->add_format();
	# $format->set_bold();
	# $format->set_align('left');
	# my $color_bg=$title{$title[$col]}{color};
	# $format->set_bg_color($color_bg);
	# $result->write(0,$col,$title[$col],$format);
# }

#写入除去表头的内容
open ANNO, "<", "$annovar" or die $!;
while (<ANNO>){
	chomp;
	if ($.==1) {
		#写入表头
		my $head_col_num=0;
		my @annotation=split/\t/, $_;
		if ($annotation[-1] eq "Otherinfo"){
			@annotation = (@annotation[0..@annotation-2],"AF","qual","DP","chr","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT","Genotype");
		}
		$col_num = @annotation;
		my $color_bg;
		my $format;
		for (my $i = 0; $i < $col_titile; $i++) {
			for (my $j = 0; $j < $col_num; $j++) {
				if ( $title[$i] eq $annotation[$j] ) {
					push @same_col_num, $j;
					$format = $workbook->add_format();
					$format->set_bold();
					$format->set_align('left');
					$color_bg=$title{$title[$i]}{color};
					$format->set_bg_color($color_bg);
					$result->write(0,$head_col_num ,$title[$i],$format);
					$head_col_num = $head_col_num + 1;
					push @title_out, $title[$i];
				}
			}
		}
		$same_col_num = @same_col_num;
	}
	else {
		my $row = $. - 1 ;
		my $n = 0;
		my @annotation=split/\t/, $_;
		my $anno_col = @annotation;
		$result -> set_column(0, $anno_col, 15);
		for ( my $col=0; $col<@same_col_num; $col++ ) {
			$result -> write($row,$col,$annotation[$same_col_num[$col]]);
		}
		for (my $col = $col_num; $col < @annotation; $col++) {
			$result -> write($row,$same_col_num+$n,$annotation[$col]);
			$n++;
		}
	}
}
close ANNO;

my $num = 0;
my $description = $workbook->add_worksheet("Description");
#my $format2 = $workbook->add_format();  #写到循环内！写在循环外为全局变量
#$format2->set_bold();
$description->set_column(0,1,25);
$description->set_column(2,2,100);
foreach my $t ( @title_out ) {
	my $format2 = $workbook->add_format();
	$format2->set_bold();
	$format2->set_bg_color($title{$t}{"color"});
	$description->write($num,0, $title{$t}{"type"},$format2);
	$description->write($num,1, $t,$format2);
	$description->write($num,2, $title{$t}{"description"},$format2);
	$num++;
}

my $End_Time = &TIME;
print "End Time: $End_Time\n";

#Sub-----------------------------

sub TIME {
	return strftime("%Y-%m-%d %H:%M:%S", localtime(time));
}