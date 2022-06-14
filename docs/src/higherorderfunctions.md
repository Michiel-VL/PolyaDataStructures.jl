# Higher Order Functions


## EdgeMapReduce

Struct to model mapreduce on edges of a struct. An edge is a pair of successive elements in the struct. 

If the mapreduce is to be applied on arbitrary constructs, it can be instantiated as follows.

```@example
using PolyaDataStructures
dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))
emr = EdgeMapReduce(dist, +, Int)
t = Tour([ntuple(i -> rand(1:10), 2) for i in 1:10])
t2 = Tour([ntuple(i -> rand(1:10), 6) for i in 1:10])
println("The length of tour $t is $(emr(t))")
println("The length of tour $t2 is $(emr(t2))")
```

In many applications, the reduction must be performed many times over a single object. If the object has as elements members of a fixed, finite set, memoization can be used: for each pair of elements $(e_1,e_2)$, $f(e_1,e_2)$ is computed and stored in a table. When the function is called later on, the memo is consulted instead of computing $f(e_1,e_2)$ anew. To make use of memoization, initialize the structure as follows: `EdgeMapReduce(f, r, C)`. Here, `C` is a collection of elements. If `C` has an index of type `Base.OneTo{Int}`, the memo is initialized as a `Matrix{V}`. If not, a `Dict{Tuple{eltype(C),eltype(C)},V}` is used.

```@example
using PolyaDataStructures
C = [(rand(1:10),rand(1:100)) for i in 1:10]
t = Tour(eachindex(C))
dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))
emr = EdgeMapReduce(dist, +, C)
v = emr(t)
println("The total length of tour t is: $v")
i = 2
j = 7
v2 = emr(t, v, swap!, i, j)
println("Swapping elements $i and $j in $t results in a total length of $v2.")
```

Currently, delta-evaluation is still hardcoded. Following reducing operations have been implemented: `+`, `*` and `-`.  However, in the future, extensions for various map-functions and reduce-operators will be implemented. Currently, delta-evaluation assumes `f(i,j) = f(j,i)`.