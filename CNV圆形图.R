library("circlize")

rm(list = ls())
options(stringsAsFactors = F)

data = read.table("DEL.txt", 
                  sep='\t', header=T)# 可以读多个文件，画多层 chr start end的形式
data2 = read.table("DUP.txt", 
                  sep='\t', header=T)

data3 = read.table("Both.txt", 
                 sep='\t', header=T)

# 初始化自己的染色体
chr = read.table("chr.txt", sep='\t', header=T) # chr start end 形式， 一般start为0 ，end 为染色体全长
xchr = data.frame(start=chr$start, end=chr$end/10^6)
circos.par(cell.padding = c(0.02, 0, 0.02, 0))
circos.initialize(sectors=chr$chr, 
                  xlim = xchr)

circos.track(ylim=c(0,3),
             panel.fun = function(x, y) {
               Genome=CELL_META$sector.index
               xlim=CELL_META$xcenter
               ylim=CELL_META$cell.ylim
               circos.text(mean(xlim),mean(ylim),Genome,
                            cex = 0.6,font=2)
              # circos.axis(labels.cex = 0.5)
               },bg.border=T,
                 bg.col=rep(c("#85BA8F", "#A3C8DC","#F09594"),length.out=30), 
                 track.height=0.05)

#设置x轴axis
#track.index = get.current.track.index() 可以让轴外放
brk <- seq(0,200,40)  # 得和circos.initialize中设置的x的数量级是一致的，否则出不来X轴刻度
circos.track(track.index = get.current.track.index(),
             panel.fun = function(x, y) {
                         circos.axis(h="top",major.at=brk,labels=round(brk,1),labels.cex=0.5,
                        labels.pos.adjust =0,
                        col='#045eaf',labels.col='black',lwd=0.7,labels.facing="clockwise")
                         },bg.border=T)


#############下面每个都是一层，而且可以是读入的不同数据
bgcol <- rep("#F9766E", 30)  # 249,118,110
circos.trackHist(data$chr, data$start/10^6, bin.size = 0.2, bg.col = bgcol, col = NA)

bgcol <- rep("#00BFC4", 30) # 0,191,196
circos.trackHist(data2$chr, data2$start/10^6, bin.size = 0.2, bg.col = bgcol, col = NA)

bgcol <- rep("#00BFFF", 30) # 0,191,255
circos.trackHist(data3$chr, data3$start/10^6, bin.size = 0.2, bg.col = bgcol, col = NA)








