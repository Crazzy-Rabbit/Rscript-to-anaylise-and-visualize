# Rscript-to-anaylise-and-visualize
一些用于画图的R脚本
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FCrazzy-Rabbit%2FRscript-to-anaylise-and-visualize&count_bg=%2379C83D&title_bg=%23555555&icon=microgenetics.svg&icon_color=%23E7E7E7&title=%E8%AE%BF%E9%97%AE%E9%87%8F&edge_flat=false"/></a>
### 别偷偷看啊喂，顺手点个赞
- NEXT
  - R的数据分析、算法等
- [X] [采样地图](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/blob/main/plot_采样地图.R)
    - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/e1299695-09e1-46c3-8436-6a3bf1e64fb1" width="80%">
- [X] [拓扑树](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/blob/main/plot_Phylogenetic_Topolopy.R)
    - [X] ![Rplot](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/f381812d-06c1-469c-9a49-b125d14b8f60)

- [x] [选择信号组合图](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/blob/main/plot_选择信号组合图.R)
    - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/16b24800-e7d9-4c13-be1a-412f31caa22e" width="40%">

- [X] [选择信号频数分布直方图](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/blob/main/plot_selection-Ztest-histplot.R)
    - [X] ![Rplot](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/ab8ffb12-8fdc-445d-89d1-1ce4c3a20b97)

- [X] 曼哈顿图
    - [X] 1.R中CMplot画的
        - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/f2734885-bee2-4de2-b172-cdcce4896896" width="100%">
        - [x] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/df83ac64-9fff-4e4a-8f01-ab8dce9ada3c" width="100%">


    - [X] 2.plot_Manhattan.py画的
        - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/2ca8944a-b9fc-4160-aea4-a49a929338e9" width="100%">
        
- [X] 差异基因表达谱
    - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/d91468e9-a4e4-46da-9642-65638ef72590" width="40%">

- [X] 火山图
    - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/23d2916f-1e1a-46ef-b18a-c403aff7b548" width="40%">

- [X] 富集条形图
    - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/794dae83-71e3-41f2-9cc2-8111fc33e515" width="50%">
    - [x] 个性化一点
        - [X] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/677b02b6-2c20-4870-be23-ab4d2f05f01e" width="100%">
- [x] CMplot_circos
    - [x] <img src="https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/e0363405-2186-4a9f-b1ba-18e90ae5b42d" width="100%">

- [x] 堆叠图-条形
    - [x] ![SNPindel分布](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/3bbe0878-68cc-4466-baf1-f5fedc9e9aec)

- [x] PCA
    - [X] ![PCA1](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/710b2efb-4390-43e1-8b62-8817791ad38e)
- [X] ADMIXTURE
    - [X] ![1 6_CV](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/af3829ba-48ae-4122-b481-ff4e45c419ee)
    - [X] ![1 7_6admixture](https://github.com/Crazzy-Rabbit/Rscript-to-anaylise-and-visualize/assets/111029483/27852037-9b8a-4c4d-b843-1f1edbb7fb4a)

- [x] locuszoom
      ![locuszoom](https://github.com/user-attachments/assets/18766ec6-276a-4cb1-8168-37ae406d48d8)

- [x] GWFM plot (GCTB genome wide fine mapping)
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


  

