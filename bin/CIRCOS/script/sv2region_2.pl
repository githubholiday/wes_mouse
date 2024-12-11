use strict;

my $indir = shift;
my $kt = shift;
my $outdir = shift;

my %haxi_faid_hsid;
my %haxi_faid_len;
readkt($kt,\%haxi_faid_hsid,\%haxi_faid_len);

my @files = glob("$indir/*.vcf");

foreach my $file(@files){
	my $class;
	if($file =~ /$indir\/(.+?)\.vcf/){
		$class = $1;
	}
	
	if($class eq 'DEL' || $class eq 'DUP' || $class eq 'INV'){
		open HH,"$file";
		open SC,">$outdir"."/"."sv_".$class.".txt";
		while(defined(my $line = <HH>)){
			chomp($line);		
			if($line !~ /^#/){
				my @cell = split('\t',$line);
				if($cell[6] eq 'PASS' && $line =~ /;END=(.+?);/){
					print SC $haxi_faid_hsid{$cell[0]}." ".$cell[1]." ".$1." id=".$cell[2]."\n";
				}			
			}
		}
		close SC;
		close HH;
	}
	elsif($class eq 'TRA'){
		open HH,"$file";
		open SC,">$outdir"."/"."sv_".$class.".txt";
		while(defined(my $line = <HH>)){
			chomp($line);		
			if($line !~ /^#/){
				my @cell = split('\t',$line);

				if($cell[6] eq 'PASS' && $line =~ /;CHR2=(.+?);END=(.+?);/){
					print SC $haxi_faid_hsid{$cell[0]}." ".$cell[1]." ".$cell[1]." ".$haxi_faid_hsid{$1}." ".$2." ".$2."\n";
				}		
			}
		}
		close SC;
		close HH;		
		
		
	}
	else{
		
		
	}
	
	
}




sub readkt{
	my $filekt = shift;
	my $haxi = shift;
	my $haxi_len = shift;
	
	open HH,"$filekt";
	while(defined(my $line = <HH>)){
		chomp($line);
		my @cell = split(' ',$line);
		#print $cell[6]."\t".$cell[2]."\n";
		${$haxi}{$cell[3]} = $cell[2];
		${$haxi_len}{$cell[3]} = $cell[5];
		
		
	}
	
	
	close HH;
	
	
	
}