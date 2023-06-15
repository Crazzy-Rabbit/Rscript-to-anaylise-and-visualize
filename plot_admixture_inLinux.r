#!/usr/bin/Rscript

# Usage: Rscript 01_plot_admixture.r -i input_prefix -k maxk
# need R packages: optparse, RColorBrewer
# 稍微给改了一下。最终图片应该是挺好看的了
#Admixture结果可视化
 
##=========================================
library("optparse")
# Read in the arguments
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="bam file prefix", metavar="character"),
  make_option(c("-k", "--maxk"), type="integer", default=NULL,
              help="maximum k value", metavar="integer")
)
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# Check that all required arguments are provided
if (is.null(opt$input)){
  print_help(opt_parser)
  stop("Please provide the input prefix", call.=FALSE)
}else if (is.null(opt$maxk)){
  print_help(opt_parser)
  stop("Please provide the maximum k value to plot", call.=FALSE)
}


# sort columns according to the cor
sort.admixture <- function(admix.data){
  k <- length(admix.data)
  n.ind <- nrow(admix.data[[1]])
  name.ind <- rownames(admix.data[[1]])
  admix.sorted <- list()
  
  if (admix.data[[1]][1,1] > admix.data[[1]][1,2]){
    admix.sorted[[1]] <- admix.data[[1]]
  }else{
    admix.sorted[[1]] <- admix.data[[1]][,c(2,1)]
  }
  
  for (i in 1:(k-1)){
    admix <- matrix(nrow = n.ind, ncol = (i + 2))
    cors <- cor(admix.sorted[[i]], admix.data[[i + 1]])
    sorted.loc <- c()
    for (j in 1:nrow(cors)){
      cor <- cors[j,]
      cor[sorted.loc] <- NA
      sorted.loc <- c(sorted.loc, which.max(cor))
    }
    
    sorted.loc <- c(sorted.loc, which(! 1:ncol(cors) %in% sorted.loc))
    cat("n_max = ", sorted.loc, "\n")
    admix <- admix.data[[i + 1]][,sorted.loc]
    rownames(admix) <- name.ind
    admix.sorted[[i + 1]] <- admix
  }
  return(admix.sorted)
}

sort.iid <- function(k.values, groups){
  max.col <- which.max(colSums(k.values))
  k.values <- cbind(k.values, groups[match(rownames(k.values), as.character(groups$iid)),])
  k.values <- transform(k.values, group = as.factor(k.values$fid))
  k.means <- tapply(k.values[,max.col], k.values$group, mean)
  k.means <- k.means[order(k.means)]
  k.sort <- data.frame(id = names(k.means), 
                       order = order(k.means),
                       mean = k.means)
  k.values$order <- k.sort[match(as.character(k.values$group), k.sort$id), 3]
  k.values <- k.values[order(k.values$order, k.values[,max.col]),]
  return(rownames(k.values))
}

sort.fid <- function(iid.order, fid.order, fam.table){
  new.order <- c()
  for (fid in fid.order){
    new.order <- c(new.order, which(iid.order %in% fam.table[fam.table$fid == fid, "iid"]))
  }
  return(iid.order[new.order])
}

read.structure <- function(file, type = "structure"){
  if (type == "structure"){
    k.values <- read.table(file = file, header = F)
    rownames(k.values) <- k.values[,1]
    k.values[,1:3] <- NULL
  }else{
    k.values <- read.table(file = file, header = F)
  }
  return(k.values)
}

add.black.line <- function(data, groups, nline = 1){
  data <- as.matrix(data)
  group.name <- unique(groups)
  new.data <- matrix(NA, ncol = ncol(data))
  black.data <- matrix(NA, nrow = nline, ncol = ncol(data))
  new.name <- c(NA)
  for (name in group.name){
    new.data <- rbind(new.data, black.data)
    new.data <- rbind(new.data, data[which(groups == name),])
    new.name <- c(new.name, rep(NA,nline))
    new.name <- c(new.name, rownames(data)[which(groups == name)])
  }
  
  added.data <- new.data[(nline + 2):nrow(new.data),]
  rownames(added.data) <- new.name[(nline + 2):nrow(new.data)]
  return(added.data)
}


##=========================================
header <- opt$input
max.k <- opt$maxk
##=========================================
admix.fn <- paste(header, 2:max.k, "Q", sep = ".")
fam.fn <- paste(header, "fam", sep = ".")
admix.fam <- read.table(fam.fn, stringsAsFactors = F,
                        col.names = c("fid", "iid", "pid", "mid", "sex", "pheno"))
admix.values <- lapply(admix.fn, read.table, header = F, 
                       row.names = as.character(admix.fam$iid))
order.fn <- paste(header, "order.txt", sep = ".")
admix.order <- read.table(order.fn, stringsAsFactors = F,
                          col.names = c("region", "iid", "fid"))
id.order <- admix.order$iid
admix.data <- list()
for (i in 1:length(admix.values)){
  admix.data[[i]] <- admix.values[[i]][id.order,]
}

species <- as.character(admix.order[,1])
sorted.data <- sort.admixture(admix.data)

## add black line in plot
nline <- 0
plot.data <- list()
group.order <- admix.order[match(id.order, admix.order$iid),3]
for (i in 1:length(sorted.data)){
  plot.data[[i]] <- add.black.line(sorted.data[[i]], group.order, nline = nline)
}

## add xlab to plot
plot.id.list <- rownames(plot.data[[1]])
plot.xlab <- admix.order[match(x = plot.id.list, table = admix.order$iid),]

plot.lab <- unique(plot.xlab$fid)
plot.lab <- plot.lab[!is.na(plot.lab)]
plot.at <- c()
start <- 0
for (fid in plot.lab){
  xlen <- length(which(plot.xlab$fid == fid))
  gap <- start + floor(xlen / 2)
  plot.at <- c(plot.at, gap)
  start <- start + nline + xlen
}

##=========================================
## barplot admixture and structure
library(RColorBrewer)
my.colours <- c("#873186", "#6BB93F","#E20593", "#18A2CA","#FFB6C1","#DBB71D", "#F37020","#3364BC", 
                brewer.pal(8,"Dark2"),"#0b09c3","#f2640a","#08b052","#c00505","#0bc5ee","#7030a2","#ffff01","#c55911")   
#brewer.pal(8, "Dark2")

max.k <- length(plot.data)
n <- dim(plot.data[[1]])[1]

png(file=paste(header, "admix.plot.png", sep = "."),res=400, width = 2000, height = 1200)
par(mfrow = c(max.k, 1), mar=c(0,0.7,0,0),oma=c(3.5,0,0.1,0.1), mgp=c(0,0.2,0),xaxs="i",cex.lab=0.6,  font.lab=2, cex.axis=0.8)
par(las=2)

# define black line locate in where
plot.at1 <- c()
start <- 0
for (fid in plot.lab){
  xlen <- length(which(plot.xlab$fid == fid))
  gap <- start + floor(xlen)
  plot.at1 <- c(plot.at1, gap)
  start <- start + nline + xlen
}
# plot  k
for (i in 1:max.k){
     barplot(t(as.matrix(plot.data[[i]])), names.arg = rep(c(""), n), 
             col = my.colours, border = NA, space = 0,axes = F, 
             ylab = paste("K=",i+1),xaxt="n", yaxt="n")
# plot black line for each pop
    for (i in 0:(length(plot.at1))) {
        x <- plot.at1[i]
        abline(v=0, lwd=1,  col="black")
        abline(v=x, lwd=0.7, col="black") 
  }
        abline(h=0, lwd=0.7, col="black")     
}
axis(side = 1, at = plot.at, labels = plot.lab, tick = F, font=2, cex.axis = 0.6)
dev.off()
