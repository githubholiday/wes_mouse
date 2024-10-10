#!/usr/bin/perl
use strict;
use warnings;
my $usage =<<usage;

Usage :
    perl $0 sampleclass(value="single" or "pair") AnnotationFile NewformatAnnotationFile
Function :
    add Ref/Alt(Fre) Quality into the inputfile's 6th and 7th column,others are same
Author  :
    Xuelian Han(<xuelian2008ing\@sina.com>)
Date :
    20160601

usage
unless (@ARGV == 3) {
    print "$usage\n";
    exit 1;
}
my ($class,$in,$new) = @ARGV;
open IN,"<$in" or die "fail read $in:$!\n";
open OUT,">$new" or die "fail output $new:$!\n";
my $tile = 0;
my $columns = 0;
my $quality="\.";
while (<IN>) {
    chomp;
    my @one = split /\t/;
    $columns = @one if ($. > 1);
    my ($ADfre,$judge,$AD,$ADtile,$RD,$RDtile) = ();
	if ($. == 1) {
        $tile = @one;
        print OUT join("\t",@one[0..4]),"\tRef/Alt(Fre)\tQuality\t",join("\t",@one[5..($tile-1)]),"\n";
    }
    else {
	    if($class eq "single") {
            if (/\*\*/) {
                my @more = split /\*\*/;
                my @otherinfo = split /\t/,$more[-1];
                $judge = $otherinfo[10];
                $AD = (split /\:/,$otherinfo[-1])[1];
                $ADtile = (split /\:/,$otherinfo[-2])[1];
                if ($judge eq "PASS") {
                    $quality = $otherinfo[9];
                } else {
		  		print STDERR "Wrong : input file format is not correct\n";
                    exit;
                }
            }
            else {
                $judge = $one[($tile - 1) + 9];
                if ($judge eq "PASS") {
                    $quality = $one[($tile - 1) + 8];
                }
                else {
                    print STDERR "Wrong : input file format is not correct\n";
                    exit;
                }
                $AD = (split /\:/,$one[-1])[1];
                $ADtile = (split /\:/,$one[-2])[1];
            }
            if ($ADtile eq "AD") {
                $ADfre = &MAF($AD);
            }
            else {
			    $ADfre ="\.";
			    print STDERR "Wrong : input file format is not correct\n";
                exit;
            }
            print OUT join("\t",@one[0..4]),"\t$ADfre\t$quality\t",join("\t",@one[5..($columns-1)]),"\n" if $ADfre;
        }
	    elsif ($class eq "pair"){
	        if (/\*\*/) {
                my @more = split /\*\*/;
                my @otherinfo = split /\t/,$more[-1];
                $judge = $otherinfo[10];
                if ($judge eq "PASS") {
                    my $quality = $otherinfo[9];
                }
                else {
				    print STDERR "Wrong : input file format is not correct\n";
                    exit;
                }
			}
	        else{
	            #$judge = $one[($tile - 1) + 9];
                #if ($judge eq "PASS") {
                    my $quality = $one[($tile - 1) + 8];
                #}
                #else {
                #    print STDERR "Wrong : input file format is not correct\n";
                #    exit;
                #}
	        }
            #$AD = (split /\:/,$one[-1])[4];
			#$RD= (split /\:/,$one[-1])[3];
            #$ADtile = (split /\:/,$one[-3])[4];
			#$RDtile = (split /\:/,$one[-3])[3];
	        #if (($ADtile eq "AD") && ($RDtile eq "RD")) {
		    #   my $fre = sprintf("%.2f", $AD/($AD+$RD));
			#   my @array=($RD,$AD);
			#   my $bases1=join('/',@array);
			#   $ADfre="$bases1\($fre\)";
            #}
            #else {
			#    print STDERR "Wrong : input file format is not correct\n";
            #    exit;
            #}
            $ADfre = (split /:/, $one[-1])[-1];
		    print OUT join("\t",@one[0..4]),"\t$ADfre\t$quality\t",join("\t",@one[5..($columns-1)]),"\n" if $ADfre;
	    }
    }
}
close IN;
close OUT;

sub MAF {
    my ($ad) = @_;
    my $final = "";
    my @tem = split /\,/,$ad;
    my $bases = join('/',@tem);
    my $maf = '';
    if (@tem == 2) {
        if(($tem[0]+$tem[1])>0){
            $maf = sprintf("%.2f",$tem[1]/($tem[0]+$tem[1]));
            $final = "$bases\($maf\)";
		}
    } elsif (@tem > 2) {
        my $sum = shift @tem;
        my $small = $tem[0];
        $sum += $tem[0];
        for(my $j=1;$j<@tem;$j++) {
            $sum += $tem[$j];
            if($small == 0) {
                $small = $tem[$j];
            } else {
                $small = $tem[$j] if ($tem[$j] < $small && $tem[$j] != 0);
            }
        }
        $maf = sprintf("%.2f",$small/$sum);
        $final = "$bases\($maf\)";
    } else {
        print STDERR "Filter : have less 2 genotypes , @tem\n";
    }
    return $final;
}
