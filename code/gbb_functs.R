## bootstrap functions ------------------------

##
## bootstrap sample a graph according the "simple scheme"
##
sample_graph <- function(graph) {
  require(igraph)
  
  ## constants
  n <- length(V(graph))
  D <- degree(graph)
  m <- mean(D + 1)
  k <- floor(n/m)
  p <- 2*(m - 2)*length(E(graph))/(m*(n - m)*n)
  index <- sample(1:n, k)
  count <- 1

  ## individual block subgraphs
  blocks <- lapply(index, function(i) {
    ## get subgraph
    subgraph <- induced_subgraph(graph, V(graph)[c(i, neighbors(graph, i))])
    
    ## set vertex names for unioning later
    b <- length(V(subgraph))
    vertex_attr(subgraph, "name") <- count:(count + b - 1)
    count <<- count + b
    
    ## remove graph attributes for unioning
    for(attr in graph_attr_names(subgraph)) {
      subgraph <- delete_graph_attr(subgraph, attr)
    }
    
    return(subgraph)
  })
  
  ## combine all subgraphs
  g_star <- do.call(graph_add, blocks)
  
  ## add appropriate between block edges according to Bern(p)
  match_blocks <- expand.grid(x = 1:k, y = 1:k)
  match_blocks <- match_blocks[match_blocks$x < match_blocks$y, ]
  
  edges_add <- apply(match_blocks, 1, function(match){
    match_nodes <- expand.grid(V(blocks[[match["x"]]])$name, V(blocks[[match["y"]]])$name)
    as.character(t(match_nodes[rbinom(nrow(match_nodes), 1, p) == 1, ]))
  })
  
  if(class(edges_add) == "list") {
    edges_vec <- do.call(c, edges_add)
  } else {
    edges_vec <- c(edges_add)
  }
  
  g_star <- g_star + edges(edges_vec)
  return(g_star)
  
}

graph_add <- function(...) {
  graphs <- list(...)
  nodes <- lapply(graphs, function(g){ as.character(V(g)$name) })
  links <- lapply(graphs, function(g){ as.character(t(ends(g, E(g)))) })
  
  graph.empty(directed = FALSE) + unlist(nodes) + edges(unlist(links))
}

gbb_e <- function(graph, B) {
  require(igraph)
  T_star <- rep(NA, B)
  
  #for 1, ..., B get T*
  for(i in seq_len(B)) {
    graph_star <- sample_graph(graph)
    T_star[i] <- length(E(graph_star))
  }
  return(T_star)
}

gbb_mu <- function(graph, B) {
  require(igraph)
  T_star <- rep(NA, B)
  
  #for 1, ..., B get T*
  for(i in seq_len(B)) {
    graph_star <- sample_graph(graph)
    T_star[i] <- sum(degree(graph_star))/length(V(graph_star))
  }
  return(T_star)
}






