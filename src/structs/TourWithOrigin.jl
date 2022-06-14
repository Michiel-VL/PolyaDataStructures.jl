"""
    struct TourWithOrigin{T,V} <: AbstractTour{T,V}

Represents a tour through a sequence of elements {T}. Use method `eachedge(t)` to get an iterator over the edges of the tour. Similar to `Tour`, with the exception that the first element here is immutable and not included in the `indexset`.
"""
struct TourWithOrigin{T, V} <: AbstractTour{T}
    origin::T
    v::V
    function TourWithOrigin(origin::T, v::V) where {T,V <: AbstractVector{T}}
        return new{T,V}(origin, v)
    end
end

TourWithOrigin(v::Vector) = TourWithOrigin(first(v), v[2:end])

Base.length(t::TourWithOrigin) = length(t.v) + 1
Base.size(t::TourWithOrigin) = (length(t), )

Base.getindex(t::TourWithOrigin, i::Int) = i == 1 ? t.origin : getindex(t.v, i - 1)

function Base.setindex!(t::TourWithOrigin, v, i::Int) 
    i == 1 && error("The first element of a TourWithOrigin can not be changed!")
    setindex!(t.v, v, i-1)
end

"""
    eachedge(t::TourWithOrigin)

returns an iterator over pairs of successive elements in `t`.
"""
eachedge(t::TourWithOrigin) = EdgeIter(t)




Base.resize!(t::TourWithOrigin, i) = resize!(t.v, i-1) # -1 required because push! internally relies on length of p

function Base.insert!(t::TourWithOrigin, i, e) 
    insert!(t.v, i, e)
    return t
end

function Base.deleteat!(t::TourWithOrigin, i)
    deleteat!(t.v, i)
    return t 
end

function Base.pop!(t::TourWithOrigin)
     pop!(t.v)
     return t
end

indexset(t::TourWithOrigin) = eachindex(t)[2:end]

Base.copy(t::TourWithOrigin) = TourWithOrigin(t.origin, copy(t.v))