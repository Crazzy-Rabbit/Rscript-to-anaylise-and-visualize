# `ggplot2`之几何形状


```R
library(tidyverse)
```

### 1 图形语法
图形语法 “`grammar of graphics`” (“`ggplot2`” 中的`gg`就来源于此) 使用图层(`layer`)去描述和构建图形，下图是ggplot2图层概念的示意图![image.png](R语言学习-数据可视化-ggplot进阶(1)之各种图的实现_files/image.png)

![image.png](R语言学习-数据可视化-ggplot进阶(1)之各种图的实现_files/image.png)

### 2 图形部件
一张统计图形就是从数据到几何形状(`geometric object`，缩写`geom`)所包含的图形属性(`aesthetic attribute`，缩写`aes`)的一种映射。

1.`data`: 数据框`data.frame` (注意，不支持向量`vector`和列表`list`类型）


2.`aes`: 数据框中的数据变量映射到图形属性。什么叫图形属性？就是图中点的位置、形状，大小，颜色等眼睛能看到的东西。什么叫映射？就是一种对应关系，比如数学中的函数`b = f(a)`就是`a`和`b`之间的一种映射关系, `a`的值决定或者控制了`b`的值，在`ggplot2`语法里，`a`就是我们输入的数据变量，`b`就是图形属性， 这些图形属性包括：
- x（x轴方向的位置）
- y（y轴方向的位置）
- color（点或者线等元素的颜色）
- size（点或者线等元素的大小）
- shape（点或者线等元素的形状）
- alpha（点或者线等元素的透明度）

3.`geoms`: 几何形状，确定我们想画什么样的图，一个`geom_***`确定一种形状。更多几何形状推荐阅读这里

- `geom_bar()`
- `geom_density()`
- `geom_freqpoly()`
- `geom_histogram()`
- `geom_violin()`
- `geom_boxplot()`
- `geom_col()`
- `geom_point()`
- `geom_smooth()`
- `geom_tile()`
- `geom_density2d()`
- `geom_bin2d()`
- `geom_hex()`
- `geom_count()`
- `geom_text()`
- `geom_sf()`

4.`stats`: 统计变换

5.`scales`: 标度

6.`coord`: 坐标系统

7.`facet`: 分面

8.`layer`： 增加图层

9.`theme`: 主题风格

10.`save`: 保存图片

![image.png](R语言学习-数据可视化-ggplot进阶(1)之各种图的实现_files/image.png)

## 开始
R语言数据类型，有字符串型、数值型、因子型、逻辑型、日期型等。 `ggplot2`会将字符串型、因子型、逻辑型默认为离散变量，而数值型默认为连续变量，将日期时间为日期变量：
- 离散变量: 字符串型, 因子型, 逻辑型

- 连续变量: 双精度数值, 整数数值

- 日期变量: 日期, 时间, 日期时间

我们在呈现数据的时候，可能会同时用到多种类型的数据，比如

- 一个离散

- 一个连续

- 两个离散

- 两个连续

- 一个离散, 一个连续

- 三个连续

### 1 导入数据
后续用到的所有数据均可在`https://github.com/Crazzy-Rabbit/R_for_Data_Science/tree/master/demo_data`下载


```R
gapdata <- read_csv("./demo_data/gapminder.csv")
```

    [1mRows: [22m[34m1704[39m [1mColumns: [22m[34m6[39m
    [36m──[39m [1mColumn specification[22m [36m─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[39m
    [1mDelimiter:[22m ","
    [31mchr[39m (2): country, continent
    [32mdbl[39m (4): year, lifeExp, pop, gdpPercap
    
    [36mℹ[39m Use `spec()` to retrieve the full column specification for this data.
    [36mℹ[39m Specify the column types or set `show_col_types = FALSE` to quiet this message.



```R
gapdata %>% head()
```


<table class="dataframe">
<caption>A tibble: 6 × 6</caption>
<thead>
	<tr><th scope=col>country</th><th scope=col>continent</th><th scope=col>year</th><th scope=col>lifeExp</th><th scope=col>pop</th><th scope=col>gdpPercap</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>Afghanistan</td><td>Asia</td><td>1952</td><td>28.801</td><td> 8425333</td><td>779.4453</td></tr>
	<tr><td>Afghanistan</td><td>Asia</td><td>1957</td><td>30.332</td><td> 9240934</td><td>820.8530</td></tr>
	<tr><td>Afghanistan</td><td>Asia</td><td>1962</td><td>31.997</td><td>10267083</td><td>853.1007</td></tr>
	<tr><td>Afghanistan</td><td>Asia</td><td>1967</td><td>34.020</td><td>11537966</td><td>836.1971</td></tr>
	<tr><td>Afghanistan</td><td>Asia</td><td>1972</td><td>36.088</td><td>13079460</td><td>739.9811</td></tr>
	<tr><td>Afghanistan</td><td>Asia</td><td>1977</td><td>38.438</td><td>14880372</td><td>786.1134</td></tr>
</tbody>
</table>



### 2 检查数据

是否有缺失值


```R
gapdata %>% 
  summarise(
    across(everything(), ~sum(is.na(.)))
  )
```


<table class="dataframe">
<caption>A tibble: 1 × 6</caption>
<thead>
	<tr><th scope=col>country</th><th scope=col>continent</th><th scope=col>year</th><th scope=col>lifeExp</th><th scope=col>pop</th><th scope=col>gdpPercap</th></tr>
	<tr><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
</tbody>
</table>



## 基本绘图
### 1 柱状图
常用于一个离散变量

`geom_bar()`自动完成对相应变量的`count`


```R
gapdata %>% 
  ggplot(aes(x = continent)) +
  geom_bar()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_17_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = reorder(continent, continent, length))) +
  geom_bar()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_18_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = reorder(continent, continent, length))) +
  geom_bar() +
  coord_flip()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_19_0.png)
    



```R
# geom_bar vs stat_count
library(patchwork)
p = gapdata %>% 
  ggplot(aes(x = continent)) + 
  stat_count()

p1 = gapdata %>% 
  ggplot(aes(x = continent)) +
  geom_bar()

p / p1
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_20_0.png)
    



```R
gapdata %>% count(continent)
```


<table class="dataframe">
<caption>A spec_tbl_df: 5 × 2</caption>
<thead>
	<tr><th scope=col>continent</th><th scope=col>n</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><td>Africa  </td><td>624</td></tr>
	<tr><td>Americas</td><td>300</td></tr>
	<tr><td>Asia    </td><td>396</td></tr>
	<tr><td>Europe  </td><td>360</td></tr>
	<tr><td>Oceania </td><td> 24</td></tr>
</tbody>
</table>



`geom_bar()` 自动完成了对对应行的`count`这个统计


```R
gapdata %>% 
  distinct(continent, country) %>% 
  ggplot(aes(x = continent)) +
  geom_bar()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_23_0.png)
    


可先进行统计，再画图，不过显然直接用`geom_bar()`代码更少


```R
gapdata %>% 
  distinct(continent, country) %>% 
  group_by(continent) %>% 
  summarise(num = n()) %>% 
  ggplot(aes(x = continent, y = num)) +
  geom_col()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_25_0.png)
    


### 2 直方图
常用于一个连续变量

`geom_histograms()`, 默认使用 `position = "stack"`


```R
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_histogram() # corresponding to stat_bin()
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_27_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_histogram(binwidth = 1)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_28_0.png)
    


`geom_histograms()`, 默认使用 `position = "stack"`




```R
gapdata %>% 
  ggplot(aes(x = lifeExp, fill = continent)) +
  geom_histogram()
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_30_1.png)
    


也可以指定 `position = "identity"`

参数的含义是指直方图的条形应当以其实际计数（频数）堆叠在一起，而不进行任何调整


```R
gapdata %>% 
  ggplot(aes(x = lifeExp, fill = continent)) + 
  geom_histogram(position = "identity")
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_32_1.png)
    


### 3 频次图
`geom_freqpoly()`


```R
gapdata %>% 
  ggplot(aes(x = lifeExp, color = continent)) +
  geom_freqpoly()
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_34_1.png)
    


### 4 密度图
`geom_density()`
- `geom_density()` 中`adjust` 用于调节`bandwidth`, `adjust = 1/2` means use half of the default bandwidth.

`geom_line(stat = "density")`


```R
#' smooth histogram = density plot
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_density()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_36_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_line(stat = "density")
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_37_0.png)
    


`adjust` 用于调节`bandwidth`, `adjust = 1/2`means use half of the default bandwidth.


```R
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_density(adjust = 0.2)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_39_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = lifeExp, color = continent)) +
  geom_density()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_40_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = lifeExp, fill = continent)) +
  geom_density(alpha = 0.2)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_41_0.png)
    



```R
gapdata %>% 
  filter(continent != "Oceania") %>% 
  ggplot(aes(x = lifeExp, fill = continent)) +
  geom_density(alpha = 0.2)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_42_0.png)
    


直方图和密度图画在一起。注意`y = stat(density)`表示`y`是由`x`新生成的变量，这是一种固定写法，类似的还有`stat(count)`, `stat(level)`


```R
gapdata %>% 
  filter(continent != "Oceania") %>% 
  ggplot(aes(x = lifeExp, y = stat(density))) +
  geom_histogram(aes(fill = continent)) +
  geom_density()
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_44_1.png)
    


### 5 箱线图
一个离散变量 + 一个连续变量


```R
gapdata %>% 
  ggplot(aes(x = year, y = lifeExp)) +
  geom_boxplot()
```

    Warning message:
    “[1m[22mContinuous [32mx[39m aesthetic
    [36mℹ[39m did you forget `aes(group = ...)`?”



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_46_1.png)
    


数据框中的`year`变量是数值型，需要先转换成因子型，弄成离散型变量


```R
gapdata %>% 
  ggplot(aes(x = as.factor(year), y = lifeExp)) +
  geom_boxplot()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_48_0.png)
    


当然，也可以用`group`明确指定分组变量


```R
gapdata %>% 
  ggplot(aes(x = year, y = lifeExp)) +
  geom_boxplot(aes(group = year))
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_50_0.png)
    


小提琴图+散点+光滑曲线


```R
gapdata %>% 
  ggplot(aes(x = year, y = lifeExp))+
  geom_violin(aes(group = year))+
  geom_jitter(alpha = 0.25)+
  geom_smooth(se = TRUE)
```

    [1m[22m`geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_52_1.png)
    


### 6 抖动散点图
点重叠的处理方案

`geom_jitter()`


```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp)) +
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_54_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp))+
  geom_jitter()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_55_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp)) +
  geom_boxplot()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_56_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp))+
  geom_boxplot()+
  geom_jitter(alpha = 0.25)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_57_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp))+
  geom_jitter()+
  stat_summary(fun.y = median, colour = "red", geom = "point", size = 5)
```

    Warning message:
    “[1m[22mThe `fun.y` argument of `stat_summary()` is deprecated as of ggplot2 3.3.0.
    [36mℹ[39m Please use the `fun` argument instead.”



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_58_1.png)
    



```R
gapdata %>%
  ggplot(aes(reorder(x = continent, lifeExp), y = lifeExp)) +
  geom_jitter() +
  stat_summary(fun.y = median, colour = "red", geom = "point", size = 5)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_59_0.png)
    


注意到我们已经提到过 `stat_count` / `stat_bin` / `stat_summary`


```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp))+
  geom_violin(trim = FALSE, alpha = 0.5) +
  stat_summary(fun.y = mean,
    fun.ymax = function(x){mean(x) + sd(x)},
    fun.ymin = function(x){mean(x) - sd(x)},
    geom = "pointrange")
```

    Warning message:
    “[1m[22mThe `fun.ymin` argument of `stat_summary()` is deprecated as of ggplot2 3.3.0.
    [36mℹ[39m Please use the `fun.min` argument instead.”
    Warning message:
    “[1m[22mThe `fun.ymax` argument of `stat_summary()` is deprecated as of ggplot2 3.3.0.
    [36mℹ[39m Please use the `fun.max` argument instead.”



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_61_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = continent, y = lifeExp))+
  geom_violin(trim = FALSE, alpha = 0.5) +
  stat_summary(fun.y = mean,
    fun.ymax = ~mean(.x) + sd(.x),
    fun.ymin = ~mean(.x) - sd(.x),
    geom = "pointrange")
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_62_0.png)
    


### 7 山峦图
常用于一个离散变量 + 一个连续变量

`ggridges::geom_density_ridges()`


```R
gapdata %>% 
  ggplot(aes(x = lifeExp, y = continent, 
             fill = continent))+
  ggridges::geom_density_ridges()
```

    Picking joint bandwidth of 2.23
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_64_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = lifeExp, y = continent,
            fill = continent))+
  ggridges::geom_density_ridges()+
  scale_fill_manual(
    values = c("#003f5c", "#58508d", "#bc5090", "#ff6361", "#ffa600"))
```

    Picking joint bandwidth of 2.23
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_65_1.png)
    



```R
# colorspace 调色板
gapdata %>% 
  ggplot(aes(x = lifeExp, y = continent, 
             fill = continent))+
  ggridges::geom_density_ridges()+
  scale_fill_manual(
    values = colorspace::sequential_hcl(5, palette = "Peach"))
```

    Picking joint bandwidth of 2.23
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_66_1.png)
    


### 散点图
常用于两个连续变量

`geom_point()`


```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_68_0.png)
    


更好的 `log` 转化方式
- `scale_x_log10()`
- `scale_y_log10()`


```R
# 一般
gapdata %>% 
  ggplot(aes(x = log(gdpPercap), y = lifeExp))+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_70_0.png)
    



```R
# 更好方式
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
  geom_point()+
  scale_x_log10()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_71_0.png)
    



```R
着色方式
```


    Error in eval(expr, envir, enclos): 找不到对象'着色方式'
    Traceback:




```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point(aes(color = continent))

gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp, 
             color = continent))+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_73_0.png)
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_73_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point(alpha = (1/3), size = 2)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_74_0.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point(alpha = 0.3)+
  geom_smooth()
```

    [1m[22m`geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_75_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point()+
  geom_smooth(lwd = 3, se = FALSE)
```

    [1m[22m`geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_76_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point()+
  geom_smooth(lwd = 3, se = FALSE, method = "lm")
```

    [1m[22m`geom_smooth()` using formula = 'y ~ x'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_77_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp, 
             color = continent))+
  geom_point()+
  geom_smooth(lwd = 3, se = FALSE, method = "lm")
```

    [1m[22m`geom_smooth()` using formula = 'y ~ x'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_78_1.png)
    



```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp, 
             color = continent))+
  geom_point(alpha = 0.3)+
  geom_smooth(lwd = 1, color = "blue", se = TRUE, method = "lm")
```

    [1m[22m`geom_smooth()` using formula = 'y ~ x'



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_79_1.png)
    



```R
jCountries <- c("Canada", "Rwanda", "Cambodia", "Mexico")

gapdata %>% 
  filter(country %in% jCountries) %>% 
  ggplot(aes(x = year, y = lifeExp, color = country))+
  geom_line()+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_80_0.png)
    


可以看到，图例的顺序和图中的顺序不太一致，

在设置color的时候可以对continent进行reorder


```R
gapdata %>% 
  filter(country %in% jCountries) %>% 
  ggplot(aes(x = year, y = lifeExp, 
             color = reorder(country, -1 * lifeExp, max)
            ))+
  geom_line()+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_82_0.png)
    


当然还有如下方式

利用`if_else`函数增加一列，并直接用`geom_label(aes(label = end_label))`讲其加入图中`max`那个点


```R
gapdata %>% 
  filter(country %in% jCountries) %>% 
  group_by(country) %>% 
  mutate(end_label = if_else(year == max(year), country, NA_character_)) %>% 
  ggplot(aes(x = year, y = lifeExp, 
            color = country))+
  geom_line()+
  geom_point()+
  geom_label(aes(label = end_label))+
  theme(legend.position = "none")
```

    Warning message:
    “[1m[22mRemoved 44 rows containing missing values or values outside the scale range (`geom_label()`).”



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_84_1.png)
    


如果觉得麻烦，可以用`gghighlight`宏包


```R
# install.packages("gghighlight")
library(gghighlight)
gapdata %>% 
  filter(country %in% jCountries) %>% 
  ggplot(aes(x = year, y = lifeExp,
             color = country))+
  geom_line()+
  geom_point()+
  gghighlight::gghighlight()
```

    label_key: country
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_86_1.png)
    


### 9 点线图
`geom_point() + geom_segment()`


```R
# 点图
gapdata %>% 
  filter(continent == "Asia" & year == 2007) %>% 
  ggplot(aes(x = lifeExp, y = country))+
  geom_point()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_88_0.png)
    



```R
# 点线图
gapdata %>% 
  filter(continent == "Asia" & year == 2007) %>% 
  ggplot(aes(x = lifeExp, y = reorder(country, lifeExp),
             ))+
  geom_point(color = "blue", size = 2)+
  geom_segment(aes(x = 40, xend = lifeExp, 
                   y=reorder(country,lifeExp),yend=reorder(country,lifeExp)),
                   color = "lightgrey")+
  labs(x = "Life Expectancy (years)", y = "",
      title = "Life Expectancy by Country",
      subtitle = "GapMinder data for Asia - 2007")+
  theme_minimal()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_89_0.png)
    


### 10 分面
- 分面有两个 - `facet_grid()` - `facet_wrap()`
#### 1 `facet_grid()`
- create a grid of graphs, by rows and columns
- use `vars()` to call on the variables
- adjust scales with `scales = "free"`


```R
gapdata %>% 
  ggplot(aes(x = lifeExp)) +
  geom_density()+
  facet_grid(. ~ continent)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_91_0.png)
    



```R
gapdata %>% 
  filter(continent != "Oceania") %>% 
  ggplot(aes(x = lifeExp, fill = continent))+
  geom_histogram()+
  facet_grid(continent ~ .)
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_92_1.png)
    



```R
gapdata %>%   
  filter(continent != "Oceania") %>% 
  ggplot(aes(x = lifeExp, y = stat(density)))+
  geom_histogram(aes(fill = continent))+
  geom_density()+
  facet_grid(continent~ .)
```

    [1m[22m`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_93_1.png)
    


#### 2 `facet_wrap()`
- create small multiples by “wrapping” a series of plots
- use `vars()` to call on the variables
- nrow and ncol arguments for dictating shape of grid


```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp, color = continent))+
  geom_point(show.legend = FALSE)+
  facet_wrap(~continent)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_95_0.png)
    


### 11 文本标注
`ggforce::geom_mark_ellipse()`

`ggrepel::geom_text_repel()`


```R
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_point()+
  ggforce::geom_mark_ellipse(aes(
    filter = gdpPercap > 70000,
    label = "Rich country",
    description = "What country are they?"
  ))
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_97_0.png)
    



```R
ten_countries <- gapdata %>% 
  distinct(country) %>% 
  pull() %>%
  sample(10)
ten_countries
```


<style>
.list-inline {list-style: none; margin:0; padding: 0}
.list-inline>li {display: inline-block}
.list-inline>li:not(:last-child)::after {content: "\00b7"; padding: 0 .5ex}
</style>
<ol class=list-inline><li>'Zimbabwe'</li><li>'Kenya'</li><li>'Uganda'</li><li>'Yemen, Rep.'</li><li>'United States'</li><li>'Gambia'</li><li>'Myanmar'</li><li>'Canada'</li><li>'Cote d\'Ivoire'</li><li>'Honduras'</li></ol>




```R
library(ggrepel)
gapdata %>% 
  filter(year == 2007) %>% 
  mutate(
    label = ifelse(country %in% ten_countries, as.character(country), "")
  ) %>% 
  ggplot(aes(log(gdpPercap), lifeExp))+
  geom_point(size = 3.5, alpha = 0.9, shape = 21, 
            col = "white", fill = "#0162B2")+
  geom_text_repel(aes(label = label), size = 4.5,
                 point.padding = 0.2, box.padding = 0.3,
                 force = 1, min.segment.length = 0)+
  theme_minimal(14)+
  theme(legend.position = "none",
       panel.grid.minor = element_blank())+
  labs(x = "log(GDP per capita)",
       y = "life expectancy")
```

    Warning message:
    “ggrepel: 1 unlabeled data points (too many overlaps). Consider increasing max.overlaps”



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_99_1.png)
    


### 12 errorbar图
`geom_errorbar()`


```R
avg_gapdata <- gapdata %>% 
  group_by(continent) %>% 
  summarise(mean = mean(lifeExp), sd = sd(lifeExp)
           )
avg_gapdata
```


<table class="dataframe">
<caption>A tibble: 5 × 3</caption>
<thead>
	<tr><th scope=col>continent</th><th scope=col>mean</th><th scope=col>sd</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>Africa  </td><td>48.86533</td><td> 9.150210</td></tr>
	<tr><td>Americas</td><td>64.65874</td><td> 9.345088</td></tr>
	<tr><td>Asia    </td><td>60.06490</td><td>11.864532</td></tr>
	<tr><td>Europe  </td><td>71.90369</td><td> 5.433178</td></tr>
	<tr><td>Oceania </td><td>74.32621</td><td> 3.795611</td></tr>
</tbody>
</table>




```R
avg_gapdata %>% 
  ggplot(aes(continent, mean, fill = continent))+
  geom_point()+
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd),
               width = 0.25)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_102_0.png)
    


### 13 椭圆图
`stat_ellipse(type = "norm", level = 0.95)`,也就是添加置信区间


```R
gapdata %>% 
  ggplot(aes(x = log(gdpPercap), y = lifeExp))+
  geom_point()+
  stat_ellipse(type = "norm", level = 0.95)
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_104_0.png)
    


### 14 2D 密度图
与一维的情形`geom_density()`类似， `geom_density_2d()`, `geom_bin2d()`, `geom_hex()`常用于刻画两个变量构成的二维区间的密度


```R
#geom_bin2d()
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_bin2d()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_106_0.png)
    



```R
# geom_density2d()
gapdata %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp))+
  geom_density2d()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_107_0.png)
    


### 15 马赛克图
`geom_tile()`， `geom_contour()`， `geom_raster()`常用于3个变量


```R
gapdata %>% 
  group_by(continent, year) %>% 
  summarise(mean_lifeExp = mean(lifeExp)) %>% 
  ggplot(aes(x = year, y = continent, fill = mean_lifeExp))+
  geom_tile()+
  scale_fill_viridis_c()
```

    [1m[22m`summarise()` has grouped output by 'continent'. You can override using the `.groups` argument.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_109_1.png)
    


事实上可以有更好的呈现方式


```R
gapdata %>% 
  group_by(continent, year) %>% 
  summarise(mean_lifeExp = mean(lifeExp)) %>% 
  ggplot(aes(x = year, y = continent, 
             size = mean_lifeExp, color = mean_lifeExp))+
  geom_point()+
  scale_color_viridis_c()+
  theme_minimal(15)
```

    [1m[22m`summarise()` has grouped output by 'continent'. You can override using the `.groups` argument.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_111_1.png)
    


把数值放入点中

`geom_text()`


```R
gapdata %>% 
  group_by(continent, year) %>% 
  summarise(mean_lifeExp = mean(lifeExp)) %>% 
  ggplot(aes(x = year, y = continent, size = mean_lifeExp))+
  geom_point(shape = 21, color = "red", fill = "white")+
  scale_size_continuous(range = c(7, 15))+
  geom_text(aes(label = round(mean_lifeExp, 2)), size = 3, color = "black")+
  theme_minimal()+
  theme(legend.position = "none")
```

    [1m[22m`summarise()` has grouped output by 'continent'. You can override using the `.groups` argument.



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_113_1.png)
    



```R
library(tidyverse)
tbl <-
  tibble(
    x = rep(c(1, 2, 3), times = 2),
    y = 1:6,
    group = rep(c("group1", "group2"), each = 3)
  )
ggplot(tbl, aes(x, y)) + geom_line()
ggplot(tbl, aes(x, y, group = group)) + geom_line()
ggplot(tbl, aes(x, y, fill = group)) + geom_line()
ggplot(tbl, aes(x, y, color = group)) + geom_line()
```


    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_114_0.png)
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_114_1.png)
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_114_2.png)
    



    
![png](R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_files/R%E8%AF%AD%E8%A8%80%E5%AD%A6%E4%B9%A0-%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96-ggplot%E8%BF%9B%E9%98%B6%281%29%E4%B9%8B%E5%90%84%E7%A7%8D%E5%9B%BE%E7%9A%84%E5%AE%9E%E7%8E%B0_114_3.png)
    

