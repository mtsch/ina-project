using LightGraphs
using Plots

g = loadgraph("../models/iCHOv1-model/iCHOv1.lg")

"""
Get the histogram of f(g)
"""
function gethist(f, g)
    vals = filter(x -> x > 0, f(g))
    hist = sum(sort(unique(vals)) .== vals', 2)
    find(hist), filter(x -> x > 0, hist) ./ sum(hist)
end

"""
Plot indegree, outdegree and degree of network g on the sampe plot.
"""
function degreeplot(g, title="")
    dx, dy = gethist(degree, g)
    ix, iy = gethist(indegree, g)
    ox, oy = gethist(outdegree, g)

    scatter(dx, dy, label="degree", scale=:log10, title=title,
            xlab = "degree", ylab = "p")
    scatter!(ix, iy, label="in degree")
    scatter!(ox, oy, label="out degree")
end

"""
Estimate the value of gamma for a degree distribution f(g).
"""
function gamma(f, g; delta = 1)
    k = filter(x -> x >= delta, f(g))
    n = length(k)

    1 + n * inv(sum(log.(k ./ (delta - 0.5))))
end
