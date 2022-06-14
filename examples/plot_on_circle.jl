using Pkg
cd(@__DIR__)
Pkg.activate("..")
using Plots
using PolyaDataStructures
using StatsBase
using IterTools

ncities = 10
dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))
C = [(rand(1:10000), rand(1:10000)) for i in 1:ncities]
min_idx = argmin(sum.(eachrow([dist(c1,c2) for c1 in C, c2 in C])))
swap!(C, 1, min_idx)
sort!(C, by = x -> dist(C[1],x))
scatter(C)

rr(v, n) = (v-1) % n + 1

function repset(ncities, ndims)
    ncols = ncities - 1
    A = zeros(Int,ntuple(x->ncols, ndims)...)
    for i in 1:ncols
        A[i,:] .= 1:ncols
    end
    for i in 1:ncols
        A[i,:] = rr.(A[i,:] .+ i, ncols) .+1
    end
    B = vcat(A[ncols,:]', A[1:ncols-1,:])
    return B
end

function stackmats(A)
    Aset = [A]
    for i in 1:dims(A,1)-1
        push!(Aset, rr.(A, ncities-1 .+1))
end


A = repset(ncities, 2)
tourset = map( r->TourWithOrigin(1, r), eachrow(A))
emr = EdgeMapReduce(dist, +, C)

objvals = emr.(tourset)


O = objvals / mean(objvals) .- 1
tovecs(C, tour) = first.(C[tour]), last.(C[tour])

p1 = plot(legend=false)
V = tovecs.(Ref(C), tourset)
foreach(v -> plot!(v...), V)

p2 = bar(O, legend = false)

plot(p1, p2, layout= grid(2,1, heights=[ .8 ,.2]))