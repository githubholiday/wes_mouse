#! /usr/perl/bin -w
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;
my ($outdir,$configFile,$karyotype,$sample);
use Getopt::Long;
GetOptions(
    "o=s"=>\$outdir,
    "c=s"=>\$configFile,
    "k=s"=>\$karyotype,
    "s=s"=>\$sample,
);
my $usage=<<USAGE;
    -o 输出文件夹；
    -c 配置文件；
    -k circos的karyotyep文件；
    -s 样品名。
USAGE
if(!$outdir || !$configFile || !$karyotype ||!$sample)
{
	die"$usage\n";
}
my %haxi_config;
readconfig($configFile,\%haxi_config);
my ($bands,$circos,$ideogram,$ideogram_label,$ideogram_position,$ticks);
my $chr=load_karyotype($karyotype);
my $dir=dirname($configFile);
my ($dup,$inv,$del,$tra);
$dup=<<DUP;
<plot>
type            = tile
layers_overflow = hide
file        = $dir/sv_DUP.txt
r1          = 0.65r
r0          = 0.61r
orientation = in

layers      = 15
margin      = 0.02u
thickness   = 10
padding     = 5

stroke_thickness = 3
stroke_color     = dpred
color            = pred

<backgrounds>
<background>
color = 238,162,173
</background>
</backgrounds>
</plot>
DUP

$inv=<<INV;
<plot>
type            = tile
layers_overflow = hide
file        = $dir/sv_INV.txt
r1          = 0.60r
r0          = 0.56r
orientation = in

layers      = 15
margin      = 0.02u
thickness   = 10
padding     = 5

stroke_thickness = 3
stroke_color     = dpgreen
color            = pgreen

<backgrounds>
<background>
color = 154,255,154
</background>
</backgrounds>
</plot>
INV
$del=<<DEL;
<plot>
type            = tile
layers_overflow = hide
file        = $dir/sv_DEL.txt
r1          = 0.70r
r0          = 0.66r
orientation = in

layers      = 15
margin      = 0.02u
thickness   = 10
padding     = 5

stroke_thickness = 3
stroke_color     = dblue
color            = blue

<backgrounds>
<background>
color = 176,226,255
#vvlgrey
</background>
</backgrounds>
</plot>
DEL

unless (-e "$dir/sv_DUP.txt"){
    $dup="";
}
unless (-e "$dir/sv_INV.txt"){
    $inv="";
}
unless (-e "$dir/sv_DEL.txt"){
    $del="";
}

$bands=<<"HEND";
show_bands            = yes
fill_bands            = yes
band_stroke_thickness = 2
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

karyotype   = $dir/$sample.karyotype.txt

chromosomes_units = 100000
chromosomes       = $chr

chromosomes_display_default = yes

################################################################
# 
# define 3 scatter plots, using the same data file
#

<highlights>
z          = 0
fill_color = green

##2 start
<highlight>
file       = $dir/indel.txt
r0         = 0.91r
r1         = 0.95r
stroke_thickness = 1
stroke_color     = dgreen
</highlight>
##2 end

</highlights>


<plots>

##1 start
#<plot>
#type      = line
#thickness = 2
#max_gap = 1u
#file    = $dir/min.depth
#color   = vdgrey
#min     = 0
#max     = {{meanDepth}}
#r0      = 0.94r
#r1      = 0.99r

#fill_color = vdgrey_a3
#<axes>
#<axis>

#color     = blue
#thickness = 1
#spacing   = 0.2r

#</axis>
#</axes>

#</plot>
##1 end

##3 start
<plot>

type      = histogram
file      = $dir/snp.regNum.txt
orientation = in
r1        = 0.87r
r0        = 0.82r
max       = {{maxSnpNum}}
min       = 0

stroke_type = outline
thickness   = 1
color       = vdgrey
extend_bin  = no

<backgrounds>
<background>
color = vvlgrey
</background>
</backgrounds>

<axes>
<axis>
spacing   = 0.1r
color     = lgrey
thickness = 2
</axis>
</axes>

<rules>
<rule>
use       = no
condition = var(value) < 0
show      = no
</rule>
<rule>
#condition  = var(value) < 0
condition  = 1
#fill_color = lred
fill_color = eval(sprintf("spectral-9-div-%d",remap_int(var(value),0,{{maxSnpNum}},1,9)))
</rule>
</rules>

</plot>
##3 end

#<plot>
#type      = line
#thickness = 2
#
#max_gap = 1u
#file    = ../data/max.depth
#color   = red
#fill_color = red_a4
#min     = 0
#max     = {{meanDepth}}
#r0      = 0.94r
#r1      = 0.99r
#
#<axes>
#<axis>
#
#color     = blue
#thickness = 1
#spacing   = 0.2r
#
#</axis>
#</axes>
#
#</plot>

##4 start
$del
##4 end


##5 start
$dup
##5 end

##6 start
$inv
##6 end

</plots>

HEND

if(-f "$dir/sv_TRA.txt")
{
$circos.=<<"HEND";
<links>
##7 start
<link>
file          = $dir/sv_TRA.txt
radius        = 0.51r
bezier_radius = 0r
color         = black_a4
thickness     = 2

<rules>
<rule>
condition     = 1
color         = eval(var(chr2))
flow          = continue

</rule>
</rules>
</link>
##7 start
</links>

<<include etc/housekeeping.conf>>

HEND
}
else
{
$circos.=<<"HEND";
<<include etc/housekeeping.conf>>
HEND
}

$ideogram=<<"HEND";

<ideogram>

<spacing>
default = 0.005r
break   = 0.5r
</spacing>

<<include ideogram.position.conf>>
<<include ideogram.label.conf>>
<<include bands.conf>>

radius*       = 0.85r

</ideogram>

HEND

$ideogram_label=<<"HEND";

show_label       = yes
label_font       = default
label_radius     = dims(image,radius)-160p
label_size       = 20
label_parallel   = no
#label_case       = lower
#label_format     = eval(sprintf("chr%s",var(label)))

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
size             = 36p
thickness        = 3p
label_offset     = 5p
format           = %.1f

<tick>
spacing        = 1u
#show_label     = yes
#label_size     = 20p
size           = 15p
</tick>

<tick>
spacing        = 5u
show_label     = yes
label_size     = 24p
</tick>

</ticks>


HEND

#my ($bands,$circos,$ideogram,$ideogram_label,$ideogram_position,$ticks);

output($bands,$outdir,'bands.conf');
output($circos,$outdir,'circos.conf');
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
		if($line =~ /{{(.+?)}}/){#
			#print $1."\n";
			my $k = $1;
			if($k eq 'meanDepth'){
				my $t_val = $haxi_config{$k} * 2;
				#print $haxi_config{$k};die;
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

sub load_karyotype
{
	my ($file)=@_;
	open (IN,$file)||die "can't open file $file\n";
	my $chr;
	while (<IN>)
	{
		chomp;
		my @tmp=split/\s+/,$_;
		$chr.="$tmp[2];";
	}
	$chr=~s/;$//;
	return $chr;
}
