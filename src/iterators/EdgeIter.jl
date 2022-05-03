"""
    EdgeIter{T,N,V <: AbstractArray{T,N}}

`EdgeIter(v)` returns an iterator over pairs of subsequent elements (edges) from `v`, ending with the pair `(v[n], v[1])`, where `n = length(v)`.
"""
struct EdgeIter{T,N, V <: AbstractArray{T,N}}
    v::V
end

Base.size(e::EdgeIter) = (length(e.v),)
Base.length(e::EdgeIter) = length(e.v)
Base.eltype(::Type{EdgeIter{T, N, V}}) where {N,T,V} = Tuple{T,T}
Base.IteratorSize(::Type{EdgeIter}) = Base.HasLength()

#TODO: Figure out where the allocation is happening in iterate. Look at the iterator-implementations in Base.

function Base.iterate(e::EdgeIter)
    r = iterate(e.v)
    inner_iter(e, r)
end

function Base.iterate(e::EdgeIter, state)
    r = iterate(e.v, state)
    inner_iter(e, r)
end

function inner_iter(e::EdgeIter, r)
    isnothing(r) && return nothing
    el, state = r
    el == last(e.v) && return ((el, first(e.v)), state)
    return ((el, first(iterate(e.v, state))), state)
end