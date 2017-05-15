using LightGraphs
using LightGraphsExtras

using Plots
using PlotRecipes
plotly()

using DataFrames
using Lazy
using DataFramesMeta

using PyCall
@pyimport networkx
@pyimport community
@pyimport sklearn.metrics as metrics

using Combinatorics

# Algorithms ...................................................................
"""
Community detection using infomap.
"""
function infomap(g; quiet=true, clean=true)
    save("temp", g)
    run(pipeline(`cat temp`, `tail -n +2`, `sed "s/,/ /g"`, "temp.txt"))

    if quiet
        run(pipeline(`infomap/Infomap temp.txt .`, stdout=DevNull))
    else
        run(`infomap/Infomap temp.txt .`)
    end
    run(pipeline(`cat temp.tree`, `tail -n +2`, `sed "s/#//"`, "temp.tab"))
    table = readtable("temp.tab", separator=' ', header=true)

    if clean
        rm("temp")
        rm("temp.txt")
        rm("temp.tab")
        rm("temp.tree")
    end

    @> begin
        table
        @transform(infomap = parse.([Int], first.(split.(:path, [':']))))
        @select(node = :node_, :infomap)
        @orderby(:node)
    end
end

"""
Community detection using louvain.
"""
function louvain(g; clean=true)
    save("temp", g)
    run(pipeline(`cat temp`, `tail -n +2`, `sed "s/,/ /g"`, "temp.txt"))
    G = networkx.read_adjlist("temp.txt")
    partition = community.best_partition(G)

    if clean
        rm("temp")
        rm("temp.txt")
    end

    node = Int[]
    group = Int[]
    for i in vertices(g)
        if haskey(partition, "$i")
            push!(node, i)
            push!(group, partition["$i"])
        end
    end
    DataFrame(node = node, louvain = group)
end

"""
Wrapper for label propagation
"""
function labprop(g)
    DataFrame(node = vertices(g),
              labprop = label_propagation(g)[1])
end

# Misc .........................................................................
nmi = metrics.normalized_mutual_info_score

"""
Entropy of vector
"""
function ent(x)
    hst = sum(Float64.(x' .== unique(x)), 2)
    hst ./= sum(hst)
    -sum(hst .* log(hst))
end

"""
Normalized variation of information.
"""
function nvi(x, y)
    @assert length(x) == length(y)
    hx = ent(x)
    hy = ent(y)

    (hx + hy - 2metrics.mutual_info_score(x, y)) / log(length(x))
end
