#! /usr/perl/bin -w
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;
use Data::Dumper;

my $Description=my $usage =<<usage;
Usage :
	Function :
	    Display one or more mutation in one circos picture
	Author  :
		Jing Wang
	Date :
		20160930

usage

my ($joblist,$outdir,$chr,$configFile,$check_snp_tag,$config_radius_defined,$help,$karyotype);
GetOptions(
	"joblist:s"=>\$joblist,
    "outdir:s"=>\$outdir,
	"chr:s"=>\$chr,
	"config_radius_defined:s"=>\$config_radius_defined,
	"karyotype:s" => \$karyotype,
	"help:s"=>\$help);
die "$Description" unless ($joblist && $outdir && $chr ||  $help || $config_radius_defined);

$karyotype ||= "";

open Joblist1,"<$joblist" or die $!;
$configFile=$outdir."/../data/config";
my ($plot1,$plot2,$link1,$link2);
$plot1="#<plots>";
$plot2="#</plots>";
$link1="#<links>";
$link2="#</links>";
my $row1=0;
my $row2=0;
my $row3=0;
my $row4=0;
my $SNP_INDEL_num=0;
my $cnv_num=0;
my $LOH_num=0;
my $SV_num=0;
my $Fusion_num=0;

while (<Joblist1>){
	chomp;
	my @mutation=split/\t/,$_;
    if ($mutation[0] eq "SNP_INDEL"){
         $row1=$row1+1;
		 $SNP_INDEL_num=1;
         }
     if($mutation[0] eq "CNV"){
         $row1=$row1+1;
		 $cnv_num=1;
         }
        if($mutation[0] eq "LOH"){
		 $row1=$row1+1;
		 $LOH_num=1;
        }
    if($mutation[0] eq "SV"){
		$row1=$row1+1;
		$row3=$row3+1;
		$SV_num=1;
       }
        if($mutation[0] eq "Fusion"){
		$row1=$row1+1;
		$row3=$row3+1;
		$Fusion_num=1;
       }

}
#/print "$row1\t$row2\t$row3\t$row4";
close Joblist1;
$check_snp_tag=$outdir."/../data/snp_tag";
open IN,"<$check_snp_tag";
while (<IN>){
	chomp;
	$check_snp_tag=$_;
 }
chomp $check_snp_tag;
my %haxi_config;
readconfig($configFile,\%haxi_config);
my ($bands,$circos,$SNP_INDEL_single,$SNP_INDEL_group,$Fusion_label,$SV_CTX,$SV,$LOH,$CNV,$Fusion,$ideogram,$ideogram_label,$last,$ideogram_position,$ticks,$need_chr);
$need_chr =  checkchr($chr);
$bands=<<"HEND";
show_bands            = yes
fill_bands            = yes
band_stroke_thickness =
band_stroke_color     = white
band_transparency     = 0

HEND

$circos=<<"HEND";
<<include colors_fonts_patterns.conf>>
<<include ideogram.conf>>
<<include ticks.conf>>
<image>
<<include etc/image.conf>>
</image>
karyotype   = $karyotype

chromosomes_units = 1000000
chromosomes       = $need_chr
chromosomes_display_default = no
HEND


$last=<<"HEND";
<<include etc/housekeeping.conf>>
HEND

$ideogram=<<"HEND";

<ideogram>

<spacing>
default = 0.005r
break   = 0.5r
</spacing>

<<include ideogram.position.conf>>
<<include ideogram.label.conf>>
<<include bands.conf>>

radius*       = 0.82r

</ideogram>
HEND
$ideogram_label=<<"HEND";

show_label       = yes
label_font       = default
label_radius     = dims(image,radius)-180p
label_size       = 36
label_parallel   = yes
label_case       = upper
label_format     = eval(sprintf("chr%s",var(label)))
HEND

$ideogram_position=<<"HEND";

radius           = 0.775r
thickness        = 30p
fill             = yes
fill_color       = black
stroke_thickness = 2
stroke_color     = black
HEND

$ticks=<<"HEND";

show_ticks          = yes
show_tick_labels    = yes

<ticks>
radius           = dims(ideogram,radius_outer)
orientation      = out
label_multiplier = 1e-6
color            = black
size             = 20p
thickness        = 3p
label_offset     = 5p
format           = %d
<tick>
spacing        = 10u
#show_label     = yes
#label_size     = 20p
size           = 5p
</tick>
<tick>
spacing        = 5u
show_label     = yes
label_size     = 20p
size           = 10p
label_offset   = 10p
</tick>
</ticks>
HEND

#my $PWD=getcwd;
my $config_radius="$Bin/../../config/config.txt";
print "$config_radius\n";
if ($config_radius_defined){
	$config_radius=$config_radius_defined;
}else{
	$config_radius=$config_radius;
	}
#$config_radius=$BIN. '/../'.'config';
open Config_radius,"<$config_radius" or die $!; 
my ($r0,$r1,$r02,$r021,$r121,$r022,$r122,$r03,$r031,$r032,$r033,$r131,$r132,$r133);
my $OUTFILE= "$outdir"."/"."circos.conf";
open(OUT,">$OUTFILE");
print OUT "$circos";
my $circos_num1=0;
my $num1=0;
my $num2=0;
my $num3=0;
my $num4=0;
my $num5=0;
my $num6=0;
my $num7=0;
while (<Config_radius>){
	chomp;
	next if $_=~/^#/;
	next if $_=~/^$/;
	my @radius=split/=/,$_;
	my $element=$radius[0];
	if ($element=~/_radius/){
		my @radius_mutation=split/;/,$radius[1];
		my $circos_num=@radius_mutation;
		#print "$circos_num";
		for(my $i = 0;$i < @radius_mutation;$i++){
			my @radius_mutation_each_circle=split/,/,$radius_mutation[$i];
			my @radius_r0=split/:/,$radius_mutation_each_circle[0];
			my @radius_r1=split/:/,$radius_mutation_each_circle[1];
			#my @radius_r00=split/:/,$radius_r0;
			#my @radius_r11=split/:/,$radius_r1;
			#print "$r0[1]\t$r1[1]\n";
			$r0=$radius_r0[1];
			$r1=$radius_r1[1];
			#print "$r0\t$r1\n";
			$r02=($r1-$r0)/2;
			$r021=$r0;
			$r121=$r0+$r02;
			$r022=$r121;
			$r122=$r1;
			$r03=($r1-$r0)/3;
			$r033=$r0;
			$r133=$r033+$r03;
			$r032=$r133;
			$r132=$r032+$r03;
			$r031=$r132;
			$r131=$r1;
			$r0=$r0."r";
			$r1=$r1."r";
			$r121=$r121."r";
			$r021=$r021."r";
			$r122=$r122."r";
			$r022=$r022."r";
			$r031=$r031."r";
			$r032=$r032."r";
			$r033=$r033."r";
			$r131=$r131."r";
			$r132=$r132."r";
			$r133=$r133."r";
			open Joblist2,"<$joblist" or die $!;
#print OUT "$circos";
	
LOOP1:while (<Joblist2>){
	chomp;
	my@mutation=split/\t/,$_;
	if($num1==0){
	if ($mutation[0] eq "SNP_INDEL"){
		$row2=$row2+1;
		$num1=1;
		if($row2==1){
			$plot1="<plots>";
			#$a="<plots>";
		}else{
			$plot1="#<plots>";
			#$a="#<plots>";
		}
		if($row1==1){
		$plot1="<plots>";
		$plot2="</plots>";
		}else{
		if($row1==$row2){
			$plot2="</plots>";
		}else{
			$plot2="#</plots>";
		}
		}
		if ($check_snp_tag =~/Single/i) {
			#print OUT "$SNP_INDEL_single";
    	output1($plot1,$plot2,$SNP_INDEL_single);
		}else{
			#print OUT "$SNP_INDEL_group";
		output1($plot1,$plot2,$SNP_INDEL_group);
		}
	last LOOP1;
	}
	#last LOOP1;
	}
	$plot1="#<plots>";
	$plot2="#</plots>";
	if($num2==0){
	if($mutation[0] eq "CNV"){
		$row2=$row2+1;
		$num2=1;
		if($row2==1){
			$plot1="<plots>";
		}else{
			$plot1="#<plots>";
		}
		if($row1==1){
			$plot1="<plots>";
			$plot2="</plots>";
		}else{
			if($row1==$row2){
				$plot2="</plots>";
			}else{
				$plot2="#</plots>";
			}
        }
		#print OUT "$CNV";
		output1($plot1,$plot2,$CNV);
	last LOOP1; 
	}
	 #last LOOP1;
	 }
	 $plot1="#<plots>";
	 $plot2="#</plots>";
	 if($num3==0){
	if($mutation[0] eq "LOH"){
		$row2=$row2+1;
		$num3=1;
		if($row2==1){
			$plot1="<plots>";
		}
		if($row1==1){
			$plot1="<plots>";
			$plot2="</plots>";
		}else{
			if($row1==$row2){
				$plot2="</plots>";
			}else{
				$plot2="#</plots>";
			}
    	}
		#print OUT "$LOH";
		output1($plot1,$plot2,$LOH);
	last LOOP1;
	}
	#last LOOP1;
	}
	$plot1="#<plots>";
	$plot2="#</plots>";
	if($num4==0){
	if($mutation[0] eq "SV"){
		$row2=$row2+1;
		$num4=1;
        if($row2==1){
        	$plot1="<plots>";
        }
        if($row1==1){
        	$plot1="<plots>";
        	$plot2="</plots>";
        }else{
        	if($row1==$row2){
        		$plot2="</plots>";
        	}else{
				$plot2="#</plots>";
        	}
		}
		output1($plot1,$plot2,$SV);
	last LOOP1;
	}
	#last LOOP1;
	}
	$plot1="#<plots>";
	$plot2="#</plots>";
	if($num5==0){
	if($mutation[0] eq "Fusion"){
		$row2=$row2+1;
		$num5=1;
        if($row2==1){
        	$plot1="<plots>";
        }
        if($row1==1){
            $plot1="<plots>";
            $plot2="</plots>";
        }else{
        	if($row1==$row2){
            	$plot2="</plots>";
            }else{
				$plot2="#</plots>";
            }
        }
		#print OUT "$Fusion";
		print "$plot1\t$plot2\n";
		output1($plot1,$plot2,$Fusion_label);
	last LOOP1;
	}
	#last LOOP1;
	}
	$plot1="#<plots>";
	$plot2="#</plots>";
}
close Joblist2;

}
	}

}

open Joblist3,"<$joblist" or die $!;
LOOP2:while (<Joblist3>){
	chomp;
	my@mutation=split/\t/,$_;
	if($mutation[0] eq "SV"){
	$row4=$row4+1;
	$num6=1;
	if($row4==1){
       $link1="<links>";
    }else{
       $link1="#<links>";
     }
    if($row3==1){
       $link1="<links>";
       $link2="</links>";
    }else{
       if($row3==$row4){
          $link2="</links>";
       }else{
       }
   }
	output2($link1,$link2,$SV_CTX);
	}
	$link1="#<links>";
	$link2="#</links>";
	if($mutation[0] eq "Fusion"){
	$num6=1;
	$row4=$row4+1;
		if($row4==1){
           $link1="<links>";
        }else{
           $link1="#<links>";
        }
        if($row3==1){
           $link1="<links>";
           $link2="</links>";
        }else{
             if($row3==$row4){
                $link2="</links>";
             }else{
             }
        }
        output2($link1,$link2,$Fusion); 
		}
}
close Joblist3;
print OUT "$last";
close OUT;
output($bands,$outdir,'bands.conf');
#output($circos,$outdir,'circos.conf');
output($ideogram,$outdir,'ideogram.conf');
output($ideogram_label,$outdir,'ideogram.label.conf');
output($ideogram_position,$outdir,'ideogram.position.conf');
output($ticks,$outdir,'ticks.conf');
sub output{
        my $content = shift;
        my $t_outdir = shift;
        my $filename = shift;
my @lines = split('\n',$content);
        print ">".$t_outdir."/".$filename."\n";
        open SC,">".$t_outdir."/".$filename;
        foreach my $line(@lines){
                chomp($line);
                if($line =~ /{{(.+?)}}/){
                        #print $1."\n";
                        my $k = $1;
                        if($k eq 'meanDepth'){
                                my $t_val = $haxi_config{$k} * 2;
                                $line =~ s/{{.+?}}/$t_val/;
                                print SC $line."\n";
                        }
                        elsif($k eq 'maxSnpNum'){
                                $line =~ s/{{.+?}}/$haxi_config{$k}/;
                                print SC $line."\n";
                        }
                        else{

                        }

                }
                else{
                        print SC $line."\n";
                }


        }


        close SC;
}
sub readconfig{
        my $file = shift;
        my $haxi = shift;
        open HH,"$file";
        while(defined(my $line = <HH>)){
                chomp($line);
                my @cell = split('=>',$line);
                ${$haxi}{$cell[0]} = $cell[1];

        }

        close HH;


}

sub test{
        return "bbb";
}

sub checkchr{
        my $chr = shift;
        my @db_chroms;
        foreach  (1..22) {
                push @db_chroms,"hs$_";
        }
        if ($chr eq 'XY') {
                push @db_chroms,"hsX";push @db_chroms,"hsY";
        }elsif ($chr eq 'auto') {
                #pass
        }elsif ($chr eq 'XX') {
                push @db_chroms,"hsX";
        }else {
                @db_chroms = ();
                my @chroms = split/[\;|\,]/,$chr;
                foreach  (@chroms) {
                        $_=~s/chr/hs/;
                        if ($_=~/hs(\d+)/) {
                                if ($1>=23) {
                                        die("chrome name err...\n");
                                }else{
                                        push @db_chroms,$_;
                                }
                        }elsif ($_ eq 'hsX' || $_ eq 'hsY' ) {
                                push @db_chroms,$_;
                        }else {
                                die("chrome name err...\n");
                        }
                }
        }
        return join(";",@db_chroms);
}

sub output1{
	$plot1 = shift;
	$plot2 = shift;
	$SNP_INDEL_single=<<"HEND";
<highlights>
z          = 0
#fill_color = green
<highlight>
file       = ../data/indel.len.txt
</highlight>
</highlights>
$plot1;
<plot>
type      = line
thickness = 2
max_gap = 1u
file    = ../data/snp.de.txt
color   = blue
fill_color = no
min     = 0
max     = 1
r1    = $r122
r0    = $r022
</plot>
<plot>
type             = scatter
stroke_thickness = 2
file             = ../data/snp.txt
fill_color       = grey
stroke_color     = grey
glyph            = circle
glyph_size       = 1
max   = 1
min   = 0
r1    = $r121
r0    = $r021
<backgrounds>
<background>
color = vvlgrey
</background>
</backgrounds>
<axes>
<axis>
color     = vlgrey
thickness = 2
spacing   = 0.25r
</axis>
</axes>
</plot>
$plot2
HEND

$SNP_INDEL_group=<<"HEND";
<highlights>
z          = 0
#fill_color = green
<highlight>
file       = ../data/indel.len.txt
</highlight>
</highlights>
$plot1
<plot>
type      = line
thickness = 2
max_gap = 1u
file    = ../data/snp.de.txt
color   = blue
fill_color = no
min     = 0
max     = 1
r1    = $r122
r0    = $r022
</plot>
<plot>
type             = scatter
stroke_thickness = 2
file             = ../data/snp.txt
fill_color       = grey
stroke_color     = grey
glyph            = circle
glyph_size       = 1
max   = 1
min   = 0
r1    = $r121
r0    = $r021
<backgrounds>
<background>
color = vvlgrey
</background>
</backgrounds>
<axes>
<axis>
color     = vlgrey
thickness = 2
spacing   = 0.25r
</axis>
</axes>
<rules>
<rule>
condition    = (var(value) >=0.75)
stroke_color = red
fill_color   = red
</rule>
<rule>
condition    = (var(value) < 0.25)
stroke_color = green
fill_color   = green
</rule>
</rules>
</plot>
$plot2
HEND

$LOH=<<"HEND";
$plot1
<plot>
type             = scatter
stroke_thickness = 2
file             = ../data/LOH_site.txt
fill_color       = grey
stroke_color     = grey
glyph            = circle
glyph_size       = 1
#max   =
min   = 0
#r1=0.95
#r0=0.84
r1    = $r1
r0    = $r0
<backgrounds>
<background>
color = vvlgrey
</background>
</backgrounds>
<axes>
<axis>
color     = vlgrey
thickness = 1
spacing   = 0.25r
</axis>
</axes>
</plot>
$plot2
HEND
$CNV=<<"HEND";
$plot1
<plot>
type             = scatter
stroke_thickness = 2
file             = ../data/cnv_region.txt
fill_color       = grey
stroke_color     = grey
glyph            = circle
glyph_size       = 3
#max   =
min   = 0
r1    = $r1
r0    = $r0
<backgrounds>
<background>
color = vvlgrey
</background>
</backgrounds>
<axes>
<axis>
color     = vlgrey
thickness = 1
spacing   = 0.25r
</axis>
</axes>
</plot>
$plot2
HEND
$SV=<<"HEND";
$plot1
<plot>
type            = tile
layers_overflow = hide
file        = ../data/sv_DEL.txt
r1= $r131
r0 = $r031
layers      = 4
margin      = 0.0200u
thickness   = 8
padding     = 6
stroke_thickness = 1
stroke_color     = dblue
color            = blue
glyph_size       = 10
<backgrounds>
<background>
color = 176,226,255
#vvlgrey
</background>
</backgrounds>
</plot>
<plot>
type            = tile
layers_overflow = hide
file        = ../data/sv_INS.txt
r1= $r132
r0 = $r032
layers      = 4
margin      = 0.02u
thickness   = 8
padding     = 6
stroke_thickness = 1
stroke_color     = dpgreen
color            = pgreen
glyph_size       = 10
<backgrounds>
<background>
color = 154,255,154
#vvlgrey
</background>
</backgrounds>
</plot>
<plot>
type            = tile
layers_overflow = hide
file        = ../data/sv_DUP.txt
r1= $r133
r0 = $r033
layers      = 4
margin      = 0.0200u
thickness   = 8
padding     = 6
stroke_thickness = 1
stroke_color     = dpred
color            = pred
glyph_size       = 10
<backgrounds>
<background>
color = 238,162,173
</background>
</backgrounds>
</plot>
$plot2
HEND



$Fusion_label=<<"HEND";
$plot1
<plot>
type  = text
file  = ../data/label.txt
color = black
r1    = 1.2r
r0    = 1.1r
label_size = 20
label_font = light
padding    = 5p
rpadding   = 5p
show_links     = yes
link_dims      = 5p,4p,8p,4p,0p
link_thickness = 2
link_color     = dgrey
label_parallel   = no
</plot>
$plot2
HEND
    my $variable = shift;
	print OUT "$variable";
}


sub output2{
	$link1 = shift;
	$link2 = shift;
$Fusion=<<"HEND";
$link1
<link>
file          = ../data/fusion.txt
radius        = 0.4r
bezier_radius = 0r
color         = 127,255,0
thickness     = 8
#<rules>
#<rule>
#condition     = 1
#color = "black"
#color         = eval(var(chr2))
#flow          = continue
#</rule>
#</rules>
</link>
$link2
HEND
$SV_CTX=<<"HEND";
$link1
<link>
file          = ../data/sv_CTX.txt
radius        = 0.4r
#chromosomes_radius=
bezier_radius = 0r
color         = 128,0,255
thickness     = 8
</link>
<link>
file          = ../data/sv_INV.txt
radius        = 0.4r
bezier_radius = 0r
color         = 205,92,92
thickness     = 8
</link>
$link2
HEND
	my $variable1 = shift;
	print OUT "$variable1";
}
