#!/usr/bin/perl -w
# 
# Copyright (c) fanshu 2015
# Writer: fanshu
# Program Date: 2015.
# Modifier: fanshu
# Last Modified: 2015.
my $ver="1.0";

use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

######################请在写程序之前，一定写明时间、程序用途、参数说明；每次修改程序时，也请做好注释工作
my %opts;
GetOptions(\%opts,"annovar=s","key=s","od=s","type=s","v=s","h","rscript=s" );


if(!defined($opts{annovar}) || !defined($opts{key})|| !defined($opts{od})|| defined($opts{h}))
{
	print << "Usage End.";

	Description:
	Version: $ver
	Usage:

		-annovar annovar result                                    must be given
				
		-key     output file key name                              must be given
		
		-od      output dir                                        must be given
		
		-type    call varient type:[default ind],pair or pop       option
        -v       snp or indel                                      必需参数；
		-h       Help document
		
Usage End.

	exit;

}

###############Time
my $Time_Start;
$Time_Start = sub_format_datetime(localtime(time()));
print "\nStart Time :[$Time_Start]\n\n";
################
my $Rscript=$opts{rscript};
my $annovar=$opts{annovar}; $annovar=Absolute_Dir($annovar,"file");
my $key=$opts{key}; 
my $od=$opts{od};$od=Absolute_Dir($od,"dir");
my $type=defined $opts{type} ?$opts{type}:"ind";

my $name=basename($annovar);
my $indel;
if ($opts{v} eq "snp"){
    $indel=0;
}
elsif ($opts{v} eq "indel"){
    $indel=1;
}
else{
    die "请用-v 参数指明是snp 还是indel（只接受这两个字符串）\n";
}
#my $indel=0;
#$indel=1 if($name =~/INDEL/);

my %var_region;			#stat1
my %var_exon;			#stat2
my %snp_ts_tv;			#stat3
my %var_homo_hete;		#stat3
my %indel_length;		#stat5
my %snp_base;			#stat6
my $total=0;

my %TS_TV=(
	"AT"=>"TV",
	"TA"=>"TV",
	"GC"=>"TV",
	"CG"=>"TV",
	"AC"=>"TV",
	"TG"=>"TV",
	"CA"=>"TV",
	"GT"=>"TV",
	"AG"=>"TS",
	"GA"=>"TS",
	"TC"=>"TS",
	"CT"=>"TS",
);

my %snp_pattern =(
	"A-T"=>"T-A",
	"A-C"=>"T-G",
	"A-G"=>"T-C",
	"G-C"=>"C-G",
	"G-T"=>"C-A",
	"G-A"=>"C-T",
	"T-A"=>"T-A",
	"T-C"=>"T-C",
	"T-G"=>"T-G",
	"C-A"=>"C-A",
	"C-T"=>"C-T",
	"C-G"=>"C-G",
);
########load file;
open (IN,"$annovar")||die "can't open file $annovar \n";
while(<IN>)
{
	chomp;
	next if(/^$/ || /^\#/ || /Alt/);
	my ($chr,$start,$end,$ref,$alt,$Func_knownGene,$Gene_knownGene,$GeneDetail_knownGene,$ExonicFunc_knownGene,@tmp)=split/\t/,$_;
	$total++;
	$var_region{$Func_knownGene}++;
	#if($Func_knownGene eq "exonic"){print "$ExonicFunc_knownGene\n";die;}
	
	$var_exon{$ExonicFunc_knownGene}++ if($Func_knownGene eq "exonic");
	if($indel ==1)
	{
		my $len=(length($ref)>length($alt))?length($ref):length($alt);
		$indel_length{all}{$len}++;
		$indel_length{exon}{$len}++ if($Func_knownGene eq "exonic");
	}
	else
	{
		#next if($alt =~/,/);
		my @alt=split/,|\//,$alt;
		foreach my $a (@alt)
		{
			if(exists $TS_TV{"$ref$a"})
			{
				$snp_ts_tv{all}{$TS_TV{"$ref$a"}}++;
				$snp_ts_tv{exon}{$TS_TV{"$ref$a"}}++ if($Func_knownGene eq "exonic");
			}
			else
			{
                print "there is strange mutation type $ref to $alt in $chr,$start\n";
			}
			$snp_base{$snp_pattern{$ref."-".$a}}++;
		}

	}
	if($type eq "ind")
	{
		my $hete=(split/:/,$tmp[-1])[0];
		my @geno=split/\//,$hete;
		if((scalar @geno ==1) || ($geno[0] eq $geno[1]))
		{
			$var_homo_hete{all}{homo}++;
			if($Func_knownGene eq "exonic")
			{
				$var_homo_hete{exon}{homo}++;
			}
		}
		else
		{
			$var_homo_hete{all}{hete}++;
			if($Func_knownGene eq "exonic")
			{
				$var_homo_hete{exon}{hete}++;
			}
		}
	}
}
###
my $stat="$od/$key";
if($indel==1){$stat.=".INDEL"}
else{$stat.=".SNP"}
#### 1 snp in genome region stat
my @stand=("UTR5","UTR3","UTR5;UTR3","exonic","splicing","exonic;splicing","upstream","downstream","upstream;downstream","intronic","intergenic","ncRNA_UTR3","ncRNA_UTR5","ncRNA_exonic","ncRNA_splicing","ncRNA_intronic");
my $output;my $other=0;my %pdf;
foreach my $s(@stand)
{
	$var_region{$s}=0 if(!exists $var_region{$s});
	my $per=H_format($var_region{$s}/$total*100);
	$output.="$s\t".H_format($var_region{$s})."\t".$per."\n";
	$pdf{(split/;|_/,$s)[0]}+=$var_region{$s};
	delete $var_region{$s};
}

foreach my $s (keys %var_region)
{
	$other+=$var_region{$s};
}
my $per=$other/$total*100;
$output.="other\t".H_format($other)."\t".H_format($per)."\n";
my $format_total=H_format($total);
my $stat1=$stat.".genome.region.stat.txt";
open (O1,">$stat1")||die "can't creat file $stat1\n";
print O1 "#$key\tNumber\tPercent(%)\nTotal\t$format_total\t100.00\n$output";
close O1;

my $pdf1=$stat.".genome.region.stat.picture.list"; 
open (P,">$pdf1")||die "can't creat file $pdf1\n";
print P "Type\t$key\n";
foreach my $s (sort keys %pdf)
{
	my $p=0;
	$p=H_format($pdf{$s}/$total*100) if($total!=0);
	print P "$s($p\%)\t$p\n";
}
my $p=0;
$p=H_format($other/$total*100) if($total!=0);
print P "other($p\%)\t$p\n";
close P;

print "$Rscript $Bin/anno.pie.r $pdf1 $stat.genome.region.stat.pdf $key T 0 1\n";
`$Rscript $Bin/anno.pie.r $pdf1 $stat.genome.region.stat.pdf $key T 0 1`;
`convert $stat.genome.region.stat.pdf $stat.genome.region.stat.png`;
### 2 snp or in exon stat
my @snp_exon_type=("nonsynonymous SNV","synonymous SNV","stopgain","stoploss","unknown");
my @indel_exon_type=("frameshift deletion","frameshift insertion","nonframeshift deletion","nonframeshift insertion","stopgain","stoploss","unknown");
my $stat2=$stat.".ExonicFunc.stat.txt";
my $pdf2=$stat.".ExonicFunc.stat.picture.list";
open (P2,">$pdf2")||die "can't creat file $pdf2\n";
print P2 "Type\t$key\n";
$output="";my $total2=0;$other=0;
foreach my $s (keys %var_exon)
{
	$total2+=$var_exon{$s};
}
if($indel==1)
{
	foreach my $s (@indel_exon_type)
	{
		$var_exon{$s}=0 if(!exists $var_exon{$s});
		my $per;
		if($total2==0){$per=0}
		else{$per=H_format($var_exon{$s}/$total2*100);}
		$output.="$s\t".H_format($var_exon{$s})."\t".$per."\n";
		$other+=$var_exon{$s};
		print P2 "$s($per\%)\t$per\n";
	}
}
else
{
	foreach my $s (@snp_exon_type)
	{
		$var_exon{$s}=0 if(!exists $var_exon{$s});
		my $per;
		if($total2==0){$per=0}
		else{$per=H_format($var_exon{$s}/$total2*100);}
		$output.="$s\t".H_format($var_exon{$s})."\t".$per."\n";
		$other+=$var_exon{$s};
		print P2 "$s($per\%)\t$per\n";
	}
}
close P2;
`sed -i 's/SNV/SNP/g' $pdf2`;
$other=$total2-$other;
if($other!=0){print "ExonicFunc pattern is strange,the other type number is $other\n";}
open (O2,">$stat2")||die "can't creat file $stat2\n";
my $newtotal2=H_format($total2);
#print O2 "#$key\tNumber\tPercent(%)\nTotal\t$total2\t100.00\n$output";  ##by renxue 20181112
print O2 "#$key\tNumber\tPercent(%)\nTotal\t$newtotal2\t100.00\n$output";
close O2;
`sed -i 's/SNV/SNP/g' $stat2`;

if($total2!=0)
{
	print "$Rscript $Bin/anno.pie.r $pdf2 $stat.ExonicFunc.stat.pdf $key T 0 1\n";
	`$Rscript $Bin/anno.pie.r $pdf2 $stat.ExonicFunc.stat.pdf $key T 0 1`;
	`convert $stat.ExonicFunc.stat.pdf $stat.ExonicFunc.stat.png`;
}
####### 3 snp_ts_tv stat
$output="";$other=0;
if($indel !=1)
{
	my $stat3=$stat.".TS_TV.stat.txt";
	$snp_ts_tv{all}{TS}=0 if(!exists $snp_ts_tv{all}{TS});
	$snp_ts_tv{all}{TV}=0 if(!exists $snp_ts_tv{all}{TV});
	$snp_ts_tv{exon}{TS}=0 if(!exists $snp_ts_tv{exon}{TS});
	$snp_ts_tv{exon}{TV}=0 if(!exists $snp_ts_tv{exon}{TV});
	my $p1="-";my $p2="-";
	$p1=$snp_ts_tv{all}{TS}/$snp_ts_tv{all}{TV} if($snp_ts_tv{all}{TV}!=0);
	$p2=$snp_ts_tv{exon}{TS}/$snp_ts_tv{exon}{TV} if($snp_ts_tv{exon}{TV}!=0);
	
	$output.=H_format($snp_ts_tv{all}{TS})."\t".H_format($snp_ts_tv{all}{TV})."\t".H_format($p1)."\t";
	$output.=H_format($snp_ts_tv{exon}{TS})."\t".H_format($snp_ts_tv{exon}{TV})."\t".H_format($p2)."\n";
	open (O3,">$stat3")||die "can't creat file $stat3\n";
	print O3 "#Sample\tTS_genome\tTV_genome\tTS/TV_genome\tTS_exonic\tTV_exonic\tTS/TV_exonic\n";
	print O3 "$key\t$output";
	close O3;
}

######## 4 var_homo_hete stat
$output="";$other=0;
if($type eq "ind")
{
	my $stat4=$stat.".homo_hete.stat.txt";
	my $pdf4=$stat.".homo_hete.stat.picture.list";
	$var_homo_hete{all}{homo}=0 if(!exists $var_homo_hete{all}{homo});
	$var_homo_hete{all}{hete}=0 if(!exists $var_homo_hete{all}{hete});
	$var_homo_hete{exon}{homo}=0 if(!exists $var_homo_hete{exon}{homo});
	$var_homo_hete{exon}{hete}=0 if(!exists $var_homo_hete{exon}{hete});
	my ($p1,$p2,$p3,$p4)=(0,0,0,0);
	if(($var_homo_hete{all}{homo}+$var_homo_hete{all}{hete})!=0)
	{
		$p1=H_format($var_homo_hete{all}{homo}/($var_homo_hete{all}{homo}+$var_homo_hete{all}{hete})*100);
		$p2=H_format($var_homo_hete{all}{hete}/($var_homo_hete{all}{homo}+$var_homo_hete{all}{hete})*100);
	}
	if(($var_homo_hete{exon}{homo}+$var_homo_hete{exon}{hete})!=0)
	{
		$p3=H_format($var_homo_hete{exon}{homo}/($var_homo_hete{exon}{homo}+$var_homo_hete{exon}{hete})*100);
		$p4=H_format($var_homo_hete{exon}{hete}/($var_homo_hete{exon}{homo}+$var_homo_hete{exon}{hete})*100);
	}
	$output.="Number\t".H_format($var_homo_hete{all}{homo})."\t".H_format($var_homo_hete{all}{hete})."\t";
	$output.=H_format($var_homo_hete{exon}{homo})."\t".H_format($var_homo_hete{exon}{hete})."\n";
	$output.="Percentage(%)\t$p1\t$p2\t$p3\t$p4\n";
	open (O4,">$stat4")||die "can't creat file $stat4\n";
	print O4 "#$key\tHom_genome\tHet_genome\tHom_exonic\tHet_exonic\n$output";
	close O4;
	open (P4,">$pdf4")||die "can't creat file $pdf4\n";
	print P4 "Type\t$key\nHom_genome\t$p1\nHet_genome\t$p2\nHom_exonic\t$p3\nHet_exonic\t$p4\n";
	close P4;
}

######### 5 indel_length
$output="";$other=0;
if($indel ==1)
{
	my $stat5=$stat.".length.pattern.stat.txt";
	my $pdf5=$stat.".length.pattern.stat.picture.list";
	my $all_len;my $exon_len;
	for(my $s=1;$s<=10;$s++)
	{
		$indel_length{all}{$s}=0 if(!exists $indel_length{all}{$s});
		$indel_length{exon}{$s}=0 if(!exists $indel_length{exon}{$s});
		$output.="$s\t".H_format($indel_length{all}{$s})."\t".H_format($indel_length{exon}{$s})."\n";
		$all_len.="Genome($s)\t$indel_length{all}{$s}\n";
		$exon_len.="Exonic($s)\t$indel_length{exon}{$s}\n";
		delete $indel_length{all}{$s};
		delete $indel_length{exon}{$s};
	}
	my $len1=0;my $len2=0;
	foreach my $s (sort keys %{$indel_length{all}})
	{
		$len1+=$indel_length{all}{$s};
	}
	foreach my $s (sort keys %{$indel_length{exon}})
	{
		$len2+=$indel_length{exon}{$s};
	}
	$output.=">10\t".H_format($len1)."\t".H_format($len2)."\n";
	open (O5,">$stat5")||die "can't creat file $stat5\n";
	print O5 "\#$key\tGenome\tExonic\n$output";
	close O5;
	open (P5,">$pdf5")||die "can't creat file $pdf5\n";
	print P5 "Type\t$key\n$all_len"."Genome(>10)\t$len1\n"."$exon_len"."Exonic(>10)\t$len2\n";
	close P5;
	print "$Rscript $Bin/anno.indel_len.r $pdf5 $stat.length.pattern.stat.pdf $key \n";
	`$Rscript $Bin/anno.indel_len.r $pdf5 $stat.length.pattern.stat.pdf $key`;
	`convert $stat.length.pattern.stat.pdf $stat.length.pattern.stat.png`;

}

###### 6 snp_base
$output="";$other=0;
if($indel !=1)
{
	my $stat6=$stat.".mutation.pattern.stat.txt";
	my $pdf6=$stat.".mutation.pattern.stat.picture.list";
	my $tt=0;
	foreach my $t (keys %snp_base) {$tt+=$snp_base{$t}}
	open (P6,">$pdf6")||die "can't creat file $pdf6\n";
	print P6 "Type\t$key\n";
	my @pattern=("T-A","T-C","T-G","C-A","C-T","C-G");
	foreach my $s (@pattern) 
	{
		$snp_base{$s}=0 if(!exists $snp_base{$s});
		$output.="$s\t".H_format($snp_base{$s})."\n";
		my $p=0;
		$p=H_format($snp_base{$s}/$tt*100) if($tt!=0);
		print P6 "$s($p\%)\t$p\n";
	}
	open (O6,">$stat6")||die "can't creat file $stat6\n";
	print O6 "\#Sample\t$key\n$output";
	close O6;
	close P6;
	print "$Rscript $Bin/anno.pie.r $pdf6 $stat.mutation.pattern.stat.pdf $key T 0 1\n";
	`$Rscript $Bin/anno.pie.r $pdf6 $stat.mutation.pattern.stat.pdf $key T 0 1`;
	`convert $stat.mutation.pattern.stat.pdf $stat.mutation.pattern.stat.png`;
}

###############Time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

###############Subs
sub sub_format_datetime {#Time calculation subroutine
 my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
 $wday = $yday = $isdst = 0;
 sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}


######Absolute_Dir(file,"file") or Absolute_Dir(dir,"dir")
sub Absolute_Dir
{
	my ($ff,$type)=@_;
	my $cur_dir=`pwd`;
	chomp $cur_dir;
	if($ff !~/\// && $type eq "file")
	{
		$ff=$cur_dir."/".$ff;
	}
	elsif($ff !~/\// && $type eq "dir")
	{
		$ff=$cur_dir."/".$ff;
		if(!-d $ff){`mkdir -p $ff`}
	}
	elsif($type eq "dir")
	{
		if(!-d $ff){`mkdir -p $ff`}
	}
	return $ff;
}
####fasta format
sub Fasta_format
{
	my ($seq,$len)=@_;
	my $format;
	my @seq=split//,$seq;
	for(my $i=0;$i<length($seq);$i++)
	{
		$format.="$seq[$i]";
		if(($i+1)%$len==0){$format.="\n";}
	}
	if(length($seq)%$len!=0){$format.="\n";}
	return $format;
}

sub H_format{
	my $tmp = $_[0];

	if($tmp =~ /^\d*\.\d*$/){
		$tmp = sprintf("%0.2f",$tmp);
		return $tmp;
	}
	elsif($tmp =~ /^\d+$/){
		$tmp =reverse $tmp;
		$tmp=~s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
		return reverse($tmp);
	}
	else{
		 return $tmp;
	}
}
