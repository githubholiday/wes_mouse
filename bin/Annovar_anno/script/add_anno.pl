#!/usr/bin/perl
use strict;
use warnings;
my $usage = <<USAGE;
*********************************************************************************
Usage   : perl $0 input1 input2 input3 input4 output
Author  : Xuelian Han
*********************************************************************************
input1
     ANNOVAR annotation output file,with tile,seperate by tab
input2
     another annotation result file,which needed to be formated into ANNOVAR file
     with tile,seperate by tab
     1st column value of this file,must same in ANNOVAR's x column
input3
     which x column of ANNOVAR file is same with input2's first column,started from 1 
input4
     dot or other signal to represent no result,dot means .
output
     outputfile
*********************************************************************************
USAGE

unless (@ARGV == 5) {
    print $usage;
    exit 1;
}
my ($orig,$data,$col,$sig,$new) = @ARGV;

##########Get the content of sprot.anno
my %data = ();
my $addtitle = '';
my $addnum = 0;
open DB,"<$data" or die "fail read $data:$!\n";
my $num22=0;
while (<DB>) {
    chomp;
    my @tem = split /\t/;
    my $title = shift @tem; #first column is addconnect title
	$num22=@tem;
    if ($. == 1) {
        $addtitle = join("\t",@tem); #first line is columnnames
        $addnum = @tem;
    } else {
        $data{$title} = join("\t",@tem);
    }
}
close DB;

my $null = '';
if ($sig eq 'dot') {
    $null = '.';
    $null .= "\t\." x ($addnum - 1);
} else {
    $null = $sig;
    $null .= "\t$sig" x ($addnum - 1);
}

open ORIG,"<$orig" or die "fail read $orig:$!\n";
open OUT,">$new" or die "fail output $new:$!\n";
my $total = 0;
my $num1=0;
my $num2=0;
while (<ORIG>) {
    chomp;
    my @tem = split /\t/;
    if ($. == 1) {
        my $last = pop @tem;
        $total = @tem; #record the first line's database numbers,beside otherinfo
        my $part1 = join("\t",@tem);
        print OUT $part1,"\t$addtitle\t$last\n";
    } else {
        my $total2 = @tem - 1;
        my $first = join("\t",@tem[0..($total-1)]);
        my $third = join("\t",@tem[$total..$total2]);
        my $second = '';
        my $geneall = $tem[$col - 1];
		 $geneall =~s/;/,/;
        if ($geneall =~ /\,/) {
            my @tem = split /\,/,$geneall;
			my $num=@tem;
            foreach (@tem) {
				$num2++;
                if (exists $data{$_}) {
				      $num1++;
					  if($num2>$num1){
					  $second .= '||';
					  }
                    $second .= $data{$_};
                } else {
                    $second .= $null;
                }
				if(($num2 <$num)){
					if($num1 >0){
						$second .= '||';
					}
				}
				if(($num1==0)){
				$second = $null;
				}
				#print "$second\n";
            }
        } else {
            if (exists $data{$geneall}) {
                $second = $data{$geneall};
            } else {
                $second = $null;
            }
        }
		if($num1 > 0 && $num2 >1){
			my @array=split/\|\|/,$second;
			my $element=$array[0];
			my @b1=split/\t/,$element;
			for (my $i=1;$i<@array;$i++){
				my @b=split/\t/,$array[$i];
				for(my $j=0;$j<@b;$j++){
				$b1[$j]="$b1[$j]"."\|\|"."$b[$j]";
			}
			}
		$second=join("\t",@b1);
		#print "$second\n";
		}
        print OUT $first,"\t$second\t$third\n"; 
}
$num1=0;
$num2=0;
}
close ORIG;
close OUT;

