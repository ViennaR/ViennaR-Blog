---
title: "igraph Applications for Transportation Networks"
author: "Maximilian Leodolter"
date: "2016-08-24T22:20:00+02:00"
output:
  md_document:
    variant: markdown_github
---

![IGraph](/img/igraph.jpeg)

A summary of Max Leodolters' **igraph** talk in May.

``` r
require(igraph)
require(data.table)
require(ggplot2)
```

Centrality - What is it?
========================

Network Centrality gives you an idea of how important a vertex/node and edge/link in your network/graph \(N(V,E)\) respectively \(G(N,L)\) is. Examples:

-   Closeness
-   Betweenness
-   Eigenvalue
-   degree
-   ...

<!--more-->

Some formulas:

-   Closeness Centrality \[ C^{node}(n) = \frac{1}{\sum_{m \in N \setminus \{n\}}d(n,m)} \]
-   Betweenness centrality \[ B^{node}(n) = \sum_{m\neq o \in N\backslash \{n\} } \frac{\sigma_{mo}(n)}{\sigma_{mo}} \]
-   Node-based Closeness for a link \[ \ddot{C}^{link}(l_{n,m}) = \frac{C^{node}(n) + C^{node}(m)}{2} \]
-   Node-based Betweenness for a link \[ \ddot{B}^{link}(l_{n,m}) = \frac{B^{node}(n) + B^{node}(m)}{2} \]
-   Link-based Betweenness for a link \[ B^{link}(l) = \sum_{n \neq m \in N } \frac{\sigma_{nm}(l)}{\sigma_{nm}} \] \*\(\sigma\) is the number of traversing OD relations, and \(d(n,m)\) is the distance of the shortest route from \(n\) to \(m\)

What to select, \(\ddot{B}^{link}(l_{n,m})\) or \(B^{link}(l)\)?

igraph for centralities
=======================

Node Betweenness
----------------

``` r
g <- make_star(5, mode = "undirected", center=3)
V(g)$name <- letters[1:length(V(g))]
plot(g)
```

![](/img/20160524_igraph_applications_files/figure-markdown_github/unnamed-chunk-2-1.png)

``` r
g <- set.edge.attribute(g, "weight",  value= 1)
b <- betweenness(g, directed=F)
V(g)$name <- b
plot(g)
```

![](/img/20160524_igraph_applications_files/figure-markdown_github/unnamed-chunk-2-2.png)

Edge Betweenness:

``` r
g <- make_star(5, mode = "undirected", center=3)
V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight",  value= 1)

bg <- edge_betweenness(g, directed=F)
plot(g, edge.label = bg)
```

![](/img/20160524_igraph_applications_files/figure-markdown_github/unnamed-chunk-3-1.png)

Local vs. Global
----------------

``` r
g <- make_graph(c(1, 2, 2, 3,#horizontal connections
                  4,5,5,6,6,7,
                  1,6,#vertical connections
                  2,7), directed = FALSE)
#g <- make_star(10, mode = "undirected", center=3)
V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight",  value= 1)
set.seed(2)
lay <- layout.auto(g)
bl <- estimate_edge_betweenness(g, cutoff = 1.5, directed=F);bl
```

    ## [1] 3 3 2 4 3 3 3

``` r
bg <- edge_betweenness(g, directed=F)


# set plotting parameters
vs <- 15# vertex.size
ec <- gray(0.8)#edge.color
elx <- 2# edge.label.cex
elc <- "black"#,edge.label.color
vlc <- 2#vertex.label.cex
ew <- 2#edge.width
hd <- paste(rep(" ",0), collapse="")
cm <- 3
vc <- "orange"#gray(0.8)#palette("default")#"grey"#vertex.color

dev.new(width = 18, height=6)
par(mfrow=c(1,3))

plot(g, edge.label=paste(hd, round(E(g)$weight,1)), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights", cex.main = cm)
plot(g, edge.label=paste(hd, round(bl,1)),          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Local Betweenness", cex.main = cm)
plot(g, edge.label=paste(hd, round(bg,1)),          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(c) Global Betweenness", cex.main = cm)
```

Node-based vs. link-based Betweenness for Links
-----------------------------------------------

``` r
g <- make_graph(c(1,2, 2,3, 3,4, 4,5,#horizontal connections
                  6,7, 7,8, 8,9, 9,10,
                  2,7,#vertical connections
                  3,8,
                  4,9), directed = FALSE)

V(g)$name <- letters[1:length(V(g))]
set.seed(1210)
g <- set.edge.attribute(g, "weight",  value= 1)
g <- set.edge.attribute(g, "weight", index= c(10), value= 2)
#plot(g,edge.label=paste(hd, round(E(g)$weight,1)))
lay <- layout.auto(g)
eb <- edge_betweenness(g, directed=F)
vb <- betweenness(g, directed=F)

tmp1 <- as.data.table(as.data.frame(cbind(get.edgelist(g))))
tmp1[,id:=1:.N]
tmp2 <- as.data.table(data.frame(value=vb, name=names(vb)))
setnames(tmp1, "V1", "name")
tmp3 <- merge(tmp1, tmp2, by ="name")
setnames(tmp3, "name", "V1")
setnames(tmp3, "V2", "name")
tmp4 <- merge(tmp3, tmp2, by ="name")
setnames(tmp4,  "name", "V2")
tmp4[,m:=mean(c(value.x, value.y)) , by=c("V2","V1")]
evb <- tmp4[order(id),list(V1,V2,m)]$m


# set plotting parameters
vs <- 15# vertex.size
ec <- "grey"#edge.color
elx <- 2# edge.label.cex
elc <- "black"#edge.label.color
vlc <- 2#vertex.label.cex
ew <- 2#edge.width
hd <- paste(rep(" ",0), collapse="")
cm <- 3
vc <- "orange"# vertex.color

dev.new(width = 18, height=6)
par(mfrow=c(1,3))

plot(g, edge.label=paste(hd, round(E(g)$weight,1)), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights",cex.main=cm)
plot(g, edge.label=paste(hd, round(eb,1)),          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Link based Betweenness",cex.main=cm)
V(g)$name <- paste(vb)
plot(g, edge.label=paste(hd, round(evb,1)),          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(c) Node based Betweenness" ,cex.main=cm)
```

Bugs/Features/Special experiences
---------------------------------

-   demonstrate the parameter 'lay' with setting it NULL
-   cutoff parameter
-   nodes need to be named for using induced.subgraph(), otherwise problems in matching results

### cutoff

stackoverflow: <http://stackoverflow.com/questions/34180036/how-does-the-cutoff-parameter-influence-betweenness-calculation>

discussion: <https://lists.nongnu.org/archive/html/igraph-help/2012-11/msg00083.html>

github project: <https://github.com/maxar/igraph_testing/blob/master/test_vertex_betweenness_local.R>

``` r
require(igraph)
packageVersion("igraph") # my installed version is 1.0.1
```

    ## [1] '1.0.1'

``` r
#----------------------------------------------------------------------------------------
#---------------    EXAMPLE 1    --------------------------------------------------------
#----------------------------------------------------------------------------------------

#--- set plotting parameters
vs <- 25# vertex.size
ec <- gray(0.8)#edge.color
elx <- 2# edge.label.cex
elc <- "black"#,edge.label.color
vlc <- 2#vertex.label.cex
ew <- 2#edge.width
cm <- 2
vc <- "orange"


g <- make_graph(c(1, 2, 2, 3, 3, 4, 4,5, 5, 6, 6, 7) , directed = FALSE)

set.seed(1210)
lay <- layout.auto(g)

graphics.off()
dev.new(width = 30, height=10)
par(mfrow=c(1,3))

V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight",  value= c(2,3,5,5,3,2))
plot(g, edge.label=round(E(g)$weight,1), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights", cex.main = cm)

bl.1 <- estimate_betweenness(g, cutoff=10)
V(g)$name <- bl.1
plot(g,        layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Local Betweenness\ncutoff 10", cex.main = cm)

bl.2 <- estimate_betweenness(g, cutoff=Inf)
V(g)$name <- bl.2
plot(g,        layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Global Betweenness\ncutoff Inf", cex.main = cm)


# Comments and Discussion:
# This simple example illustrates, why it is questionable
# that the cutoff parameter actually measures distance independent of the edge weights
#
# 1. define edge weights as in plot (a)
# 2. calculate vertex betweenness with cutoff 10 (b)
# 3. calculate vertex betweenness with cutoff Inf (c)






#----------------------------------------------------------------------------------------
#---------------    EXAMPLE 2    --------------------------------------------------------
#----------------------------------------------------------------------------------------

#--- set plotting parameters
vs <- 25# vertex.size
ec <- gray(0.8)#edge.color
elx <- 2# edge.label.cex
elc <- "black"#,edge.label.color
vlc <- 2#vertex.label.cex
ew <- 2#edge.width
cm <- 2
vc <- "orange"


set.seed(1210)
g <- make_ring(8)
lay <- layout.auto(g)

graphics.off()
dev.new(width = 12, height=12)
par(mfrow=c(2,2))

V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight", value= c(.1 , .2, rep(.1, 2), rep(0.2,4)))
plot(g, edge.label=round(E(g)$weight,1), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights", cex.main = cm)

bl.1 <- estimate_betweenness(g, cutoff=0.29)
V(g)$name <- bl.1
plot(g,        layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Local Betweenness\ncutoff 0.29", cex.main = cm)

V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight", value=.2)
plot(g, edge.label=round(E(g)$weight,1), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(c) new weights", cex.main = cm)

bl.2 <- estimate_betweenness(g, cutoff=0.29)
V(g)$name <- bl.2
plot(g,          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(d) Local Betweenness\ncutoff 0.29", cex.main = cm)


# Comments and Discussion:
# This simple example illustrates, that vertex betweenness values change,
# if the edge weights are changed and the cutoff parameters are chosen constant.
# Ring shape to reconstruct the calculation easier;
#
# 1. define edge weights as in plot (a)
# 2. calculate vertex betweenness with cutoff 0.29 (b)
# 3. define new edge weights as in plot (c)
# 4. calculate vertex betweenness with cutoff 0.29 (d)





#----------------------------------------------------------------------------------------
#---------------    EXAMPLE 3    --------------------------------------------------------
#----------------------------------------------------------------------------------------

#--- set plotting parameters
vs <- 20# vertex.size
ec <- gray(0.8)#edge.color
elx <- 1# edge.label.cex
elc <- "black"#,edge.label.color
vlc <- 1#vertex.label.cex
ew <- 2#edge.width
cm <- 2
vc <- "orange"


set.seed(1210)
g <- make_ring(20)
lay <- layout.auto(g)

graphics.off()
dev.new(width = 30, height=30)
par(mfrow=c(2,2))

V(g)$name <- letters[1:length(V(g))]
g <- set.edge.attribute(g, "weight", value= c(rep(2:3,10)))
plot(g, edge.label=round(E(g)$weight,1), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights", cex.main = cm)

bl.1 <- estimate_betweenness(g, cutoff=6)
V(g)$name <- bl.1
plot(g,        layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) Local Betweenness\ncutoff 6", cex.main = cm)

bl.2 <- estimate_betweenness(g, cutoff=9)
V(g)$name <- bl.2
plot(g,        layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(c) Local Betweenness\ncutoff 9", cex.main = cm)

bl.3 <- estimate_betweenness(g, cutoff=Inf)
V(g)$name <- bl.3
plot(g,          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(d) Global Betweenness\ncutoff Inf", cex.main = cm)


# Comments and Discussion:
# This simple example illustrates, that vertex betweenness values change,
# if the edge weights are constant and the cutoff parameters change.
# Ring shape to reconstruct the calculation easier;
#
# 1. define edge weights as in plot (a)
# 2. calculate vertex betweenness with cutoff 6 (b)
# 3. calculate vertex betweenness with cutoff 9 (c)
# 4. calculate vertex betweenness with cutoff Inf (d)
```

### normalization

stackoverflow: <http://stackoverflow.com/questions/34000326/normalized-local-closeness-centrality-in-r-igraphestimate-closeness>

I am trying to calculate a normalized local closeness centrality. But setting the parameter 'normalized = T' for igraph::estimate\_closeness() only multiplies the results with (N-1). Is it possible to define N\_i for vertex i individually by it's neighborhood, that is determined by the cut-off parameter (and of course by the graph itself)?

The mini example demonstrates, that setting the parameter 'normalized=T' does not work for this purpose. It normalizes with one and the same (N-1) for all vertices.

Thanks for help.

``` r
set.seed(1210)
require('igraph')
g <- random.graph.game(20,3/10)
g <- set.edge.attribute(g, "weight",  value= 1)
cnt <- estimate_closeness(g, cutoff = 3, normalized = T );cnt
```

    ##  [1] 0.6333333 0.2467532 0.3220339 0.5000000 0.5277778 0.5588235 0.6129032
    ##  [8] 0.5135135 0.5428571 0.5588235 0.4634146 0.5277778 0.6129032 0.5000000
    ## [15] 0.6333333 0.5000000 0.3392857 0.5135135 0.5135135 0.5135135

``` r
cnf <- estimate_closeness(g, cutoff = 3, normalized = F );cnf
```

    ##  [1] 0.03333333 0.01298701 0.01694915 0.02631579 0.02777778 0.02941176
    ##  [7] 0.03225806 0.02702703 0.02857143 0.02941176 0.02439024 0.02777778
    ## [13] 0.03225806 0.02631579 0.03333333 0.02631579 0.01785714 0.02702703
    ## [19] 0.02702703 0.02702703

``` r
#print results
cbind(cnf * (length(V(g))-1), cnt)
```

    ##                       cnt
    ##  [1,] 0.6333333 0.6333333
    ##  [2,] 0.2467532 0.2467532
    ##  [3,] 0.3220339 0.3220339
    ##  [4,] 0.5000000 0.5000000
    ##  [5,] 0.5277778 0.5277778
    ##  [6,] 0.5588235 0.5588235
    ##  [7,] 0.6129032 0.6129032
    ##  [8,] 0.5135135 0.5135135
    ##  [9,] 0.5428571 0.5428571
    ## [10,] 0.5588235 0.5588235
    ## [11,] 0.4634146 0.4634146
    ## [12,] 0.5277778 0.5277778
    ## [13,] 0.6129032 0.6129032
    ## [14,] 0.5000000 0.5000000
    ## [15,] 0.6333333 0.6333333
    ## [16,] 0.5000000 0.5000000
    ## [17,] 0.3392857 0.3392857
    ## [18,] 0.5135135 0.5135135
    ## [19,] 0.5135135 0.5135135
    ## [20,] 0.5135135 0.5135135

``` r
sum(abs(cnf * (length(V(g))-1) - cnt))
```

    ## [1] 8.326673e-17

``` r
#for visualization
V(g)$name <- paste("v", 1:length(V(g)), sep="")#letters[1:length(V(g))]
set.seed(2)
lay <- layout.auto(g)

## set plotting parameters
vs <- 15# vertex.size
ec <- gray(0.8)#edge.color
elx <- 2# edge.label.cex
elc <- "black"#,edge.label.color
vlc <- 2#vertex.label.cex
ew <- 2#edge.width
hd <- paste(rep(" ",0), collapse="")
cm <- 3
vc <- "orange"#gray(0.8)#palette("default")#"grey"#vertex.color

dev.new(width = 18, height=6)
par(mfrow=c(1,3))

plot(g, edge.label=paste(hd, round(E(g)$weight,1)), layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(a) Weights", cex.main = cm)

V(g)$name <- paste(round(cnt,3))
plot(g,          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(b) local closeness normalized", cex.main = cm)

V(g)$name <- paste(round(cnf,3))
plot(g,          layout=lay, vertex.size=vs, edge.color=ec, edge.label.cex=elx, vertex.label.cex=vlc, edge.width=ew, edge.label.color=elc, vertex.color=vc)
title("(c) local closeness", cex.main = cm)
```

#### My solution

easy workaround for local centralities: define neighborhood for each node, calcualte 'global' centralities for these neighborhoods and normalize it individually.

What for did we use centralities?
=================================

Thanks to Anita Graser for the beautiful plots!

\[\hat{y}_{t,\gamma}(s,b,c) = \beta_t  + \beta_{\gamma,s} \cdot s  + \beta_{\gamma,b} \cdot b + \beta_{\gamma,c} \cdot c + \beta_{\gamma,bc} \cdot b \cdot c\]

some plots:

Global Betweenness
------------------

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\map_bg.png)

Local Betweenness
-----------------

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\map_bl.png)

Global Closeness
----------------

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\map_cg.png)

Local Closeness
---------------

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\map_cl.png)

Real world difference of node-based and link-based Betweenness for a link
-------------------------------------------------------------------------

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\detail_bg_link.png) ![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\detail_bg_node.png)

Improvement travel time model
-----------------------------

### MAPE Difference Global minus local

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\map_mape_glob_minus_loc.png)

### Detail MAPE base

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\detail_mape_base.png)

### Detail MAPE with local centralities

![plot test](non_svn\Figures\publication_figures\improving-vehicle-speed\detail_mape_local.png)
