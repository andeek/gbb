## libraries and functs ----------------
library(igraph)
library(dplyr)
source("code/gbb_functs.R")

## run gbb -----------------------
## params
B <- 500
const <- .5

## generate graphs
data.frame(n = c(10, 50, 100, 150, 200)) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_er

## block boostrap
graphs_er %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb(.$graph[[1]], B))) -> T_star_er

save(T_star_er, graphs_er, file = "data/erdos_renyi.RData")

## plots -----------------
T_star_er %>%
  mutate(mu = 2*e/n) %>%
  group_by(n) %>%
  summarise(MSE = mean((res - mu)^2)) %>%
  ggplot() +
  geom_point(aes(n, MSE)) +
  geom_line(aes(n, MSE))

T_star_er %>%
  mutate(mu = 2*e/n) %>%
  ggplot() +
  geom_boxplot(aes(factor(n), res)) +
  geom_hline(aes(y_intercept = mu)) +
  facet_wrap(~n, scales = "free_y")
