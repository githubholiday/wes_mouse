args<-commandArgs(T);
#Rscript draw.r input_file output.pdf Read1_length Read2_length output_2.pdf
data<-read.table(args[1],header=F)
length1=as.numeric(args[3])
length2=as.numeric(args[4])



sum=as.numeric(data$V2)+as.numeric(data$V3)+as.numeric(data$V4)+as.numeric(data$V5)+as.numeric(data$V6)
dd<-c(data$V2/sum*100,data$V3/sum*100,data$V4/sum*100,data$V5/sum*100,data$V6/sum*100);
content_max=max(dd);

pdf(args[2],w=8,h=6)
opar<-par()
par(mar=c(2.5, 2.5, 2.5, 0.25))
high=70
if(content_max>70)
	high=90

low=0
w=1.5
posi=(length1+length2)*3/4;
step_length = ifelse((length1+length2) <= 250, 10, 25)
xais=seq(0,(length1+length2),step_length)
yais=seq(low,high,10)
plot(data$V1,data$V2/sum*100,type="l",bty="l",col="red",ylim=c(low,high),xlab="",ylab="",xaxt="n", yaxt="n")
points(data$V1,data$V2/sum*100, col = "red",pch=20)
lines(data$V1,data$V3/sum*100,col="blue",lwd=w)
points(data$V1,data$V3/sum*100, col = "blue",pch=20)
lines(data$V1,data$V4/sum*100,col="green",lwd=w)
points(data$V1,data$V4/sum*100, col = "green",pch=20)
lines(data$V1,data$V5/sum*100,col="darkmagenta",lwd=w)
points(data$V1,data$V5/sum*100, col = "darkmagenta",pch=20)
lines(data$V1,data$V6/sum*100,col="turquoise4",lwd=w)
points(data$V1,data$V6/sum*100, col = "turquoise4",pch=20)
legend(posi,65, c("A%","T%","C%", "G%","N%"),lwd=1,cex=0.8,col = c("red","blue","green","darkmagenta","turquoise4"),bty="n")
axis(side=1, xais, tcl=-0.2, labels=FALSE)
mtext("Position",side=1,line=1)
mtext(xais,side=1,las=1,at=xais,cex=0.8)
axis(side=2,yais,tcl=-0.2,label=F)
mtext(yais,side=2,las=1,at=yais,cex=0.8,line=0.5)
mtext("Percent(%)",side=2,line=1.5)
abline(v=length1,lty=2,col="black")
title(paste("Base Distribution of ",args[6],sep=''))
par(opar)
dev.off()

yais<-seq(0,40,10)
pdf(args[5],w=8,h=6)
plot(data$V1,data$V7,type="l",bty="l",col="red",ylim=c(0,50),xlab="",ylab="",xaxt="n", yaxt="n")
axis(side=1, xais, tcl=-0.2, labels=FALSE)
mtext("Position",side=1,line=1)
mtext(xais,side=1,las=1,at=xais,cex=0.8)
axis(side=2,yais,tcl=-0.2,label=F)
mtext(yais,side=2,las=1,at=yais,cex=0.8,line=0.5)
mtext("Quality",side=2,line=1.5)
abline(v=length1,lty=2,col="black")
title(paste("Mean Quality Distribution of ",args[6],sep=''))
legend(posi,47, c("mean_quality"),lwd=1,cex=0.8,col = c("red"),bty="n")
dev.off()
