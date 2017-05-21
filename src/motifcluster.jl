using PyCall

@pyimport sklearn.metrics as metrics

nmi = metrics.normalized_mutual_info_score

fn = "../motifcluster-results/iCHOv1-connected-M10-cluster.txt"

function parseresults(fn)
    str = readstring(fn)
    clusters = Vector{Int}[]

    for l in split(str, '\n')[1:end-1]
        push!(clusters, parse.([Int], split(l, '\t')))
    end

    res = zeros(Int, sum(length.(clusters)))

    for i in eachindex(clusters)
        for j in clusters[i]
            res[j] = i
        end
    end

    res
end

function get_subsystem_classes(metafn="../models/iCHOv1-model/iCHOv1-meta-connected.csv")
    meta_str = readcsv(metafn)[2:end,4]
    subsystems = unique(meta_str)

    meta_num = zeros(Int, length(meta_str))

    for (i, s) in enumerate(meta_str)
        meta_num[i] = findfirst(s .== subsystems)
    end

    meta_num
end

# ———————————————————————————————————————————————————————————————————————————— #
meta_num = get_subsystem_classes()

for motif in ["M" .* string.(1:13); "bifan"; "edge"]
    r = parseresults("../motifcluster-results/iCHOv1-connected-$motif-cluster.txt")
    println("$motif -> $(nmi(r, meta_num))")
end
