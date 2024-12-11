#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use Cwd;
use File::Basename;

my $help=<<USAGE;
USAGE:
	-sample		        ：  Must be given
	-inputlist          :   Must be given, The input list (Format:SampleID\\tSample_ReportName\\tPolidy(1/2)\\tLib\\tTotalid\\tRawfqdir)
	-outdir             :   Must be given
	-MonoPath           :   Sofeware Mono path ,defult(/annoroad/data1/bioinfo/PMO/yuhui/software_me/mono-2.10.9/bin/mono)
	-PairedEnd          :   Default (True) //Automatically pair two fastq files as one sample to run fusion analysis
	-RnaMode            :   Default (True) //Detect fusion results
	-ThreadNumber 	    :	Default (1)    //Possible values: 1-100. Default value=1
	-FileFormat 	    :	Default (FASTQ)//Possible values: FASTQ, QSEQ, FASTA. Default value=FASTQ
	-CompressionMethod	:	Default (Gzip) //Gzip formatted input files
	-Gzip               :	Default (True) //Gzip
	-QualityEncoding	:	Default (Automatic) //Auto detect quality coding in the fastq file or specify with Illumina or Sanger
	-AutoPenalty        :	Default (True) //Set alignment penalty cutoff to automatic based on read length: Max (2,(read length-31)/15)
	-FixedPenalty	    :	Default (2)    //If AutoPenalty=False, Fixed Penalty will be used
	-FilterUnlikelyFusionReads      :	Default (True)  //Enable filtering step
	-FullLengthPenaltyProportion    :	Default (8)     //Filtering normal reads allowing 8% of alignment mismatches of the reads
	-MinimalFusionAlignmentLength	:	Default (0)     //Default (alpha in the paper) value=0 and the program will automatically set Min(25, Max(17,floor(ReadLength/3))). The program will use the specified value if user sets any > 0
	-FusionReportCutoff	:	Default (1)    //# of allowed mutiple hits of read ends; Possible values: 1-5. Default value=1 (beta in paper)
	-NonCanonicalSpliceJunctionPenalty	:	Default (4) //Possible values: 0-10. Default value = 2 (G)
	-MinimalHit         :   Default (2)    //Minimal distinct fusion read; Possible values: 1-10000, Default value =2
	-MinimalRescuedReadNumber       :   Default (1)     //Minimal rescued read number. Default value = 1   
	-MinimalFusionSpan  :   Default (5000) //Minimal distance (bp) between two fusion breakpoints
	-RealignToGenome    :   Default (True) //If True, seed read ends are re-aligned to genome to see if it is <= FusionReportCutoff in RNA-Seq
	-OutputFusionReads  :   Default (True) //Out put Fusion reads as BAM files for genome browser. Default value = True

USAGE
my ( $sample,$inputlist,$outdir,$MonoPath,$PairedEnd,$RnaMode,$ThreadNumber,$FileFormat,$CompressionMethod,$Gzip,$QualityEncoding,$AutoPenalty,$FixedPenalty,$FilterUnlikelyFusionReads,$FullLengthPenaltyProportion,$MinimalFusionAlignmentLength,$FusionReportCutoff,$NonCanonicalSpliceJunctionPenalty,$MinimalHit,$MinimalRescuedReadNumber,$MinimalFusionSpan,$RealignToGenome,$OutputFusionReads);

GetOptions
(
	 "sample:s"  =>\$sample,
	 "inputlist:s"	=>\$inputlist,
	 "outdir:s"     =>\$outdir,
	 "MonoPath:s"     =>\$MonoPath,
	 "PairedEnd:s"		=>\$PairedEnd,
	 "RnaMode:s"		=>\$RnaMode,
	 "ThreadNumber:s"	=>\$ThreadNumber,
	 "FileFormat:s"	=>\$FileFormat,
	 "CompressionMethod:s"	=>\$CompressionMethod,
	 "Gzip:s"	=>\$Gzip,
	 "QualityEncoding:s"	=>\$QualityEncoding,
	 "AutoPenalty:s"	=>\$AutoPenalty,
	 "FixedPenalty:s"	=>\$FixedPenalty,
	 "FilterUnlikelyFusionReads:s"	=>\$FilterUnlikelyFusionReads,
	 "FullLengthPenaltyProportion:s"        =>\$FullLengthPenaltyProportion,
	 "MinimalFusionAlignmentLength:s"	=>\$MinimalFusionAlignmentLength,
	 "FusionReportCutoff:s"	=>\$FusionReportCutoff,
	 "NonCanonicalSpliceJunctionPenalty:s"	=>\$NonCanonicalSpliceJunctionPenalty,
	 "MinimalHit:s"=>\$MinimalHit,
	 "MinimalRescuedReadNumber:s"	=>\$MinimalRescuedReadNumber,
	 "MinimalFusionSpan:s"	=>\$MinimalFusionSpan,
	 "RealignToGenome:s"	=>\$RealignToGenome,
	 "OutputFusionReads:s"	=>\$OutputFusionReads,

);
die "$help" unless( defined $inputlist and defined $outdir and defined $sample);
print "\n";
############  for the basic parameter  -----------------------------------------------------------------------------------
print "input list file : $inputlist \n";
print "sample : $sample \n";
print "result output : $outdir/FusionGene/result \n";
####---------------------------------------------------
$MonoPath ||="/annoroad/data1/bioinfo/PMO/yuhui/software_me/mono-2.10.9/bin/mono";
$PairedEnd ||="True";
$RnaMode ||="True";
$ThreadNumber ||="1";
$FileFormat ||= "FASTQ";
$CompressionMethod ||= "Gzip";
$Gzip ||="True";
$QualityEncoding ||="Automatic";
$AutoPenalty ||="True";
$FixedPenalty ||="2";
$FilterUnlikelyFusionReads ||="True";
$FullLengthPenaltyProportion ||="8";
$MinimalFusionAlignmentLength ||= "0";
$FusionReportCutoff ||= "1";
$NonCanonicalSpliceJunctionPenalty ||= "4";
$MinimalHit ||= "2";
$MinimalRescuedReadNumber ||="1";
$MinimalFusionSpan ||= "5000";
$RealignToGenome ||="True";
$OutputFusionReads ||="True";

my %ploidy;

open LIST,$inputlist or die "$!";
while (<LIST>) {
	chomp;
	my @a = split /\s+/;
	$ploidy{$a[1]}=$a[4];
}
close LIST;

open SH,">$outdir/FusionGene/sh/$sample.config" or die "$!";
my $id= basename $ploidy{$sample};
	
print SH "<Files>\n";
print SH "$outdir/FQ/Result/RawData/$sample/$sample"."_R1.fq.gz\n";
print SH "$outdir/FQ/Result/RawData/$sample/$sample"."_R1.fq.gz\n";
print SH "\n";
print SH "<Options>\n";
print SH "//with all available options\n";
print SH "/MonoPath option is required when path to mono are not in PATH and job cannot start for spawn off jobs\n";
print SH "MonoPath=$MonoPath\n";
print SH "PairedEnd=$PairedEnd\n";
print SH "RnaMode=$RnaMode\n";
print SH "ThreadNumber=$ThreadNumber\n";
print SH "FileFormat=$FileFormat\n";
print SH "CompressionMethod=$CompressionMethod\n";
print SH "Gzip=$Gzip\n";
print SH "QualityEncoding=$QualityEncoding\n";
print SH "AutoPenalty=$AutoPenalty\n";
print SH "FixedPenalty=$FixedPenalty\n";
print SH "FilterUnlikelyFusionReads=$FilterUnlikelyFusionReads\n";
print SH "FullLengthPenaltyProportion=$FullLengthPenaltyProportion\n";
print SH "MinimalFusionAlignmentLength=$MinimalFusionAlignmentLength\n";
print SH "FusionReportCutoff=$FusionReportCutoff\n";
print SH "NonCanonicalSpliceJunctionPenalty=$NonCanonicalSpliceJunctionPenalty\n";
print SH "MinimalHit=$MinimalHit\n";
print SH "MinimalRescuedReadNumber=$MinimalRescuedReadNumber\n";
print SH "MinimalFusionSpan=$MinimalFusionSpan\n";
print SH "RealignToGenome=$RealignToGenome\n";
print SH "OutputFusionReads=$OutputFusionReads\n";
print SH "\n";
print SH "<Output>\n";
print SH "TempPath=$outdir/FusionGene/Intermediate/\n";
print SH "OutputPath=$outdir/FusionGene/Intermediate/"."$sample\n";
print SH "OutputName=$sample\n";
	
close SH;


