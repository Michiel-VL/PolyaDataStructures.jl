
#TODO Add Δmapreduce implementation fot AbstractArrays.

"""
    EdgeMapReduce

Struct providing implementation of `fun(v) = mapreduce(f, op, eachedge(v))]`. The implementation as a struct enables delta-evaluation as used in various common objective functions for combinatorial optimization problems.

# Usage
```julia
julia> emr = EdgeMapReduce(dist, +, 0)
 x → mapreduce(dist, +, eachedge(x); init=0)

julia> emr([(0,0), (0,1), (1,1)])
2
```
"""
struct EdgeMapReduce{F, R, V}
    mapf::F
    redop::R
    neutral_el::V
end

#TODO: Reimplement EdgeMapReduce Δmapreduce-functions to work with the inverse of operators
neutralel(e::EdgeMapReduce) = e.neutral_el 

@inline _map(e::EdgeMapReduce{F,R,V}, i, j) where {F <: AbstractArray, R, V}= e.mapf[i,j]
@inline _map(e::EdgeMapReduce, i, j) = e.mapf(i,j)
@inline _reduce(e::EdgeMapReduce, v, Δv) = e.redop(v, Δv)

invop(e::EdgeMapReduce{F,typeof(+),V}) where {F,V} = -
invop(e::EdgeMapReduce{F, typeof(-), V}) where {F,V} = +
invop(e::EdgeMapReduce{F, typeof(*), Integer}) where {F} = ÷
invop(e::EdgeMapReduce{F, typeof(*), Real}) where {F} = /
invop(e::EdgeMapReduce{F, typeof(÷), Integer}) where {F} = *
invop(e::EdgeMapReduce{F, typeof(/), V}) where {F,V} = *

function Base.show(io::IO, ::MIME"text/plain", e::EdgeMapReduce{F,R,V}) where {F <: Function,R,V}
    println(io, "x ↦ mapreduce($(e.mapf), $(e.redop), eachedge(x); init=$(e.neutral_el))")
end

function Base.show(io::IO, ::MIME"text/plain", e::EdgeMapReduce{F,R,V}) where {F <: AbstractMatrix,R,V}
    println(io, "x ↦ mapreduce(f, $(e.redop), eachedge(x); init=$(e.neutral_el)), with f memoized.")
end

function (obj::EdgeMapReduce)(t)
    E = eachedge(t)
    v = neutralel(obj)
    for e in E
        v = _reduce(obj, v , _map(obj, e...))
    end
    return v
end

(obj::EdgeMapReduce)(t, v, f, ϕ...) = v + Δmapreduce(obj, f, ϕ..., t)

function Δmapreduce(obj::EdgeMapReduce, ::typeof(push!), e, t)
    isempty(t) && return neutralel(obj)
    _map(obj, last(t), e)
end

function Δmapreduce(obj::EdgeMapReduce, ::typeof(push!), e, t::Tour)
   isempty(t) && return neutralel(obj) 
    return -_map(obj, last(t), first(t)) + _map(obj, last(t), e) + _map(obj, e, first(t))
end

function Δmapreduce(obj::EdgeMapReduce, ::typeof(pop!), t)
    length(t) <= 1 && return neutralel(obj)
    return -_map(obj, t[end-1], t[end])
end

function Δmapreduce(obj::EdgeMapReduce, ::typeof(pop!), t::Tour)
    n = length(t)
    n <= 1 && return neutralel(obj)
    c_i, ci, ci_ = inoutedges(t, n)
    return - _map(obj, c_i, ci) - _map(obj, ci, ci_) + _map(obj, c_i, ci_)
end

function Δmapreduce(obj::EdgeMapReduce, ::typeof(insert!), i, e, t::Tour)
    isempty(t) && return neutralel(obj)
    c_i, ci = inedge(t, i)
    return - _map(obj, c_i, ci) + _map(obj, c_i, e) + _map(obj, e, ci)
end

function Δmapreduce(obj::EdgeMapReduce, ::typeof(deleteat!), i, t::Tour)
    c_i, ci, ci_ = inoutedges(t,i)
    return - _map(obj, c_i, ci) - _map(obj, ci, ci_) + _map(obj, c_i, ci_)
end

#= Δmapreduce for swap!(s, i, j)
c_i - ci - ci_ ... c_j - cj - cj_ 
            => 
c_i - cj - ci_ ... c_j - ci - cj_  

case i + 1 == j

c_i - ci - cj - cj_
        =>
c_i - cj - ci - cj_ 

case i == 1 && j == n

c_j - cj - ci - ci_
        =>
c_j - ci - cj - ci_ 

=#  

function Δmapreduce(obj::EdgeMapReduce, ::typeof(swap!), i, j, t::Tour)
    i == j && return neutralel(obj)
    i,j = minmax(i,j)
    c_i, ci, ci_ = inoutedges(t,i)
    c_j, cj, cj_ = inoutedges(t,j)
    Δv = - _map(obj, c_i, ci) - _map(obj, ci, ci_)
    if (i + 1) == j
        return Δv - _map(obj, cj, cj_) + _map(obj, c_i, cj) + _map(obj, cj, ci) + _map(obj, ci, cj_)
    elseif (i == 1 && j == length(t))
        return Δv - _map(obj, c_j, cj) + _map(obj, c_j, ci) + _map(obj, ci, cj) + _map(obj, cj, ci_)
    else
        return Δv - _map(obj, c_j, cj) - _map(obj, cj, cj_) + _map(obj, c_i, cj) + _map(obj, cj, ci_) + _map(obj, c_j, ci) + _map(obj, ci, cj_)
    end
    return Δv
end


#= Δmapreduce for twoopt!(s, i, j)
c_i - ci - ci_ ... c_j - cj - cj_
            =>
c_i - cj - c_j ... ci_ - ci - cj_
=#

function Δmapreduce(obj::EdgeMapReduce, ::typeof(twoopt!), i, j, t::Tour)
    i,j = minmax(i,j)
    (i == j || (i == 1 && j == length(t))) && return neutralel(obj)
    c_i, ci = inedge(t,i)
    cj, cj_ = outedge(t,j)
    return - _map(obj, c_i, ci) - _map(obj, cj, cj_) + _map(obj, c_i, cj) + _map(obj, ci, cj_)
end

#=
c_i - ci - ci_ ... c_j - cj - cj_
            =>
c_i - ci_      ... cj - ci - cj_

c_j - cj - cj_ ... c_i - ci -cj_
            =>
c_j - ci - cj  ... c_i - ci_

cn - c1 - c2   ... c_n - cn - c1
            =>
c
=#

function Δmapreduce(obj::EdgeMapReduce, ::typeof(shift!), i, j, t::Tour)
    ((i == j) || ((i == 1) && j == length(t)) || ((i == length(t)) && (j == 1))) && return neutralel(obj)
    c_i, ci, ci_ = inoutedges(t, i)
    c_j, cj, cj_ = inoutedges(t, j)
    Δv = - _map(obj, c_i, ci) - _map(obj, ci, ci_) + _map(obj, c_i, ci_)
    if i < j
        Δv = Δv - _map(obj, cj, cj_)  + _map(obj, cj, ci) + _map(obj, ci, cj_)
    else
        Δv = Δv - _map(obj, c_j, cj) + _map(obj, c_j, ci) + _map(obj, ci, cj)
    end
    return Δv
end