## libraries and functs ----------------
library(igraph)
library(dplyr)
source("code/gbb_functs.R")

## params -----------------------
B <- 500
const <- .5

## generate graphs -----------------
data.frame(n = c(10, seq(50, 500, 50))) %>%
  mutate(e = round(const*n^(1.5))) %>%
  group_by(n, e) %>%
  do(graph = erdos.renyi.game(.$n, .$e, "gnm")) -> graphs_er

## block boostrap -------------------
graphs_er %>%
  filter(n < 250) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_er

graphs_er %>%
  filter(n == 250) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_250

graphs_er %>%
  filter(n == 300) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_300

graphs_er %>%
  filter(n == 350) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_350

graphs_er %>%
  filter(n == 400) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_400

graphs_er %>%
  filter(n == 450) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_450

graphs_er %>%
  filter(n == 500) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e(.$graph[[1]], B))) -> T_star_500

T_star_er %>%
  rbind_list(T_star_250, T_star_300, T_star_350, T_star_400, T_star_450, T_star_500) -> T_star_er

save(T_star_er, graphs_er, file = "data/erdos_renyi.RData")

## adjusted block boostrap ---------------
graphs_er %>%
  filter(n < 250) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_er_adj

graphs_er %>%
  filter(n == 250) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_250_adj

graphs_er %>%
  filter(n == 300) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_300_adj

graphs_er %>%
  filter(n == 350) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_350_adj

graphs_er %>%
  filter(n == 400) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_400_adj

graphs_er %>%
  filter(n == 450) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_450_adj

graphs_er %>%
  filter(n == 500) %>%
  group_by(n, e) %>%
  do(data.frame(res = gbb_e_adj(.$graph[[1]], B))) -> T_star_500_adj

T_star_er_adj %>%
  rbind_list(T_star_250_adj, T_star_300_adj, T_star_350_adj, T_star_400_adj, T_star_450_adj, T_star_500_adj) -> T_star_er_adj

save(T_star_er_adj, graphs_er, file = "data/erdos_renyi_adj.RData")





