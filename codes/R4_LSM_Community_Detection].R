rm(list = ls())
options(max.print = 1000)

setwd("./raw data")

packages <- c(
    "tidyverse", "tidylog", "haven", "igraph", "network", "VBLPCM", "latentnet", "readxl"
)
sapply(packages, require, character.only = TRUE)
rm(packages)

wa_sci <- read_tsv("county_county_aug2020.tsv") %>%
    filter(str_detect(user_loc, "^53"), str_detect(fr_loc, "^53"), user_loc != fr_loc) %>%
    rename("weight" = "scaled_sci")

pop <- read_xls("./population.xls") %>%
    filter(str_detect(FIPStxt, "^53")) %>%
    select(FIPStxt, `Rural-urban_Continuum Code_2013`, POP_ESTIMATE_2019, R_NET_MIG_2019) %>%
    rename("id" = "FIPStxt", "rural_degree" = "Rural-urban_Continuum Code_2013", "pop" = "POP_ESTIMATE_2019", "mig_rate" = "R_NET_MIG_2019")
edu <- read_xls("./education.xls") %>%
    `colnames<-`(make.names(colnames(.))) %>%
    filter(str_detect(FIPS.Code, "^53")) %>%
    select(FIPS.Code, Percent.of.adults.with.a.bachelor.s.degree.or.higher..2014.18) %>%
    rename("id" = "FIPS.Code", "per_high_edu" = "Percent.of.adults.with.a.bachelor.s.degree.or.higher..2014.18")
poverty <- read_xls("./poverty.xls") %>%
    filter(str_detect(FIPStxt, "^53")) %>%
    select(FIPStxt, POVALL_2018) %>%
    rename("id" = "FIPStxt", "poverty" = "POVALL_2018")
wa_counties <- read_csv("Nodes.csv") %>%
    mutate(id = as.character(id)) %>%
    left_join(., pop) %>%
    left_join(., edu) %>%
    left_join(., poverty)

wa_graph <- graph_from_data_frame(d = wa_sci, vertices = wa_counties)

# community structure
clusters <- cluster_edge_betweenness(
    wa_graph, weights = E(wa_graph)$weight,
    directed = TRUE, edge.betweenness = TRUE, merges = TRUE,
    bridges = TRUE, modularity = TRUE, membership = TRUE
)
set.seed(98105)
pdf("./community_net.pdf",  height = 6, width = 6)
plot(
    wa_graph,
    edge.width = E(wa_graph)$weight / 1000000,
    edge.arrow.size = E(wa_graph)$weight / 1000000,
    vertex.label = V(wa_graph)$county, vertex.label.cex = 0.5,
    vertex.label.font = 2, vertex.size = 5,
    vertex.color = clusters$membership,
    vertex.frame.color = "transparent"
)
dev.off()

unique(clusters$membership)
usmap::plot_usmap(
    "counties", include = "WA",
    data = data.frame(
        fips = wa_counties$id,
        membership = factor(clusters$membership)
    ),
    values = "membership"
)
# construct a network object
wa_net <- network(x = get.edgelist(wa_graph), matrix.type = "edgelist", directed = TRUE)
set.edge.value(wa_net, "weight", log(E(wa_graph)$weight))
set.vertex.attribute(wa_net, "rural_degree", wa_counties$rural_degree)
set.vertex.attribute(wa_net, "log_pop", log(wa_counties$pop))
set.vertex.attribute(wa_net, "mig_rate", wa_counties$mig_rate)
set.vertex.attribute(wa_net, "per_high_edu", wa_counties$per_high_edu)
set.vertex.attribute(wa_net, "log_poverty", log(wa_counties$poverty))
# latent space model for 2d and 3d latent space
fit2 <- ergmm(
    wa_net ~ euclidean(d = 2) + rsender + rreceiver,
    response = "weight",
    family = "normal",
    fam.par = list(prior.var = 1, prior.var.df = 1),
    seed = 98105, verbose = TRUE
)
fit3 <- ergmm(
    wa_net ~ euclidean(d = 3) + rsender + rreceiver,
    response = "weight",
    family = "normal",
    fam.par = list(prior.var = 1, prior.var.df = 1),
    seed = 98105, verbose = TRUE
)
## plot network in latent space
# load vote counts dataset
vote <- read_csv("./2020_US_County_Level_Presidential_Results.csv") %>%
    filter(str_detect(county_fips, "^53")) %>%
    select(county_fips, county_name, per_point_diff)
# 2d plot
library(plotly)
library(RColorBrewer)
pos2 <- fit2$mkl$Z
plot_ly(
    x = pos2[, 1], y = pos2[, 2],
    color = vote$per_point_diff,
    colors = c("#377EB8", "#984EA3", "#E41A1C"),
    text = ~paste(
        '</br> County: ', vote$county_name,
        '</br> Vote Margin: ', round(vote$per_point_diff, 2)
    )
)
plot(fit2)
# 3d plot
pos3 <- fit3$mkl$Z
plot_ly(
    x = pos3[, 1], y = pos3[, 2], z = pos3[, 3],
    color = vote$per_point_diff,
    colors = c("#377EB8", "#984EA3", "#E41A1C"),
    text = ~paste(
        '</br> County: ', vote$county_name,
        '</br> Vote Margin: ', round(vote$per_point_diff, 2)
    )
)
