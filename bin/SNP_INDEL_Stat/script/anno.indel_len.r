args <- commandArgs(TRUE)
if (length(args) != 3){
		print("Rscript anno.indel_len.r <InFile> <OutFile> <Title>")
		print("Example : anno.indel_len.r list pdf Test ")
		q()
}

a<-read.table(args[1],header = TRUE,sep="\t") #######read data
pdf(args[2], height=6,width=8)
par(font=2,font.lab=2,font.axis=2,cex.lab=1.5,cex.axis=1,mar=c(5.5,4.2,1.5,4.2),mgp=c(2,0.7,0))

max <- max(a[1:11,2])
max=max+5;
barplot(a[1:11,2], ylim = c(0, max), xlim = c(1, 35), space = 2, ylab = "", col = "#96cdcd", axes=F, axisnames = F,border=NA)
axis(4,font.axis=2,cex.axis=1)
mtext(side=4, line = 2.5, "Number in Genome",font=2,cex=1.5)
axis(1, at=c(1:11 * 3 - 1), labels = c(1,2,3,4,5,6,7,8,9,10,">10"), tick = F,font.axis=2,cex.axis=1.3)
par(new=TRUE)
max <- max(a[12:22,2])
max=max+5;
barplot(a[12:22,2], ylim = c(0, max), xlim = c(2, 36), space = 2, ylab = "Number in Exonic", col = "#CD5C5C", axes=F, axisnames = F,main=args[3],border=NA)
axis(2,font.axis=2,cex.axis=1)
mtext(side=1, line = 3, "InDel Length",font=2,cex=1.5)
legend("topright",col=c("#CD5C5C","#96cdcd"),pch=22,pt.bg=c("#CD5C5C","#96cdcd"),legend=c("Exonic","Genome"),cex=1.3,pt.cex=1.5,border="white")
box(bty="u")
dev.off()
