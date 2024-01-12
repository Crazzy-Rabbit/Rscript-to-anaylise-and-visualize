library(ggplot2)
library(ggthemes)

mymap <- read.table("经纬度.txt", sep = "\t", header =T)
world <- map_data("world")

my_col = c("Bos_indicus"="black","Bos_taurus"="black", "Bos_taurus_Bos_indicus"="black")
my_fill = c("Bos_indicus"="#98F5FF","Bos_taurus"="#FF7F00", "Bos_taurus_Bos_indicus"="black")
my_shape = c("Bos_indicus"=22,"Bos_taurus"=21, "Bos_taurus_Bos_indicus"=19)

p1 <- ggplot(world, aes(long, lat)) +
         geom_map(map=world, aes(map_id=region), fill="#DEDEDE", color=NA) +
         xlim(-105, 135)+ ylim(-50, 60)+
         coord_quickmap() 

p2 <- p1 + geom_point(data=mymap, aes(x = Longitude, y = Latitude, 
                      group=subspe,size=num, color=subspe, shape=subspe, fill=subspe))+
           scale_fill_manual(values = my_fill)+
           scale_color_manual(values = my_col)+
           scale_shape_manual(values = my_shape)+
           theme_map()+
           theme(legend.position=c(0,0),legend.justification=c(0,0),
                 legend.background=element_blank(),legend.title=element_blank())+
          guides(colour = guide_legend(override.aes = list(size = 5)))
p2



library(ggplot2)
library(ggthemes)

mymap <- read.table("经纬度.txt", sep = "\t", header =T)
world <- map_data("world")

my_fill = c("Africa"="#984EA3","India_Paksitan"="#F781BF","South_China"="#E41A1C",
            "Central_South_Europe"="#FFFF33","Northeast_Asia"="#FF7F00",
            "Northwest_China"="#98F5FF","Tibet"="#377EB8","West_Europe"="#4DAF4A",
            "North_Central_China"="#000000","The_Middle_East_Northwest_China"="#000000")
my_shape = c("Bos_taurus"=23,"Bos_indicus"=21,"Bos_taurus_Bos_indicus"=19)


p1 <- ggplot(world, aes(long, lat)) +
  geom_map(map=world, aes(map_id=region), fill="#DEDEDE", color=NA) +
  xlim(-105, 135)+ ylim(-50, 60)+
  coord_quickmap()  

p2 <- p1 + geom_point(data=mymap, color='black',
                      aes(x = Longitude, y = Latitude, 
                                      size=num, shape=subspe, fill=diqu))+
  scale_fill_manual(values = my_fill)+
  scale_shape_manual(values = my_shape)+
  theme_map()+
  theme(legend.position=c(0,-0.1),legend.justification=c(0,0), # 图例位置
        legend.background=element_blank(), # 去除图例背景
        legend.title=element_blank(),  # 去除图例标题
        legend.text = element_text(size=10), # 图例文本大小
        legend.key=element_rect(color=NA, fill=NA))+ # 去除图例形状周围的背景
  
  # 修改图例形状、大小
  guides(fill=guide_legend(override.aes=list(size=5,shape=21)),
         shape = guide_legend(override.aes = list(size=5, sahpe=my_shape)))

p2



