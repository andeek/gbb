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
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_er

data.frame(n = 250) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_250

graphs_250 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_250

data.frame(n = 300) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_300

graphs_300 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_300

data.frame(n = 350) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_350

graphs_350 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_350

data.frame(n = 400) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_400

graphs_400 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_400

data.frame(n = 450) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_450

graphs_450 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_450

data.frame(n = 500) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_500

graphs_500 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_500

data.frame(n = 750) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_750

graphs_750 %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_750


save(T_star_er, graphs_er, file = "data/erdos_renyi.RData")

## plots -----------------
library(ggplot2)

T_star_er %>%
  ggplot() +
  geom_boxplot(aes(factor(n), res)) +
  geom_hline(aes(yintercept = e)) +
  facet_wrap(~n, scales = "free_x")

T_star_er %>%
  group_by(n) %>%
  mutate(boot_mean = mean(res)) %>%
  summarise(boot_var = mean((res - boot_mean)^2),
            MSE = mean((res - e)^2))
