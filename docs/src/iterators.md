# Iterators documentation

A substantial part of the 



## OrderedProductIterator


```@example
using PolyaDataStructures, Plots
n = 10
J = 1:n
Jr = Iterators.reverse(J)
𝒥 = (J, Jr)
𝒯 = ((1,2),(2,1))
configs = Iterators.product(𝒯,𝒥,𝒥)
Iset = map(c -> orderedproduct(c[1], c[2:end]...), configs)
P = enumerationplot.(Iset, Ref((n,n)), markersize=5, size=(800,800))
plot(P..., layout=(4,2), size = (1000, 2000))
``` 




## OffsetOrderIterator

```@example
using PolyaDataStructures, Plots
n = 5
J = 1:n
Jr = Iterators.reverse(J)
𝒥 = (J, Jr)
𝒯 = ((1,2),(2,1))
configs = Iterators.product(𝒯,𝒥,𝒥)
Iset = map(c -> orderedproduct(c[1], c[2:end]...), configs)
Ioffset = map(I -> OffsetOrderIterator(I, n), Iset)
P = enumerationplot.(Ioffset, Ref((n,n)))
plot(P..., layout=(4,2), size = (1000, 2000))
``` 


## DisjointUnionIterator

The [disjoint union](https://en.wikipedia.org/wiki/Disjoint_union) of a family of sets consists of a new set, of which the members are the members of the old sets, each labeled with the index of the original set they belonged to.

$$\sqcup_{i \in I} A_i = Union_{i \in I} \{(x,i): x \in A_i \}$$

The DisjointUnionIterator provided gives an iterator whic


```@example
using PolyaDataStructures
s1 = [:a,:b,:c]
s2 = [:d,:e,:f]

I = DisjointUnionIterator(s1, s2)
collect(I)
```

The disjoint union iterator can be used to construct an index set over nested indexed structs. The index set can be defined at a certain depth of the nesting.

```@example
using PolyaDataStructures
v = [[[1,32],[2,7,5]],[[4],[12,3]],[[8,9],[10,12]]]
I = indexset(v, 3)
map(i -> i => v[i], I)
```
This enables us to define various operations on v based on the index structure.

```@example
using PolyaDataStructures
v = [[[1,32],[2,7,5]],[[4],[12,3]],[[8,9],[10,12]]]
I1 = indexset(v,1)
I2 = indexset(v,2)
I3 = indexset(v,3)
# Three examples
println(v)
swap!(v, first(I1), last(I1))
println(v)
swap!(v, first(I2), last(I2))
println(v)
swap!(v, first(I3), last(I3))
println(v)
``` 
