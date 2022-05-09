# PolyaDataStructures
Functionality to support the design of heuristic solution methods for combinatorial optimization problems in [Polya.jl](https://Michiel-VL/Polya.jl).

## Data Structures
- Tour: A wrapper for AbstractArrays which provides an EdgeIterator
- TourWithOrigin: Similar to the previous, but with a rootnode.
- ElementConstraint:

## Operators
- Implementation of some default operations useful in local search.
- Operator views to provide the effect of an operator application without applying it.
## Iterators
- EdgeIterator: Iterator over pairs of successive elements in AbstractArrays and Tours.
## Function structs
- EdgeMapReduce
