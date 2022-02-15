library(data.table)

## read synteny dat
dat<-fread("out_synteny_Lmel.psl",header=FALSE)
dfdat<-as.data.frame(dat)
xx<-table(dfdat[,10])
lmCh<-names(xx)[xx>100]
## 24 scaffolds = 22 autosomes + Z with one auto split (we think)
keep<-(dfdat[,10] %in% lmCh) & (dfdat[,14] %in% lmCh)

subDfdat<-dfdat[keep,]

## query = hic, target = pb

tab<-tapply(X=subDfdat[,1],INDEX=list(qg=subDfdat[,10],tg=subDfdat[,14]),sum)
lm1_sc<-as.numeric(unlist(strsplit(x=colnames(tab),split="[_-]",fixed=FALSE))[seq(2,96,4)])
lm2_sc<-as.numeric(unlist(strsplit(x=rownames(tab),split="[_-]",fixed=FALSE))[seq(2,96,4)])

## normalize with respect to knulli
ntab<-tab
for(i in 1:24){
	ntab[i,]<-ntab[i,]/sum(ntab[i,],na.rm=TRUE)
}


pdf("SynLmel.pdf",width=6,height=6)
par(mar=c(5,5,1,1))
image(ntab,axes=FALSE,xlab="L. melissa",ylab="L. melissa",cex.lab=1.4)
axis(2,at=seq(0,24,length.out=24)/24,lm1_sc,las=2)
axis(1,at=seq(0,24,length.out=24)/24,lm2_sc,las=2)
box()
dev.off()


## colinearity plots for all homologous chromsomes
pdf("AlnPlotsLmel.pdf",width=10,height=10)
par(mfrow=c(2,2))
par(mar=c(4.5,5.5,2.5,1.5))
for(i in 1:24){
	lm2<-grep(x=dfdat[,14],pattern=paste("_",lm2_sc[i],"-",sep="")) 
	lm1<-grep(x=dfdat[,10],pattern=paste("_",lm1_sc[i],"-",sep=""))
	cc<-lm1[lm1 %in% lm2]
	subd<-dfdat[cc,]
	yub<-max(subd[,13]);xub<-max(subd[,17])	

	plot(as.numeric(subd[1,16:17]),as.numeric(subd[1,12:13]),type='n',xlim=c(0,xub),ylim=c(0,yub),cex.lab=1.4,ylab="L. melissa (HiC)",xlab="L. melissa (PacBio)")
	title(main=paste("Scaffold",lm1_sc[i]),cex.main=1.4)
	N<-dim(subd)[1]
	for(j in 1:N){
		if(subd[j,9]=="++"){
			lines(subd[j,16:17],subd[j,12:13])
		}
	#	else{
	#		lines(subd[j,16:17],subd[j,12:13],col="cadetblue")
	#		#lines(knulSize[i]-subd[j,16:17],subd[j,12:13],col="cadetblue")
	#		#lines(xub-subd[j,16:17],subd[j,12:13],col="cadetblue")
	#	}
	}
	abline(a=0,b=1,col="gray",lty=2)

}
dev.off()
