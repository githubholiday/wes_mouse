use strict;

#my %haxi_seq;
my %haxi_len;
#readfa_seq($ARGV[0],\%haxi_seq);
readfa_length($ARGV[0],\%haxi_len);

#sort { $hash{$a} <=> $hash{$b} }

open SC,">$ARGV[1]";
foreach my $id(sort {$haxi_len{$b} <=> $haxi_len{$a}} keys %haxi_len){
	print SC $id."\t".$haxi_len{$id}."\n";		
}
close SC;

open SC,">$ARGV[2]";
my $i = 1;
my $total_len = 0;
foreach my $id(sort {$haxi_len{$b} <=> $haxi_len{$a}} keys %haxi_len){
	#chr - hs1 1 0 249250621 chr1
	#print SC "chr - hs$i $i 0 ".($haxi_len{$id}-1)." $id\n";	
	print SC "chr - hs$i $id 0 ".($haxi_len{$id}-1)." chr"."$i\n";
	$total_len+=$haxi_len{$id};
	$i++;	
}
close SC;

#system("rm $ARGV[3]");
open SC,">>$ARGV[3]";
print SC "spaceMin=>".int(($total_len/1000))."\n";
print SC "spaceMax=>".int(($total_len/100))."\n";
close SC;




sub readfa_seq{
	my $fafile = shift;
	my $haxi = shift;
	
	my $id;
	my $seq;
	open HH,"$ARGV[0]";

	while(defined(my $line = <HH>)){
		chomp($line);
		if($line =~ /^>(.+?) /){

			if($id){
				${$haxi}{$id} = $seq;	
			}
			$id = "";
			$seq = "";
			
			$id = $1;
		}
		else{
			$seq .= $line;
		}

	}
	if($id){
		${$haxi}{$id} = $seq;	
	}

	close HH;
	
}


sub readfa_length{
	my $fafile = shift;
	my $haxi = shift;
	
	my $id;
	my $len = 0;
	open HH,"$ARGV[0]";

	while(defined(my $line = <HH>)){
		chomp($line);
		if($line =~ /^>(.+?) / || $line =~ /^>(.*)/){

			if($id){
				${$haxi}{$id} = $len;	
			}
			$id = "";
			$len = 0;
			
			$id = $1;

		}
		else{
			$len += length($line);
		}

	}

	if($id){
		${$haxi}{$id} = $len;	
	}

	close HH;
	
}

sub show_haxi{
	my $haxi = shift;
	foreach my $id(sort keys %{$haxi}){
		print $id."\t".${$haxi}{$id}."\n";
		
	}
	
	
	
}
