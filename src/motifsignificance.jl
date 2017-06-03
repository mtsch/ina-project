using DataFrames

function motifsignificance()
    coding = readtable("../snap-results/coding-table.csv")

    rgs = DataFrame[]
    for i in 1:10
        push!(rgs, readtable("../snap-results/rg$i-motifs-counts.tab", separator='\t'))
    end

    counts = readtable("../snap-results/iCHOv1-motifs-counts.tab", separator='\t')

    function significance(count, rgcounts)
        (count - mean(rgcounts)) / std(rgcounts)
    end

    for i in 1:nrow(counts)
        sig = significance(counts[:Count][i], map(rc -> rc[:Count][i], rgs))
        mid = coding[:M][i]

        println("$mid: $sig")
    end

end
