using COBRA
using JSON
using LightGraphs

function mat2net(filename="../models/iCHOv1-model/iCHOv1.mat", name="iCHOv1")

    # Load model and make links simple.
    model = loadModel(filename, "S", name)

    s = map(sign, model.S)
    rxns = model.rxns

    nv = size(s, 2)
    g = DiGraph(nv)

    # Find a common reactant for each pair of reactions.
    for i in 1:nv
        for j in i:nv
            common = s[:, i] .* s[:, j]
            for k in common.nzind
                if s[k, i] > s[k, j]
                    add_edge!(g, i, j)
                elseif s[k, i] < s[k, j]
                    add_edge!(g, j, i)
                end
            end
        end
    end

    g, rxns
end

function create_csv(filename = "../models/iCHOv1-model/iCHOv1-meta.csv";
                    jsonfile = "../models/iCHOv1-model/iCHOv1.json",
                    matfile  = "../models/iCHOv1-model/iCHOv1.mat",
                    name     = "iCHOv1")

    metadata = JSON.parse(readstring(jsonfile))
    _, rxns  = mat2net(matfile, name)

    output = Array{String, 2}(length(rxns) + 1, 4)
    output[1, :] = ["node", "name_1", "name_2", "subsystem"]

    for (i, r) in enumerate(metadata["reactions"])
        println("$(r["name"]) === $(rxns[i])")
        output[i+1, :] .= string.([i,
                                   rxns[i],
                                   r["name"],
                                   r["subsystem"]])
    end

    writecsv(filename, output)
    output
end
