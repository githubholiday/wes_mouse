#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path remove_tree);
my $inputfile_indel = shift;#'test2.vcf';#shift;
my $outputdir = shift;#'b';#shift;
my $need_chrome = shift;#'all'; #shift ;#'auto';
my $need_r0 = 0.55;#'0.875r';# shift;
my $need_resolution = 150;#50;
$need_r0 = $need_r0.'r';
=head1 USAGE
	perl script.pl inputfile_indel.vcf outputdir all/auto/noY/chr1;chr2;...;chrY 0.875r
	perl <script.pl> <inputfile> <outdir> <r0>
	input file is InDel, and the format:VCF 
=cut

=head1 Contact
	Author : zhihuaPei
	E-mail : zhihuaPei@annoroad.com
	Company : AnnoRoad
=cut
die(`pod2text $0`) if (! $inputfile_indel || !$outputdir || !$need_r0 || !$need_chrome);
make_path("$outputdir/data");
make_path("$outputdir/conf");
#判断染色体
my @db_chroms;
foreach  (1..22) {
	push @db_chroms,"chr$_";
}
if ($need_chrome eq 'all') {
	push @db_chroms,"chrX";push @db_chroms,"chrY";
}elsif ($need_chrome eq 'auto') {
	#pass
}elsif ($need_chrome eq 'noY') {
	push @db_chroms,"chrX";
}else {
	@db_chroms = ();
	my @chroms = split/;/,$need_chrome;
	foreach  (@chroms) {
		if ($_=~/chr(\d+)/) {
			if ($1>=23) {
				die(`pod2text $0`);
			}else{
				push @db_chroms,$_;
			}
		}elsif ($_ eq 'chrX' || $_ eq 'chrY' ) {
			push @db_chroms,$_;
		}else {
			die(`pod2text $0`);
		}
	}
}
my %hash_InDel_len_stat=();
my %hash_InDel_len_infos=();
open IN,"<$inputfile_indel" or die $!;
while (<IN>) {
	chomp;
	next if $_=~/\#/;
	my @SNP_infos = split /\t/,$_;
	if ($SNP_infos[6] ne 'PASS') {
		next;
	}
	if ($SNP_infos[3] =~/,/ || $SNP_infos[4] =~/,/) {
		next;
	}
	if ($SNP_infos[0] =~/^chr(.*?)/) {
		#pass
	}else{
		$SNP_infos[0] = 'chr'.$SNP_infos[0];
	}
	next if (!( $SNP_infos[0]=~/^chr(\d+)$/) && $SNP_infos[0] ne 'chrX' && $SNP_infos[0] ne 'chrY');
	my $len = length($SNP_infos[4]) - length($SNP_infos[3]);
	if (!(exists $hash_InDel_len_stat{$SNP_infos[0]})) {
		$hash_InDel_len_stat{$SNP_infos[0]}{'MIN'} = abs($len);
		$hash_InDel_len_stat{$SNP_infos[0]}{'MAX'} = abs($len);
	}
	if (abs($len) > $hash_InDel_len_stat{$SNP_infos[0]}{'MAX'}) {
		$hash_InDel_len_stat{$SNP_infos[0]}{'MAX'} = abs($len);
	}
	if (abs($len) < $hash_InDel_len_stat{$SNP_infos[0]}{'MIN'}) {
		$hash_InDel_len_stat{$SNP_infos[0]}{'MIN'} = abs($len);
	}
	if ($len > 0) {
		push @{$hash_InDel_len_infos{$SNP_infos[0]}},['+',$SNP_infos[0],$SNP_infos[1],$SNP_infos[1]+10,abs($len)];
	}else{
		push @{$hash_InDel_len_infos{$SNP_infos[0]}},['-',$SNP_infos[0],$SNP_infos[1],$SNP_infos[1]+10,abs($len)];
	}
	
}
close IN;
open OUT ,">$outputdir/data/indel.len.txt" or die $!;
foreach my $chr (keys %hash_InDel_len_infos) {
	foreach my $infos (@{$hash_InDel_len_infos{$chr}}) {
		my $normalization = 0;
		#print "$hash_InDel_len_stat{$chr}{'MAX'}\t$hash_InDel_len_stat{$chr}{'MIN'}\n";next;
		($hash_InDel_len_stat{$chr}{'MAX'} - $hash_InDel_len_stat{$chr}{'MIN'})==0?($normalization =0):(
			$normalization = ($$infos[4] - $hash_InDel_len_stat{$chr}{'MIN'})/($hash_InDel_len_stat{$chr}{'MAX'} - $hash_InDel_len_stat{$chr}{'MIN'})	
		);
		next if $normalization == 0;
		#need_resolution
		my $str_chr = $chr;
		$str_chr =~s/chr/hs/;
		if ($$infos[0] eq '+') {
			print OUT "$str_chr\t$$infos[2]\t$$infos[3]\tr0=$need_r0,r1=$need_r0+",$normalization*$need_resolution,"p,stroke_thickness=4,stroke_color=vdblue\n";
		}else{
			print OUT "$str_chr\t$$infos[2]\t$$infos[3]\tr0=$need_r0-",$normalization*$need_resolution,"p,r1=$need_r0,stroke_thickness=4,stroke_color=vdpyellow\n";
		}
	}
}
close OUT;
%hash_InDel_len_stat=();
%hash_InDel_len_infos=();
exit(0);
