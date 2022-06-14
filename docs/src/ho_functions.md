# Higher Order Functions


## EdgeMapReduce
Struct to model mapreduce on "edges" of a struct. An edge is a pair of successive elements in the struct. 


If the mapreduce is to be applied on arbitrary constructs, it can be instantiated as follows. This instantiation will apply delta-evaluation, even if a given 

```@example
using PolyaDataStructures
dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))
emr = EdgeMapReduce(dist, +, 0)
t = Tour([ntuple(i -> rand(1:10), 2) for i in 1:10])
push!(resvec, emr(t)))
t2 = Tour([ntuple(i -> rand(1:10), 6) for i in 1:10])
println(emr(t2))
println(emr(t3))
```

In many applications, the reduction must be performed many times over a single object. 

```@example
using PolyaDataStructures
C = [(rand(1:10),rand(1:100)) for i in 1:10]
t = Tour(C)
dist(c1, c2) = Int(round(sqrt(sum((c1 .- c2).^2))))
emr = EdgeMapReduceMemoized(dist, +, C)
```

Currently, delta-evaluation is still hardcoded. The only reducing operator implemented is `+`. However, in the future, extensions for various map-functions and reduce-operators will be implemented. First on the list is generalization of the map-function. Currently, the delta-evaluation relies on the property f(i,j) = f(j,i), which is quite a specific function already.