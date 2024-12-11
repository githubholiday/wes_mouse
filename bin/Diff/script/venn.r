args = commandArgs(T)
if (length(args) <3 ){
	print('Rscript venn.r  <out pdf> <filelist> <main>')
	q()
}

filelist<-as.matrix(read.table(args[2],header=F,sep="\t"))
filenames=filelist[,1]
n<-dim(filelist)[1];


if (n == 2){
	A<-read.table(filelist[1,2],header=T,sep="\t")
	B<-read.table(filelist[2,2],header=T,sep="\t")
	list<-list(A[,1],B[,1])
	library(VennDiagram)
	library(grid)
	strright=max(strwidth(filenames,units="inches",cex=0.6,font=2))
	print(strright)
	venn.plot<-venn.diagram(list,
						filename=args[1],
						main = args[3],
						main.cex = 1,
						category.names = filenames,
						cat.just=list(c(0.7,-3),c(0.3,-3)),
						imagetype = "png",		#孟昊20170725
						#width = 2000,
						#height = 2000,
						col = "black",
						lty = 0,
						lwd = 0.4,
						fill = c("forestgreen", "goldenrod2"),
						alpha = 0.40,
						cex = 1,
						fontfamily = "serif",
						fontface = "bold",
						cat.col = c("black", "black"),
						cat.cex = 1,
						cat.fontfamily = "serif",
				);
}

if(n == 3){
	A<-read.table(filelist[1,2],header=T,sep="\t")
	B<-read.table(filelist[2,2],header=T,sep="\t")
	C<-read.table(filelist[3,2],header=T,sep="\t")
	list<-list(A[,1],B[,1],C[,1])
	library(VennDiagram)
	library(grid)
	print(filenames)
	venn.plot<-venn.diagram(list,
						filename=args[1],
						main = args[3],
						main.cex = 1,
						category.names = filenames,
						imagetype = "png",
						#width = 2000,
						#height = 2000,
						col = "black",
						lty = 0,
						lwd = 0.4,
						fill = c("forestgreen", "dodgerblue3","#e0861a"),
						alpha = 0.40,
						cex = 1,
						fontfamily = "serif",
						fontface = "bold",
						cat.col = c("black", "black", "black"),
						cat.cex = 1,
						cat.fontfamily = "serif",
				);
}

if (n==4){
	A<-read.table(filelist[1,2],header=T,sep="\t")
	B<-read.table(filelist[2,2],header=T,sep="\t")
	C<-read.table(filelist[3,2],header=T,sep="\t")
	D<-read.table(filelist[4,2],header=T,sep="\t")
	list<-list(A[,1],B[,1],C[,1],D[,1])
	library(VennDiagram)
	library(grid)
	print(filenames)
	#par(mar=c(1,2,2,4))
	strright=max(strwidth(filenames,units="inches",cex=0.6,font=2))
	print(strright)
	venn.plot<-venn.diagram(list,
						filename=args[1],
						main = args[3],
						main.cex = 1,
						cat.just=list(c(0.35,2),c(0.5,1),c(0.35,2),c(0.5,1)),
						category.names = filenames,
						imagetype = "png",
						#width = 3000,
						#height = 3000,
						col = "black",
						lty = 0,
						lwd = 0.5,
						fill = c("dodgerblue3", "forestgreen", "goldenrod2", "darkorchid1"),
						alpha = 0.40,
						cex = 1,
						fontfamily = "serif",
						fontface = "bold",
						cat.col = c("black", "black", "black","black"),
						cat.cex = 1,
						cat.fontfamily = "serif",
				);
}

if (n==5){
	A<-read.table(filelist[1,2],header=T,sep="\t")
	B<-read.table(filelist[2,2],header=T,sep="\t")
	C<-read.table(filelist[3,2],header=T,sep="\t")
	D<-read.table(filelist[4,2],header=T,sep="\t")
	E<-read.table(filelist[5,2],header=T,sep="\t")
	list<-list(A[,1],B[,1],C[,1],D[,1],E[,1])
	library(VennDiagram)
	library(grid)
	strright=max(strwidth(filenames,units="inches",cex=0.6,font=2))
	venn.plot<-venn.diagram(list,
						filename=args[1],
						main =args[3],
						main.cex = 1,
						cat.just=list(c(0.5,1),c(0.1,-5),c(0.5,0),c(0.5,0),c(1,-5)),
						category.names = filenames,
						imagetype = "png",
						width = 3000,
						height = 3000,
						col = "black",
						lty = 0,
						lwd = 0.5,
						fill = c("dodgerblue3", "forestgreen", "#f15a22","darkorchid1","#ffe600"),
						alpha = 0.40,
						cex = 0.8,
						fontfamily = "serif",
						fontface = "bold",
						cat.col = c("black", "black", "black","black", "black"),
						cat.cex = 1,
						cat.fontfamily = "serif",
				);
}
