abstract type AbstractTour{T,N, V} <: AbstractArray{T,N} end

inedge(t::T, i) where {T <: AbstractTour} = i == 1 ? (t[end], t[i]) : (t[i-1],t[i]) 
outedge(t::T, i) where {T <: AbstractTour} = i == length(t) ? (t[i], t[1]) : (t[i],t[i+1])
inoutedges(t::T, i) where {T <: AbstractTour} = (i == 1 ? t[end] : t[i-1]), t[i], ((i == length(t)) ? t[1] : t[i+1])

"""
    Tour{T,N,V}

Wrap around a struct with linear indexing to interpret it as a tour. The tour starts at the first index and finishes at the last. Calling `eachedge(t::Tour)` returns pairs `(s[i],s[i+1])` for each `i ∈ eachindex(t)`. If `i == n` then `i+1 = 0`. 
"""
struct Tour{T, N, V} <: AbstractTour{T,N,V}
    v::V

    function Tour(v::V) where {T,N, V <: AbstractArray{T,N}}
        return new{T, N, V}(v)
    end
end

function Base.show(io::IO, m::MIME"text/plain", t::Tour)
    print(io, length(t),"-element Tour{$(eltype(t))}: ")
    if length(t) > 20
        print(io, join(t[1:10], ","),",")
        println(io, join(t[end:end-10],","))
    else
        println(io, join(t, ","))
    end
end

Base.length(t::Tour) = length(t.v)
Base.size(t::Tour) = size(t.v)

Base.getindex(t::Tour, I...) = getindex(t.v, I...)
Base.setindex!(t::Tour, v, I...) = setindex!(t.v, v, I...)


"""
    eachedge(t::Tour)

returns an iterator over pairs of successive elements in `t`.
"""
eachedge(t::Tour) = EdgeIter(t)

inedge(t::Tour, i) = i == 1 ? (t[end], t[i]) : (t[i-1],t[i]) 
outedge(t::Tour, i) = i == length(t) ? (t[i], t[1]) : (t[i],t[i+1])
inoutedges(t::Tour, i) = (i == 1 ? t[end] : t[i-1]), t[i], ((i == length(t)) ? t[1] : t[i+1])

Base.copy(t::Tour) = Tour(copy(t.v))
Base.deepcopy(t::Tour) = Tour(deepcopy(t.v))
Base.resize!(t::Tour, i) = resize!(t.v, i)
Base.insert!(t::Tour, i, e) = begin insert!(t.v, i, e); t end
Base.deleteat!(t::Tour, i) = begin deleteat!(t.v, i); t end
Base.pop!(t::Tour) = begin pop!(t.v); t end