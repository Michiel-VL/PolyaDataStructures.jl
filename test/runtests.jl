using Test
using PolyaDataStructures

# Test operators 

seq = [4,2,1,5,3,6,7]
t = Tour(copy(seq))
t2 = TourWithOrigin(copy(seq))
svec = [seq, t, t2]

@testset "Operators" begin
    correct = [4,2,3,5,1,6,7]
    foreach(s -> (@test swap!(s, 3, 5) == correct), svec)
    correct = [4,6,1,5,3,2,7]
    foreach(s -> (@test twoopt!(s, 2, 6) == correct), svec)
    correct = [4,6,1,3,2,7,5]
    foreach(s -> (@test shift!(s, 4, 7) == correct), svec)
    correct = [4,7,6,1,3,2,5]
    foreach(s -> (@test shift!(s, 6, 2) == correct), svec)
end

# Test Iterators
# Check if the various orders all contain the correct elements wrt a reference set (orderless set of all elements in a neighborhood)
# Check if the ordering is correct (less important, but relevant wrt naming)

# Tests of EdgeMapReduce
"""
    compare_Δeval_and_eval(t, op, nmop, I, f)

For parameters ϕ ∈ I, test if the delta-evaluation of op(t,ϕ...) is equal to the evaluation of nmop(t,ϕ...)
"""
function compare_Δeval_and_eval(t, op, nmop, I, f)
    v = f(t)
    #println(v)
    for ϕ in I
        #println(ϕ)
        v1 = f(t, v, op, ϕ...)
        t2 = nmop(t, ϕ...)
        #println(t)
        #println(t2)
        v2 = f(t2)
        #println(v1 , " == ", v2)
        @test isapprox(v1, v2)
    end
end

## Representations
seq = [4,2,1,5,3,6,7]

Rcons = [identity, Tour, TourWithOrigin]
Rset  = map(rc -> rc(copy(seq)), Rcons)
RIset = map(r -> (r, Iterators.product(indexset(r), indexset(r))), Rset)

## Local Search Operators

ops = [swap!, twoopt!, shift!]
nmops = [swap, twoopt, shift]
Opset = zip(ops, nmops)

## Function definitions

dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))

fset = [dist]
rset = [+,*,-]
vset = [Int, Float64, Rational{Int}, 1:10]

options = Iterators.product(fset, rset, vset)

EMRset = map(option -> EdgeMapReduce(option...), options)

# bringing together everything

param_tuples = [(RI[1], OP..., RI[2], f) for (RI, OP, f) in Iterators.product(RIset, Opset, EMRset)]

@testset "EdgeMapReduce" begin
    for p in param_tuples
        @testset "Testing $p" begin
            compare_Δeval_and_eval(p...)
        end
    end
end


# Constructive operations
C = [8,9,10]
cons = [push!, pop!, insert!]
nmcons = [x -> push!(copy(x[1]), x[2]), x-> pop!(copy(x[1])), x -> insert!(copy(x[1]), x[2], x[3])]

Opset = zip(cons, nmcons)

#TODO: match index set with repr and op, run tests
#=
@testset "EdgeMapReduce" begin
    for p in param_tuples
        @testset "Testing $p" begin
            compare_Δeval_and_eval(p...)
        end
    end
end
=#
