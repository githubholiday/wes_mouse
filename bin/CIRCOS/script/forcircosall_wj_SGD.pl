#! /usr/perl/bin -w
use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use FindBin qw/$Bin $Script/;
use Cwd;

my $outdir = shift;
my $configFile = shift;
my $chr = shift;
my $outdir1=shift;
my $check_snp_tag=shift;
open IN,"<$check_snp_tag" or die $!;
while (<IN>){
chomp;
 $check_snp_tag=$_;
}
chomp $check_snp_tag;
my %haxi_config;
readconfig($configFile,\%haxi_config);
my ($bands,$circos,$ideogram,$ideogram_label,$ideogram_position,$ticks,$need_chr);
$need_chr =  checkchr($chr);

$bands=<<"HEND";
show_bands            = yes
fill_bands            = yes
band_stroke_thickness = 
band_stroke_color     = white
band_transparency     = 0

HEND
if ($check_snp_tag =~/Single/i) {
$circos=<<"HEND";
<<include colors_fonts_patterns.conf>>
<<include ideogram.conf>>
<<include ticks.conf>>
<image>
<<include etc/image.conf>>
</image>
karyotype   = /annoroad/data1/bioinfo/PMO/yuhui/project/ReSeq_V4/subscript/circos/circos-0.67-6/data/karyotype/karyotype.human.hg19.txt

chromosomes_units = 1000000
chromosomes       = $need_chr
chromosomes_display_default = no

################################################################
# 
# define 3 scatter plots, using the same data file
#

<highlights>
z          = 0
#fill_color = green
<highlight>
file       = ../data/indel.len.txt
</highlight>
</highlights>

<plots>
<plot>
type      = line
thickness = 2
max_gap = 1u
file    = ../data/snp.de.txt
color   = blue
fill_color = no
min     = 0
max     = 1
r1    = 0.98r
r0    = 0.88r
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
r1    = 0.83r
r0    = 0.68r
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
<plot>
</plots>
<links>
</links>
<<include etc/housekeeping.conf>>
HEND
}else{
$circos=<<"HEND";

<<include colors_fonts_patterns.conf>>
<<include ideogram.conf>>
<<include ticks.conf>>

<image>
<<include etc/image.conf>>
</image>

karyotype   = /annoroad/data1/bioinfo/PMO/yuhui/project/ReSeq_V4/subscript/circos/circos-0.67-6/data/karyotype/karyotype.human.hg19.txt

chromosomes_units = 1000000
chromosomes       = $need_chr
chromosomes_display_default = no

################################################################
## 
## define 3 scatter plots, using the same data file
<highlights>
z          = 0
##fill_color = green
<highlight>
file       = ../data/indel.len.txt
</highlight>
</highlights>
<plots>
<plot>
type      = line
thickness = 2
max_gap = 1u
file    = ../data/snp.de.txt
color   = blue
fill_color = no
min     = 0
max     = 1
r1    = 0.98r
r0    = 0.88r
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
r1    = 0.83r
r0    = 0.68r


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
</plots>

<links>
</links>
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
label_radius     = dims(image,radius)-150p
label_size       = 36
label_parallel   = yes
#label_case       = upper
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
