# Iterators documentation

An important goal of this package is to provide several iterators useful during local search.


## OrderedProductIterator

Given sets ``A,B``, the [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) ``A \times B`` is defined as:

```math
    A \times B = \{(a,b) : a \in A \text{ and } b \in B \}
```

For example, if:
```math
\begin{align*}
             A &= \{1,2,3 \} \\
             B &= \{1, 2\} \\
    A \times B &= \{(1,1),(1,2),(2,1),(2,2),(3,1),(3,2)\}
\end{align*}
```

An iterator for the Cartesian product of sets (or `AbstractArray`s) is available in julia through the struct `Iterators.ProductIterator`. The `OrderedProductIterator` is similar to `Iterators.ProductIterator`, but allows the user to pass an order along with the sets. 

```@example
using PolyaDataStructures
A = [1,2,3]
B = [1,2]
I = orderedproduct((2,1), A, B)
collect(I)
```

The `orderedproduct` can be used to generate various parameter space enumeration schemes for local search operations by relying on the indexset of a datastructure. These can compose into neighborhood enumerations which can be used during optimization.

```@example
using PolyaDataStructures, Plots
s = Tour([i for i in 1:3])
J = indexset(s)
I1 = orderedproduct((1,2), J, J)
I2 = orderedproduct((2,1), J, J)
println(collect(I1))
println(collect(I2))
```

Based on the default definition of the index set of a struct and its reverse, following orders can be defined:

```@example
using PolyaDataStructures, Plots
n = 5 
s = Tour([i for i in 1:n])
J = indexset(s)
Jr = Iterators.reverse(J)
𝒥 = (J, Jr)         # set options
𝒯 = ((1,2),(2,1))   # Different orders

configs = Iterators.product(𝒯,𝒥,𝒥)
Iset = map(c -> orderedproduct(c[1], c[2:end]...), configs)
P = enumerationplot.(Iset, size.(Iset))
plot(P..., layout=(2,4), size = (800, 400))
``` 


## OffsetOrderIterator
The offset iterator takes a quadratic iterator ``I`` as input and uses it to construct a new iterator ``J`` with as elements the transformation of the elements ``t \in I`` in the original iterator according to `t -> (t[1], (t[1] + t[2] - 1) % iter.n + 1)`.

```@example
using PolyaDataStructures
A = [1,2,3]
B = [1,2,3]
I = orderedproduct((2,1), A, B)
J = OffsetOrderIterator(I, 3)
```

We can reuse the OrderedProductIterators we defined earlier as a basis to create a new set of iterators. 

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
plot(P..., layout=(2,4), size = (800, 400))
``` 

## Predefined quadratic operators

Two predefined quadratic operators are available, which can be configured in various ways, resulting in 12 different iteration schemes.

### NoDiagMatrixIterator
Given ``I = \{1,2,3,\dots,n\}``, iterates over ``I \times I`` while skipping the elements on the diagonal (that is, the pairs ``(i,j): i = j``). Is defined in terms of ``n`` and takes a trait indicating the main iteration direction.

```@example
using PolyaDataStructures
n = 3
collect(NDMI(ColMajor, n))
```

This gives rise to a total of six iterators.


```@example
using PolyaDataStructures, Plots
n = 5
orders = [ColMajor, RowMajor, DiagMajor]
Iset = [NDMI(order,n) for order in orders] 
Iset = vcat(Iset, Iterators.reverse.(Iset))
P = enumerationplot.(Iset, Ref((n,n)))
plot(P..., layout=(2,3), size = (600, 400))
```

### LowerTriMatrixIterator
Given ``I = \{1,2,3,\dots,n\}``, iterates over ``I \times I`` while skipping the elements on or above the diagonal (that is, the pairs ``(i,j): i < j``). Is defined in terms of ``n`` and takes a trait indicating the main iteration direction.

```@example
using PolyaDataStructures
n = 3
collect(LTMI(ColMajor, n))
```

This gives rise to a total of six iterators.

```@example
using PolyaDataStructures, Plots
n = 5
orders = [ColMajor, RowMajor, DiagMajor]
Iset = [LTMI(order,n) for order in orders] 
Iset = vcat(Iset, Iterators.reverse.(Iset))
P = enumerationplot.(Iset, Ref((n,n)))
plot(P..., layout=(2,3), size = (600, 400))
```

### Runtime comparison with definition based on orderedproduct

Some of the iterators `LTMI` and `NDMI` can also be constructed by applying filters to `orderedproduct`. However, typically, the `NDMI`/`LTMI`implementation outperforms the more generic implementation using `orderedproduct`.

```@repl
using PolyaDataStructures, BenchmarkTools
n = 500;
I = NDMI(ColMajor, n);
@benchmark collect($I)
I = Iterators.filter(ϕ -> ϕ[1] != ϕ[2], Iterators.product(1:n, 1:n));
@benchmark collect($I)
I = NDMI(RowMajor, n);
@benchmark collect($I)
I = Iterators.filter(ϕ -> ϕ[1] != ϕ[2], orderedproduct((2,1), 1:n, 1:n));
@benchmark collect($I)

```



## DisjointUnionIterator

The [disjoint union](https://en.wikipedia.org/wiki/Disjoint_union) of a family of sets consists of a new set, of which the members are the members of the old sets, each labeled with the index of the original set they belonged to.

```math
\sqcup_{i \in I} A_i = \cup_{i \in I} \{(i,x): x \in A_i \}
```

The DisjointUnionIterator is an iterator over the disjoint union of sets. 


```@example
using PolyaDataStructures
s1 = [:a,:b,:c]
s2 = [:d,:e,:f]

I = DisjointUnionIterator(s1, s2)
collect(I)
```

It can be used to construct an index set over nested indexed structs. Furthermore, the nesting can be set at various nesting levels.

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
println("Original structure:") 
println(v) 
println("First and last element of top level are swapped (swap two vectors of vectors):") 
swap!(v, first(I1), last(I1))
println(v)
println("First and last element of second level are swapped (swap two vectors):") 
swap!(v, first(I2), last(I2))
println(v) 
println("First and last element of lowest level are swapped (swap two integers):")
swap!(v, first(I3), last(I3))
println(v)
```