open strict;


open HH,"less $ARGV[0] |";

while(defined(my $line = <HH>)){
	chomp($line);
	print $line."\n";
	
	if($line =~ /^>/){
		
		
	}
	else{
		
		
	}
	
	
}


close HH;