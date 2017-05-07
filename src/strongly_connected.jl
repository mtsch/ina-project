using LightGraphs
using Plots

g = loadgraph("../models/iCHOv1-model/iCHOv1.lg")

ccs = connected_components(g)
println("Connected component sizes:")
println(unique(length.(ccs)))
largest, indices = induced_subgraph(g, ccs[indmax(length.(ccs))])
println("Strongly connected component sizes in the largest component:")
println(unique(length.(strongly_connected_components(largest))))
