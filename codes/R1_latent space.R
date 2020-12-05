# load igraph
library(igraph)
# create an igraph object
#g1 <- graph (edges = c(dat$fr_loc))
#plot(g1)

nodes <- read.csv ("Nodes.csv", header = T, as.is=T)
links <- read.csv ("dat.csv", header = T, as.is = T)

head(nodes)

head(links)

net <- graph_from_data_frame(d=links, vertices=nodes, directed=F) 
net1 <- network (x=get.edgelist(net), matrix.type = "edgelist", directed = F)


class(net)

E(net)       # The edges of the "net" object

V(net)       # The vertices of the "net" object

E(net)$sci  # Edge attribute "sci"

V(net)$county # Vertex attribute "county"

# Plot the igraph
E(net)$width <- E(net)$sci/20000
plot(net, edge.arrow.size=.1,vertex.label=net$county)



plot(net, vertex.shape="none", vertex.label=V(net)$county, 
     
     vertex.label.font=2, vertex.label.color="gray40",
     
     vertex.label.cex=.7, edge.color="gray85")


# construct a latent space model for our data
data("net1")
network.vertex.names(nodes)

library(network)
try.fit <- ergmm(net1 ~ euclidean(d=2), tofit = c("mle"))

try.fit$mle$Z

plot(try.fit, label = nodes$county, labelsize = .01, vertex.col = NA, what = "mle", main = "MLE positions", print.formula = FALSE, labels = TRUE)
title(sub ="Labels the county in WA")



