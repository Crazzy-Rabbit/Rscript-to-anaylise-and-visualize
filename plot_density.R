# method 1 ggplot
library(ggplot2)
data <- read.table("all.fst", sep="\t", header=T)
data$Group <- factor(data$Group, levels=c("Simulated","Observed "))  

ggplot(data,aes(x=FST, group=Group,fill=Group))+
  geom_density( alpha=0.6,)+
  labs(x=expression(paste(italic('F'),st)), y="Density")+
  guides(fill = guide_legend(ncol = 1, byrow = F,title = "")) +
  scale_y_continuous(expand = c(0,0))+
  theme_bw() +
  theme(legend.position = "top")


# method 2 plot
data <- read.table("all.fst", sep="\t", header=T)
plot(density(data$FST[data$Group=="Simulated"]), col ="blue",
     xlim=c(0,1),ylim=c(0,8), main="",xlab=expression(paste(italic('F')[ST])))
lines(density(data$FST[data$Group=="Observed "]), col="red")
abline(h=0, col="gray")
