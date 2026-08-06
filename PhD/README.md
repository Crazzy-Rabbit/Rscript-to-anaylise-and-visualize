- [x] locuszoom
```r
source("plot_Locouszoom.R")
LZData <- ReadLocusZoomData(gwas="gwas_chrpos.gz", ld_info="plink.ld", snp="rs641221")
pdf('locuszoom.pdf',width = 6,height = 4)
plot_locuszoom(data=pltdt, genelist="glist_hg19_refseq.txt")
dev.off()
```
      ![locuszoom](https://github.com/user-attachments/assets/18766ec6-276a-4cb1-8168-37ae406d48d8)

- [x] GWFM plot (GCTB genome wide fine mapping)
```r
source("plot_GWFM.r")
PData <- ReadPvalueFromFiles(gwas="gwas_chrpos.gz", gwfm="gwaf.snpRes", glist="glist_hg19_refseq.txt", windowsize=200000, highlight="rs641221")
pdf('gwfm_plot.pdf',width = 8,height = 8)
MultiPvalueLocusPlot(data=PData)
dev.off()
```
      ![GWFM](https://github.com/user-attachments/assets/70b287bc-c100-4cf8-ae85-cb00310b21ae)

- [x] QQplot multi trait

```
set.seed(20260108)

N <- 50000

# 1) 纯零假设（均匀分布）
p_null <- runif(N)

# 2) “多基因/少量真实信号”：97% null + 3% 偏小p
p_poly <- runif(N)
sig_poly <- rbinom(N, 1, 0.03) == 1
p_poly[sig_poly] <- rbeta(sum(sig_poly), shape1 = 0.4, shape2 = 1)  # shape1<1 会产生更多小p

# 3) “膨胀”：|Z|整体偏大（sd>1），p会更偏小但不一定有真实峰
z_inf <- rnorm(N, mean = 0, sd = 1.2)
p_infl <- 2 * pnorm(-abs(z_inf))

# 4) “强信号”：1% 极强关联（生成极小p），并故意加入几个0
p_strong <- runif(N)
idx_strong <- sample.int(N, size = round(0.01 * N))
p_strong[idx_strong] <- 10^(-runif(length(idx_strong), min = 6, max = 10)) # 1e-6 到 1e-30
# p_strong[sample.int(N, 5)] <- 0  # 故意放几个0，测试防 Inf

pvals_list <- list(
  Null      = p_null,
  Polygenic = p_poly,
  Inflated  = p_infl,
  Strong    = p_strong
)

png("qqplot_multi.png", width=2400, height=2400, res=500, type="cairo")
qqplot_multi(
  pvals_list,
  cols = c("#1b9e77", "#d95f02", "#7570b3", "#e7298a"),
  pch  = c(16, 17, 15, 18),
  cex  = c(0.8, 0.8, 0.8, 0.8),
  ci_scale = seq(0.8, 1.0, length.out = 4),
  ci_alpha=0.6)
dev.off()
```
 ![QQplot](https://github.com/user-attachments/assets/7502f417-294a-4c1b-9ada-f7678b3f3b21)


  

