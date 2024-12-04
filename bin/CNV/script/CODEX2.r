args<-commandArgs(TRUE)
if (length(args) < 33) {
        print ("Rscript CODEX.r <BamFile_dir> <Samplelist> <BedFile> <ProjectName> <Map_threshold> <Cov_threshold> <length_threshold> <mapp_threshold> <gc_threshold> <lmax> <mode> <outdir> <ref>");
        q();
        }
library(CODEX2);
library(WES.1KG.WUGSC)
library(BSgenome.Mmusculus.UCSC.mm10)
setwd(args[12]);
#if (args[13] == "hg19"){
#	genome = BSgenome.Hsapiens.UCSC.hg19
#	}else if (args[13] == "hg38"){
#	genome = BSgenome.Hsapiens.UCSC.hg38
#	}else{
#	print("你输入的第13个参数不是hg19或者hg38,此分析不可做")
#	q();
#} 
dirPath <- args[1];
sampname <- as.matrix(read.table(args[2],sep="\t",header=F));
sampname<-as.matrix(sampname[,2]);
bamFile<-array();
for(i in 1:length(sampname)){
bamFile[i]<-list.files(paste(dirPath,"/",sampname[i],"/",sep=""),pattern = '*.rmdup.bam$');
}

bamdir <- file.path(paste(dirPath,"/",sampname,"/",sep=""), bamFile);
bedFile <- file.path(args[3]);
bedFile_info<-read.table(bedFile,sep="\t",header=F);

#getgc =function (ref, genome = NULL) {
#  if(is.null(genome)){genome=BSgenome.Hsapiens.UCSC.hg19}
 # gc=rep(NA,length(ref))
 # for(chr in unique(seqnames(ref))){
 #   message("Getting GC content for chr ", chr, sep = "")
 #   chr.index=which(as.matrix(seqnames(ref))==chr)
 #   ref.chr=IRanges(start= start(ref)[chr.index] , end = end(ref)[chr.index])
 #   if (chr == "X" | chr == "x" | chr == "chrX" | chr == "chrx") {
  #    chrtemp <- 'chrX'
  #  } else if (chr == "Y" | chr == "y" | chr == "chrY" | chr == "chry") {
  #    chrtemp <- 'chrY'
  #  } else {
  #    chrtemp <- as.numeric(mapSeqlevels(as.character(chr), "NCBI")[1])
  #  }
   # if (length(chrtemp) == 0) message("Chromosome cannot be found in NCBI Homo sapiens database!")
  #  chrm <- unmasked(genome[[chrtemp]])
  #  seqs <- Views(chrm, ref.chr)
  #  af <- alphabetFrequency(seqs, baseOnly = TRUE, as.prob = TRUE)
  #  gc[chr.index] <- round((af[, "G"] + af[, "C"]) * 100, 2)
 # }
 # gc
#}

getmapp = function (ref, genome = BSgenome.Mmusculus.UCSC.mm10, bed) {
  if(is.null(genome)){genome = BSgenome.Hsapiens.UCSC.hg19}
  #if(genome@metadata$genome == 'hg19'){mapp_gref = mapp_hg19}
  #if(genome@metadata$genome == 'hg38'){mapp_gref = mapp_hg38}
  mapp <- rep(1, length(ref))
  seqlevelsStyle(ref)='UCSC'

  for(chr in unique(seqnames(ref))){
    message("Getting mappability for ", chr, sep = "")
    chr.index=which(as.matrix(seqnames(ref))==chr)
    ref.chr=GRanges(seqnames=chr, ranges=IRanges(start= start(ref)[chr.index] , end = end(ref)[chr.index]))
    mapp.chr=rep(1, length(ref.chr))
    overlap=as.matrix(findOverlaps(ref.chr, mapp_gref))
    for(i in unique(overlap[,1])){
      index.temp=overlap[which(overlap[,1]==i),2]
      mapp.chr[i]=sum((mapp_gref$score[index.temp])*(width(mapp_gref)[index.temp]))/
        sum(width(mapp_gref)[index.temp])
    }
  mapp[chr.index]=mapp.chr
  }
  mapp
}

if(length(sampname) > 1){
	bambedObj <- getbambed(bamdir = bamdir, bedFile = bedFile,sampname = sampname, projectname = args[4])
    bamdir <- bambedObj$bamdir; 
    sampname <- bambedObj$sampname
    ref <- bambedObj$ref; 
    projectname <- bambedObj$projectname; 
	if(args[5] == "" || args[5]==" "){
		mapqthres<-20;
	}else{
		mapqthres<-as.numeric(args[5]);
	}
	coverageObj <- getcoverage(bambedObj, mapqthres = mapqthres); # 耗时较久1小时
	Y<-coverageObj$Y; 
	gc <- getgc(ref, genome=BSgenome.Mmusculus.UCSC.mm10);
	mapp <- getmapp(ref, genome);
	if(args[6]=="" || args[6]==" "){
		cov_thresh<-c(20,4000);
	}else{
		cov_thresh<-as.numeric(strsplit(args[6],",")[[1]]);
	}
	if(args[7]=="" || args[7]== " "){
		length_thresh<-c(20, 2000);
	}else{
		length_thresh<-as.numeric(strsplit(args[7],",")[[1]]);
	}
	if(args[8]=="" || args[8]== " "){
		mapp_thresh<-0.9;
	}else{
		mapp_thresh<-as.numeric(args[8]);
	}
	if(args[9]=="" || args[9]== " "){
		gc_thresh<-c(20, 80);
	}else{
		gc_thresh<-as.numeric(strsplit(args[9],",")[[1]]);
	}
	values(ref) <- cbind(values(ref), DataFrame(gc, mapp))
	qcObj <- qc(Y, sampname, ref, cov_thresh = cov_thresh,length_thresh = length_thresh, mapp_thresh = mapp_thresh, gc_thresh = gc_thresh)
	Y_qc <- qcObj$Y_qc; sampname_qc <- qcObj$sampname_qc
	ref_qc <- qcObj$ref_qc; qcmat <- qcObj$qcmat; gc_qc <- ref_qc$gc
	write.table(qcmat, file = paste(projectname, '_qcmatrix', '.txt', sep=''),sep = '\t', quote = FALSE, row.names = FALSE)
	
	Y.nonzero <- Y_qc[apply(Y_qc, 1, function(x){!any(x==0)}),]
	pseudo.sample <- apply(Y.nonzero,1,function(x){exp(1/length(x)*sum(log(x)))})
	N <- apply(apply(Y.nonzero, 2, function(x){x/pseudo.sample}), 2, median)
    if (length(sampname) > 4){
        normObj <- normalize_null(Y_qc, gc_qc, K = 1:4,N=N)
    }else{
	    normObj <- normalize_null(Y_qc, gc_qc, K = 1:length(sampname),N=N)  # 耗时很久的步骤2-3小时
    }
	# normObj <- normalize_null(Y_qc, gc_qc, K = 1:4, N=N);
	Yhat <- normObj$Yhat;
	AIC <- normObj$AIC;
	BIC <- normObj$BIC
	RSS <- normObj$RSS; 
	K <- normObj$K;
	choiceofK(AIC, BIC, RSS, K, filename = paste(projectname, "_", "choiceofK", ".pdf", sep = ""));


	optK = K[which.max(BIC)];
	if(args[10]=="" || args[10]== " "){
		lmax<-1000;
	}else{
		lmax<-as.numeric(args[10]);
	}
	if(args[11]=="" || args[11]==" "){
		mode<-"integer";
	}else{
		mode<-args[11];
	}
	outdir<-args[12];
	for (i in unique(seqnames(ref_qc))){
		if (i !="chrX" & i !="chrY"){
			print(i)
			chr.index <- which(as.matrix(seqnames(ref_qc))==i)
			optK = which.max(BIC)
			finalcall.CBS <- segmentCBS(Y_qc[chr.index,], Yhat, optK = optK,K = 1:5,sampname_qc = colnames(Y_qc), chr = i,ref_qc = ranges(ref_qc)[chr.index], lmax = 400, mode = mode)
			write.table(format(finalcall.CBS, sci=FALSE), file = paste(outdir,"/",projectname, '_', i, '_', optK,'_CNV.txt', sep=''), sep='\t', quote=FALSE, row.names=FALSE)
			write.table(qcmat, file = paste(outdir,"/",projectname, '_',i,"_qcmat.txt",sep=''), sep='\t', quote=FALSE, row.names=FALSE)
		}
	}
}else{
	print("该流程仅支持多样本分析，不支持单样本分析，流程退出")
	q()
}
