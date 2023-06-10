#! /usr/bin/Rscript
# @Author: Lulu Shi
# @Email: crazzy_rabbit@163.com
# esample usages: Rscript plot_PCA_inLinux.r -f PC1 -s PC2 -F 5% -S 10%
# required R packages: ggplot2 optparse

library("optparse")
option_list = list(
  make_option(c("-e", "--eigenvec"), type="character", default=NULL,
              help="the eigenvec file after PCA analysis", metavar="character"),
  make_option(c("-f", "--firstpc"), type="character", default=NULL,
              help="the firstpc you want to show, such as PC1 or PC2", metavar="character"),
  make_option(c("-s", "--secendpc"), type="character", default=NULL,
              help="the secendpc you want to show, such as PC2 or PC3", metavar="character"),
  make_option(c("-F", "--explan1"), type="character", default=NULL,
              help="the explainm for the firstpc you provide, such as 5.01%",metavar="character"),
  make_option(c("-S", "--explan2"), type="character", default=NULL,
              help="the explainm for the secendpc you provide, such as 10.01%",metavar="character")
)
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
# Check that all required arguments are provided
if (is.null(opt$eigenvec)){
  print_help(opt_parser)
  stop("Please provide the eigenvec file", call.=FALSE)
}else if (is.null(opt$firstpc)){
  print_help(opt_parser)
  stop("Please provide the first pc you want to show", call.=FALSE)
}else if (is.null(opt$secendpc)){
  print_help(opt_parser)
  stop("Please provide the secend pc you want to show", call.=FALSE)
}else if (is.null(opt$explan1)){
  print_help(opt_parser)
  stop("Please provide the first explainm for the firstpc you provide", call.=FALSE)
}else if (is.null(opt$explan2)){
  print_help(opt_parser)
  stop("Please provide the secend explainm for the firstpc you provide", call.=FALSE)
}

library("ggplot2")
a=read.table(opt$eigenvec)
p1=opt$firstpc
p2=opt$secendpc
e1=opt$explan1
e2=opt$explan2
Breed = a[,1]

# only provide pc1-pc2 pc1-pc3 pc2-pc3
if (p1=="PC1"){
  x0=a[,3] 
}
if (p1=="PC2"){
  x0=a[,4]
}

if (p2=="PC2"){
  y0=a[,4]
}
if (p2=="PC3"){
  y0=a[,5]
}

png(file=paste(p1, p2, "PCA.plot.png", sep = "."),res=400, width = 2000, height = 1550)
p = ggplot(data  = a , aes(x = x0, y = y0,group = Breed))+
    geom_point(alpha = 0.2, stroke = 2, aes(color=Breed), size=5) +
    scale_shape_manual(values = rep(21,times = 16)) + 
    guides(color=guide_legend(override.aes = list(size=4, stroke = 2)))

p + labs(x = paste(p1, " (", e1, ")", sep = ""),
         y = paste(p2, " (", e2, ")", sep = "")) + 
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
    theme_classic()+ 
    theme(panel.border = element_rect(fill=NA,color="black", size=0.5, linetype ="solid")) 
dev.off()
