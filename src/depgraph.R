## The object main.spine is the complete set of 
## dependent functions for prov.capture 

args <- commandArgs(TRUE)
options(pkg = args[1])

### Load the library
libs <- c("mvbutils", "igraph", "Rgraphviz")
for (l in (libs[!(libs %in% installed.packages()[,1])])){
    if (l == "Rgraphviz"){
        source("https://bioconductor.org/biocLite.R")
        biocLite("Rgraphviz")
    }else{
        install.packages(l)
    }
}
sapply(libs,require, character.only = TRUE)

### Get the package, you can delete data/provR to 
### get the most up to date version
if (!file.exists("../data/provR")){
    system("git clone git@github.com:ProvTools/provR.git")
    system("mv provR ../data/")
}

### Initialize
rm(list = ls())
pkg.R <- dir(paste0("../data/", options()$pkg, "/R/"), full.names = TRUE)
sapply(pkg.R,source)

### Getting the dependency information
fw <- foodweb(plotting = F)
ig <- graph_from_adjacency_matrix(fw$funmat)

## These are the functions that prov.capture depends on
if (options()$pkg == "RDataTracker"){
    main.spine <- names(na.omit(bfs(ig,root ="ddg.json", 
                                    neimode = c('out'),
                                    unreachable = FALSE)$order))
    json.spine <- names(na.omit(bfs(ig,root ="ddg.json", 
                                    neimode = c('out'),
                                    unreachable = FALSE)$order))
}else if (options()$pkg == "provR"){
    main.spine <- names(na.omit(bfs(ig,root =".json", 
                                    neimode = c('out'),
                                    unreachable = FALSE)$order))
    json.spine <- names(na.omit(bfs(ig,root =".json", 
                                    neimode = c('out'),
                                    unreachable = FALSE)$order))
}

## Trace the path from prov.capture to its root
if (any(options()$pkg == c("RDataTracker", "provR"))){
    core <- c(main.spine,json.spine)[!duplicated(c(main.spine,json.spine))]
    all(sort(core) == sort(names(V(ig))[names(V(ig)) %in% core]))
    isg.main.spine <- induced_subgraph(ig,match(core,names(V(ig))))

    ## plots
    pdf(paste0("../results/", options()$pkg, "_dep_graph.pdf"), width = 20, height = 20)
    plot(isg.main.spine, vertex.size = 0.1, font = 2)
    dev.off()
    
    pdf(paste0("../results/", options()$pkg, "_dep_isg_graphnel.pdf"),width = 20, height = 20)
    isgm.gnl <- igraph.to.graphNEL(isg.main.spine)
    natt <- list(label = names(V(isg.main.spine)))
    names(natt$label) <- nodes(isgm.gnl)
    plot(isgm.gnl, nodeAttrs = natt, attrs = list(node=list(shape="ellipse", fixedsize=FALSE)))
    dev.off()
}
    pdf(paste0("../results/", options()$pkg, "_dep_graphnel.pdf"),width = 30, height = 30)
    ig.gnl <- igraph.to.graphNEL(ig)
    natt <- list(label = names(V(ig)))
    names(natt$label) <- nodes(ig.gnl)
    plot(ig.gnl, nodeAttrs = natt, attrs = list(node=list(shape="ellipse", fixedsize=FALSE)))
    dev.off()

### Functions that ddg.json uses
if (any(options()$pkg == c("RDataTracker", "provR"))){
    if (options()$pkg == "RDataTracker"){
        root <- "ddg.json"
    }else{
        root <- ".json"
    }

    json.search <- bfs(ig, root = root, 
                       neimode = c('out'),
                       unreachable = FALSE)
    spine <- names(na.omit(json.search$order))
    write.table(spine, 
                file = paste0("../results/", options()$pkg, "_json_deps.txt"), 
                row.names = FALSE, 
                col.names = FALSE, 
                quote = FALSE)
}
