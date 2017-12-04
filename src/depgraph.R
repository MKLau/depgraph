## The object main.spine is the complete set of 
## dependent functions for prov.capture 

### Load the library
libs <- c("mvbutils", "igraph", "Rgraphviz")
for (l in (libs[!(libs %in% installed.packages()[,1])])){
    install.packages(l)
}
sapply(libs,require, character.only = TRUE)

### Set the correct working directory
if (grepl("/src",getwd())){setwd("..")}
### Get the package, you can delete data/provR to 
### get the most up to date version
if (!file.exists("data/provR")){
    system("git clone git@github.com:ProvTools/provR.git")
    system("mv provR data/")
}

### Initialize
rm(list = ls())
pkg.R <- dir("data/provR/R/", full.names = TRUE)
sapply(pkg.R,source)

### Getting the dependency information
fw <- foodweb(plotting = F)
ig <- graph_from_adjacency_matrix(fw$funmat)

## These are the functions that prov.capture depends on
main.spine <- names(na.omit(bfs(ig,root ="prov.capture", 
                           neimode = c('out'),
                           unreachable = FALSE)$order))
json.spine <- names(na.omit(bfs(ig,root ="prov.json", 
                           neimode = c('out'),
                           unreachable = FALSE)$order))

## Trace the path from prov.capture to its root
core <- c(main.spine,json.spine)[!duplicated(c(main.spine,json.spine))]
all(sort(core) == sort(names(V(ig))[names(V(ig)) %in% core]))
isg.main.spine <- induced_subgraph(ig,match(core,names(V(ig))))

## plots
pdf("results/dep_graph.pdf", width = 20, height = 20)
plot(isg.main.spine, vertex.size = 0.1, font = 2)
dev.off()

pdf("results/dep_isg_graphnel.pdf",width = 20, height = 20)
isgm.gnl <- igraph.to.graphNEL(isg.main.spine)
natt <- list(label = names(V(isg.main.spine)))
names(natt$label) <- nodes(isgm.gnl)
plot(isgm.gnl, nodeAttrs = natt, attrs = list(node=list(shape="ellipse", fixedsize=FALSE)))
dev.off()

pdf("results/dep_graphnel.pdf",width = 30, height = 30)
ig.gnl <- igraph.to.graphNEL(ig)
natt <- list(label = names(V(ig)))
names(natt$label) <- nodes(ig.gnl)
plot(ig.gnl, nodeAttrs = natt, attrs = list(node=list(shape="ellipse", fixedsize=FALSE)))
dev.off()

