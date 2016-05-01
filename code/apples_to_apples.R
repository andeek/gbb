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

## gbb -----------------------
gbb_T <- gbb(graph, B)

## plots
plot(graph, vertex.size = 3, vertex.color="steelblue", vertex.label=NA, vertex.frame.color="white")

save(graph, file="written/apples_to_apples.RData")
