library(ggplot2);
library(RColorBrewer);
library(reshape2);
library(grid);
args<-commandArgs(TRUE)
if (length(args) < 9) {
	print ("Rscript barplot.r <Infile> <Outdir> <The rows which you want to draw> <The y-lab> <The filename> <The barplot type> <The type of barplot(number or percentage(p))> <The title of picture> <The input colors>");
	print ("/annoroad/share/software/install/R-3.1.1/bin/Rscript /annoroad/data1/bioinfo/PROJECT/RD/Cooperation/DNA/Exome/ngs_bioinfo/dna-446/wangjing/Analysis/script/barplot.r /annoroad/data1/bioinfo/PROJECT/RD/Cooperation/DNA/Exome/ngs_bioinfo/dna-361/wangjing/Analysis/test/result/Stat/All.snp.genome.xls ./  1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 'percentages(%)' All.snp.genome stack p '' '' ");
	q();
	}
file<-read.table(args[1],header=F,sep="\t");
row<-strsplit(args[3],split=",")
screen_row<-file[row[[1]],];
screen_row<-t(screen_row);
screen_row<-data.frame(screen_row);
if(args[6] == "dodge"){
        time<-dim(screen_row)[2]-1;
}else{
        time<-1;
}
if(dim(screen_row)[1]<10){
figwidth<-9;
}else{
figwidth<-9+0.22*time*(dim(screen_row)[1]-10);
}
names<-as.matrix(screen_row[1,]);
screen_row<-screen_row[-1,];
colnames(screen_row)<-c("Samples",names[2:length(names)]);
mydata<- melt(screen_row,id.vars="Samples",variable.name="Entries",value.name = "Percentages");
mydata$Percentages<-gsub(",","",mydata$Percentages);
mydata$Percentages<-as.numeric(mydata$Percentages);
if(args[7]=="p"){
width<-ifelse(dim(screen_row)[1]>1,0.6,0.4);
angle<-ifelse(dim(screen_row)[1]>1,45,0);
breaks<-seq(0,100,20);
m<-ggplot(mydata,aes(x=Samples,y=Percentages,fill=Entries))+geom_bar(stat="identity",position=args[6],width=width)+labs(x = "",y = args[4],fill = "",size=2,title=args[8])
m<-m+scale_y_continuous(breaks=breaks)+theme(axis.text.x = element_text(colour = "gray40",size=15,face="bold",angle=angle,hjust=1),axis.text.y = element_text(colour = "gray30",size=15,face="bold",angle=0),axis.title.y=element_text(size=15,face="bold"),legend.key.width=unit(1,'cm'),legend.key.height=unit(1,'cm'),legend.text = element_text(size = 15));
}else{
width<-ifelse(dim(screen_row)[1]>1,0.6,0.4)
angle<-ifelse(dim(screen_row)[1]>1,45,0);
m<-ggplot(mydata,aes(x=Samples,y=Percentages,fill=Entries))+geom_bar(stat="identity",position=args[6],width=width)+labs(x = "",y = args[4],fill = "",size=2,title=args[8])
m<-m+theme(axis.text.x = element_text(colour = "gray40",size=15,face="bold",angle=angle,hjust=1),axis.text.y = element_text(colour = "gray30",size=15,face="bold",angle=0),axis.title.y=element_text(size=15,face="bold"),legend.key.width=unit(1,'cm'),legend.key.height=unit(1,'cm'),legend.text = element_text(size = 15));
}
if(args[9] == " " || args[9] == ""){ 
set.seed(1222);
color_default<-c("#96cdcd","#CD5C5C","#00688B","#228B22","#B3EE3A","#7B68EE","#FF7F24","#00F5FF","#00FF00","#8B658B","#00008B","#2F4F4F","#ff0040","#8A2BE2","#53868B","#90EE90","#00F5FF","#EEAD0E","#8B814C","#EEB4B4","#EE0000","#8B4726","#FFFF00",colorRampPalette(c(brewer.pal(9,"Set1"),brewer.pal(9,"Set3")),bias=1.5)(100));
#print (color_default);
}else{
color_default<-read.table(args[9],header=F,sep="\t");
color_default<-color_default[,1];
}
	if(dim(screen_row)[1]==1){
		mylabels<-gsub("\\(%\\)","",mydata$Entries);
		print (mylabels)
		myLabels <- paste(mylabels,"(",mydata$Percentages, ")", sep = "");
#m<-m+scale_fill_manual(values=c("#d7193c","#3cd719","#19d7b4","#b419d7"),labels=mylabels);
		if(dim(screen_row)[2]<4){
			values<-color_default[1:(dim(screen_row)[2]-1)];
			m<-m+scale_fill_manual(values=values,labels=myLabels);
		}else{
			m<-m+scale_fill_manual(values=color_default[1:(dim(screen_row)[2]-1)],labels=myLabels);
		}
		#ggsave(m,file=paste(args[2],"/",args[5],".png",sep=""),width =7,height = 9,dpi=200);
		ggsave(m,file=paste(args[2],"/",args[5],".pdf",sep=""),width =7,height = 9,dpi=200);
	}
	if(dim(screen_row)[1]>1){
		if(dim(screen_row)[2]<4){
			m<-m;
			values<-color_default[1:(dim(screen_row)[2]-1)]
			m<-m+scale_fill_manual(values=values);
		}else{
			values<-color_default[1:(dim(screen_row)[2]-1)]
			m<-m+scale_fill_manual(values=values);
		}
		#ggsave(m,file=paste(args[2],"/",args[5],".png",sep=""),width =figwidth,height = 9,dpi=200);
		ggsave(m,file=paste(args[2],"/",args[5],".pdf",sep=""),width =figwidth,height = 9,dpi=200);
	}


