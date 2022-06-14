"""
    Tour{T,V}

Wrap around a struct with linear indexing to interpret it as a tour. The tour starts at the first index and finishes at the last. Calling `eachedge(t::Tour)` returns pairs `(s[i],s[i+1])` for each `i ∈ eachindex(t)`. If `i == n` then `i+1 = 0`. 
"""
struct Tour{T, V} <: AbstractTour{T}
    v::V

    function Tour(v::V) where {T,N, V <: AbstractArray{T,N}}
        return new{T, V}(v)
    end
end

Base.length(t::Tour) = length(t.v)
Base.size(t::Tour) = size(t.v)

Base.getindex(t::Tour, i::Int) = getindex(t.v, i)
Base.setindex!(t::Tour, v, i::Int) = setindex!(t.v, v, i)

"""
    eachedge(t::Tour)

returns an iterator over pairs of successive elements in `t`.
"""
eachedge(t::Tour) = EdgeIter(t)


Base.resize!(t::Tour, i) = resize!(t.v, i)

function Base.insert!(t::Tour, i, e) 
    insert!(t.v, i, e)
    return t
end

function Base.deleteat!(t::Tour, i)
    deleteat!(t.v, i)
    return t 
end

function Base.pop!(t::Tour)
     pop!(t.v)
     return t
end

Base.copy(t::Tour) = Tour(copy(t.v))