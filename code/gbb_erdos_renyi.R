## libraries and functs ----------------
library(igraph)
library(dplyr)
source("code/gbb_functs.R")

## run gbb -----------------------
## params
B <- 500
const <- .5

## generate graphs
data.frame(n = seq(10, 1000, length.out = 20)) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs

## block boostrap
graphs %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb(.$graph[[1]], B))) -> T_star_er

save(T_star_er, file = "data/erdos_renyi.RData")

