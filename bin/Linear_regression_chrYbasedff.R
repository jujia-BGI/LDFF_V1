args <- commandArgs(trailing=T)
        aa<- args[1]
	bb<- args[2]

d<-read.table(file = aa,header =TRUE)
options(max.print=100000000) 


l=lm(chrY_based_ff~ . ,data=d)
summary(l)

save(l,file="Linear-model.RData")
test<-read.table(file = bb,header =TRUE)

pred=predict(l,newdata=test,type='response')
name=paste0(bb,".pred")
write.table(file=name,pred,sep="\t")
R=cor.test(pred,test$chrY_based_ff)
R

library(ggplot2)
library(ggpubr)
library(gridExtra)
library(grid)


a=data.frame(pred=pred,chrY=test$chrY_based_ff)
name=paste0(bb,".correlation.histogram.log.pdf")
pdf(name,w=5,h=2.5)

g1=ggplot(data=a,aes(x=a$chrY,y=a$pred))+xlab('ChrY_based_FF')+ylab('LDFF')+geom_point(size=0.8,alpha=0.6)+ylim(c(0,0.45))+xlim(c(0,0.45))+geom_abline(intercept=0,slope=1,linetype="dashed" )+theme_bw()+annotate("text",x=0.05,y=0.45,label=paste0("R=",round(R$estimate,3)),size=3)
g1=g1+ theme(panel.grid.major =element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank(),axis.text.x = element_text(size=6),axis.text.y = element_text(size=6),axis.title.x = element_text(size=8),axis.title.y = element_text(size=8))+labs(tag="A")


b=data.frame(value=a$pred-a$chrY,chrY=a$chrY)
c=round(summary(abs(b$value)),3)
c


g2=ggplot(data=b,aes(x=value,y=..density..))+geom_histogram(stat="bin",binwidth=0.005,colour="black", fill="white")+xlim(c(-0.1,0.1))+annotate("text",x=-0.065,y=50,label=paste0("MAE=",c[4]),size=3)
g2=g2+theme_bw()+ylab("Density")+xlab("LDFF-ChrY_based_FF")+theme(panel.grid =element_blank(),panel.background = element_blank(),axis.text.x = element_text(size=6),axis.text.y = element_text(size=6),axis.title.x = element_text(size=8),axis.title.y = element_text(size=8))+labs(tag="B")


vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
grid.newpage()
        pushViewport(viewport(layout = grid.layout(1,2)))
             print(g1, vp = vplayout(1,1:1))
             print(g2, vp = vplayout(1,2:2))
dev.off()

summary(abs(b$value))
