#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Basename;

unless (@ARGV >= 4) {
    die "usage : perl $0 tempdir tumorbam normalbam outprefix configfile\n";
}

#########Get the parameters
my $middled = shift;
my $tumor = shift;
my $normal = shift;
my $outprefix = shift;
my $config = shift;
$config ||= "$Bin/../config/pairedTumor.config";

my (%config);
&parse_config($config);

#########generate the 2bit fafile
my $name = basename $config{'REF'};
my $status = '';
unless ($config{'fa.2bit'}) {
    $status = `$config{'faToTwoBit'} $config{'REF'} $middled/$name.2bit && echo -ne "done"`;
    unless ($status eq "done") {
        wait;
    } else {
        print STDERR "fa2bit done\n";
        $config{'fa.2bit'} = "$middled/$name.2bit";
    }
}

#########Start the gfServer by random port
my $file = basename $tumor;
if (-e "$middled/gfServer.log") {
    system("rm $middled/gfServer.log");
}
srand;
my $port=int(rand(65535));
my $cmd = "nohup $config{'gfServer'} start $config{'blat.host'} $port $config{'fa.2bit'} -log=$middled/gfServer.log &";
system($cmd);

########Run the CREST.pl
while ("1") {
	#print "$config{PERL}";
	if (-e "$middled/gfServer.log") {
        my $check =`cat $middled/gfServer.log|grep "Server ready for queries"|wc -l`;
        if($check == 1) {
            my $cmd="export PERL5LIB=`dirname $config{CREST}`:\$PERL5LIB && ";
            $cmd .= "export PATH=`dirname $config{CAP3}`:`dirname $config{BLAT}`:\$PATH";
            if (-e  "$middled/$file.cover") {
                $cmd .="&& $config{PERL} $config{CREST} --blatserver $config{'blat.host'} --blatport $port -f $middled/$file.cover -d $tumor -g $normal --ref_genome $config{REF} -t $config{'fa.2bit'} -o $middled -p $outprefix $config{CREST_Somatic_command}";
                my $tmp = system($cmd);
                print STDERR "Somatic_SV by CREST done\n" if ($tmp == 0);
                last;
            } else {
                die "没找到.cover文件\n";
            }
        }
    }
}

########Stop the gfServer and kill the nohup job
system("$config{'gfServer'} stop $config{'blat.host'} $port");
my $id = `id -u`;
print "$id";
chomp($id);
#my $pid = `ps -fe|awk '\$1==$id&&\$8~/gfServer/{printf \$2}'`;
my $pid = `ps -fe |grep $id  |grep gfServer |grep -v "grep" |awk '{print \$2}'`;
if(!$pid) {
    my $name = `id -nu`;
    chomp($name);
	#$pid = `ps -fe|awk '\$1==$name&&\$8~/gfServer/{printf \$2}'`;
	$pid = `ps -fe |grep $name  |grep gfServer |grep -v "grep" |awk '{print \$2}'`;
}
print "check **** $pid\n";
system("kill $pid");

########Get parameters in Config file
sub parse_config {
    my $conifg_file = shift; 
    open IN,$conifg_file || die "fail open: $conifg_file";
    while (<IN>) {
        chomp;
        next if (/^#/);
        if (/(\S+)\s*=\s*(.*)#*/){
            $config{$1}=$2;
        }
    }
    close IN;
}

#######Check the running status of sh jobs
sub mysystem {
    my $cmd = shift;
    if (system($cmd) != 0) { 
        die "not completely,$cmd\n" ;
    } else {
        print STDOUT "$cmd";                                                 
    }
    return $?;
}
