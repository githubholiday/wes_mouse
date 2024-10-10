Args <- commandArgs(T)
input <- Args[1];
output <- Args[2];
samName <- Args[3];
pdf(output, height=6,width=8)
par(font=2,font.lab=2,font.axis=2,cex.lab=1.5,cex.axis=1,mar=c(5.5,4.2,1.5,4.2),mgp=c(2,0.7,0))

data = read.table(input,header = TRUE,stringsAsFactors = FALSE,  check.names = FALSE,quote = "",sep="\t")

tmp <- log10(data[,1])
tmp1 <- log10(data[,2])
tmp2 <- log10(data[,3])
tmp3 <- log10(data[,4])

aa <-ceiling(max(c(tmp,tmp1,tmp2,tmp3),na.rm = TRUE))
a=hist(c(tmp,tmp1,tmp2,tmp3),breaks=10,plot=F)

e=hist(tmp,breaks=seq(0,aa,0.5),plot=F)
e1=hist(tmp1,breaks=seq(0,aa,0.5),plot=F)
e2=hist(tmp2,breaks=seq(0,aa,0.5),plot=F)
e3=hist(tmp3,breaks=seq(0,aa,0.5),plot=F)
maxy = max(e$count,e1$count,e2$count,e3$count)
print(maxy)
hist(tmp,breaks=seq(0,aa,0.5),col="blue",xlab="Length(log10)",ylab="Number of SV",main=samName,ylim=c(0,maxy));
hist(tmp1,add=T,breaks=seq(0,aa,0.5),col="red",xlab="",ylab="",main="");
hist(tmp2,add=T,breaks=seq(0,aa,0.5),col="cyan",xlab="",ylab="",main="");
hist(tmp3,add=T,breaks=seq(0,aa,0.5),col="yellow",xlab="",ylab="",main="");

legend("topleft",col=c("black","black"),pch=22,pt.bg=c("blue","red","cyan","yellow"),legend=names(data),cex=1.3,pt.cex=1.5)

dev.off()


