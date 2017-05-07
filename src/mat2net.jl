using COBRA
using LightGraphs

function mat2net(filename="./iCHOv1-model/iCHOv1.mat", name="iCHOv1")

    # Load model and make links simple.
    s = map(sign, loadModel(filename, "S", name).S)

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

    g
end
