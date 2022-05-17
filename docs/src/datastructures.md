# Datastructures

## Tour
Representation for a tour. Essentially boils down to a wrapper-type for `AbstractArray`s. The wrapper provides function `eachedge(t)', which returns pairs of successive elements in the tour (in other words, the sequence of edges which define the tour). 

```@example
using PolyaDataStructures
v = [1,2,3]
t = Tour(v)
println(t)
println("Index set: ", indexset(t))
collect(eachedge(t))
```


## TourWithOrigin
Almost identical to `Tour` but wit a fixed origin. As such, indexset(t::TourWithOrigin) = 2:length(t)

```@example
using PolyaDataStructures
v = [1,2,3]
t = TourWithOrigin(v)
println(t)
println("Index set: ", indexset(t))
collect(eachedge(t))
```