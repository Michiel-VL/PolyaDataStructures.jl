"""
    struct IndexIterator{S}

Index sets for recursive data structure with type `S`.

    The purpose of this data structure is to provide an easy mechanism to define neighborhoods in terms of the index-set of a data structure. As an example, the function call `swap(s,i,j)` changes the elements s[i] and s[j] of place. We want this to be polymorphic over the indices passed. 
"""
mutable struct IndexIterator{S,I}
    s::S
    Iset::I
end

IndexIterator(s) = IndexIterator(s, indexset(s))

state(itr::IndexIterator) = itr.s


Base.eltype(itr::IndexIterator) = eltype(typeof(itr))
Base.eltype(::Type{IndexIterator{S,I}}) where {S,I} = indextype(S)
Base.length(itr::IndexIterator) = length(indexset(state(itr)))


function Base.iterate(itr::IndexIterator)
    itr.Iset = indexset(state(itr))
    I = itr.Iset
    r = iterate(I) 
    isnothing(r) && return nothing
    return r
end

function Base.iterate(itr::IndexIterator, state)
    I = itr.Iset
    r = iterate(I, state)
    isnothing(r) && return nothing
    return r
end

function Base.show(io::IO, m::MIME"text/plain", itr::IndexIterator)
    println(io, "IndexIterator:")
    
    print(io, "i ∈ ", join(first(itr, min(3, length(itr))), ","), "…")
end
