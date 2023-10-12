library(ggplot2)
data<-read.table("outgroupf3.f3", header=T, sep="\t")
data$max<-data$f_3+data$std.err
data$min<-data$f_3-data$std.err

m_colour=c("ANG"="#6BB93F","HOL"="#6BB93F","SIM"="#6BB93F",
           "SHO"="#6BB93F","CHR"="#6BB93F","HAW"="#873186",
           "KAZ"="#873186","MON"="#873181","YB"="#873181",
           "MIS"="#18A2CA","KUC"="#18A2CA",
           "WL"="#DBB71D","BRA"="#b35107")
p<-ggplot(data,aes(Source1,f_3, col=Source1))
p+geom_linerange(aes(ymin=min,ymax=max),linewidth=1.2)+
  scale_x_discrete(limits = unique(data$Source1))+
  geom_point(aes(x=Source1,y=f_3),size=2,shape=0,stroke=1.5)+
  coord_flip()+ 
  scale_color_manual(values=m_colour)+
  labs(x="", y="Ourgroup f3 (Other, WAG; Outgroup)")+
  theme_bw() + 
  theme(strip.background =element_rect(fill="grey")) +
  theme(axis.text.y = element_text(face="bold"))+
  theme(axis.text.x = element_text(face="bold"))+
  guides(col=F)

# z score
p1 <- ggplot(data,aes(Source1,Z,col=Source1))
p1 + geom_point(aes(x=Source1,y=Z), size=2,shape=0,stroke=1.5)+
  scale_x_discrete(limits = unique(data$Source1))+
  coord_flip()+ scale_color_manual(values=m_colour)+
  labs(x="", y="Z scores")+
  theme_bw() + 
  theme(strip.background =element_rect(fill="grey")) +
  theme(axis.text.y = element_text(face="bold"))+
  theme(axis.text.x = element_text(face="bold"))+
  guides(col=F)
