"""
    OffsetOrderIterator

Reuse a quadratic iterator.

# Example Usage
julia> collect(OffsetOrderIterator(Iterators.product(1:3, 1:3), 3))
3×3 Matrix{Tuple{Int64, Int64}}:
 (1, 2)  (1, 3)  (1, 1)
 (2, 3)  (2, 1)  (2, 2)
 (3, 1)  (3, 2)  (3, 3)
"""
struct OffsetOrderIterator{I,N}
    iter::I
    n::N
end

offsetorder(iterator, n) = OffsetOrderIterator(iterator, n)

Base.IteratorSize(::Type{OffsetOrderIterator{I,N}}) where {I,N} = Base.IteratorSize(I)
Base.eltype(::Type{OffsetOrderIterator{I, N}}) where {I,N} = eltype(I)
Base.length(it::OffsetOrderIterator) = length(it.iter)
Base.size(it::OffsetOrderIterator) = size(it.iter)
offset(iter::OffsetOrderIterator, t) = (t[1], (t[1] + t[2] - 1) % iter.n + 1)


function Base.iterate(iter::OffsetOrderIterator)
    res = iterate(iter.iter)
    isnothing(res) && return nothing
    r, nextstate = res
    return offset(iter, r), nextstate
end

function Base.iterate(iter::OffsetOrderIterator, state) 
    res = iterate(iter.iter, state)
    isnothing(res) && return nothing
    r, nextstate = res
    return offset(iter, r), nextstate
end

