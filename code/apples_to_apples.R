## libraries and functs ----------------
library(igraph)
library(dplyr)
library(snowboot)
source("code/gbb_functs.R")

## data -----------------
snow_graph <- local.network.MR.new5(500, "poly.log", c(0.1, 2))
graph <- graph_from_edgelist(snow_graph$edges, directed=FALSE)

## params -----------------
B <- 500
L <- 1
m <- c(10, 50)
d <- c(0, 1, 3, 5)


## snowball ------------------
expand.grid(B = B, L = L, m = m, d = d) %>%
  group_by(B, L, m, d) %>%
  do(lsmi = Oempdegreedistrib(snow_graph, .$m, .$d, .$L)) -> emp_dist

emp_dist %>%
  group_by(B, L, m, d) %>%
  do(sbb = bootdeg(sam.out = .$lsmi[[1]], n.boot = .$B)) -> snowballbb 

select_empd <- function(sbb) {
  empd <- sbb$empd[[1]]
  if("empd.seeds" %in% names(empd)) {
    res <- empd$empd.seeds
  } else {
    res <- empd$empd.nw.p0sEkb
  }
  return(res)
}

snowballbb %>%
  group_by(B, L, m, d) %>%
  do(data.frame(T_n = snowboot:::bootmeans_from_bootdegdistrib(select_empd(.$sbb[[1]])))) -> sbb_T

## gbb -----------------------
## !!! This doesn't work, p_hat is incorrect !!!
gbb_T <- gbb(graph, B)

## plots
library(ggplot2)

plot(graph, vertex.size = 3, vertex.color="steelblue", vertex.label=NA, vertex.frame.color="white")

sbb_T %>%
  ggplot() +
  geom_boxplot(aes(factor(d), T_n)) +
  facet_wrap(~m)

ggplot() + geom_boxplot(aes("", gbb_T))

save(sbb_T, gbb_T, graph, file="data/apples_to_apples.RData")
