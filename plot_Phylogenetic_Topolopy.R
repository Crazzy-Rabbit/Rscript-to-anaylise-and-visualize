library(gridExtra)
library(tidyverse)

# define the fig code
myfun <- function(linecolor, linewid,
                  label.01, label.01.size,
                  label.02, label.02.size,
                  title.text,
                  title.size){
  polygon_regular(n=3) %>%
    as.data.frame() %>%
    head(n=3) -> dat
  dat[3, ] %>%
    bind_cols(dat[1, ] %>%
                rename("V3"="V1",
                       "V4"="V2")) -> dat01
  dat[1, ] %>%
    bind_cols(dat[2, ] %>%
                rename("V3"="V1",
                       "V4"="V2")) -> dat02
  (dat[3, ]/2 + dat[1, ]/2) %>%
    bind_cols((dat[3, ]/2 + dat[2, ]/2) %>%
                rename("V3"="V1",
                       "V4"="V2")) -> dat03
  dat01 %>%
    bind_rows(dat02) %>%
    bind_rows(dat03) %>%
    ggplot() +
    geom_segment(aes(x=V1, xend=V3, y=V2, yend=V4),
                 linewidth=linewid,
                 color=linecolor,
                 lineend="round",
                 linejoin="round") +
    theme_bw() +
    theme(panel.grid = element_blank(),
          axis.title = element_blank(),
          axis.text  = element_blank(),
          axis.ticks = element_blank(),
          panel.border = element_blank()) +
    coord_equal() +
    geom_text(data=dat[2, ] %>%
                bind_rows(dat[3, ]/2 + dat[2, ]/2) %>%
                bind_rows(dat[3, ]) %>%
                mutate(label=label.01),
              aes(x=V1, y=V2, label=label),
              vjust=1.5, size=label.01.size) +
    geom_text(data=data.frame(V1=c(dat[3,1]),
                              V2=1,
                              label=label.02),
              aes(x=V1, y=V2, label=label),
              size=label.02.size, vjust=1, hjust=c(1)) +
    labs(title = title.text)+
    theme(plot.title = element_text(hjust=0.5, size=title.size)) +
    xlim(-1, 1) +
    ylim(-1, 1.2)

}



myfun(linecolor = "#dba134",
      linewid = 3,
      label.01 = c("C","B","A"),
      label.01.size = 8,
      label.02 = c("((A,B),C)"),
      label.02.size = 6,
      title.text = "ABC lineage",
      title.size = 20) -> p1
p1
