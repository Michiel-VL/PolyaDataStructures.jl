abstract type AbstractTour{T} <: AbstractVector{T} end

inedge(t::T, i) where {T <: AbstractTour} = i == 1 ? (t[end], t[i]) : (t[i-1],t[i]) 
outedge(t::T, i) where {T <: AbstractTour} = i == length(t) ? (t[i], t[1]) : (t[i],t[i+1])
inoutedges(t::T, i) where {T <: AbstractTour} = (i == 1 ? t[end] : t[i-1]), t[i], ((i == length(t)) ? t[1] : t[i+1])


function Δmapreduce(f::EdgeMapReduce, ::typeof(push!), e, t::AbstractTour)
    Δv = neutral(f)
    isempty(t) && return Δv 
    Δv = _mapinvreduce(f, Δv, last(t), first(t))
    Δv = _mapreduce(f, Δv, last(t), e)
    Δv = _mapreduce(f, Δv, e, first(t))
    return Δv
end
# TODO: Continue conversion to _mapreduce and _mapinvreduce

function Δmapreduce(f::EdgeMapReduce, ::typeof(pop!), t::AbstractTour)
    Δv = neutral(f)
    length(t) <= 1 && return Δv
    c_i, ci, ci_ = inoutedges(t, length(t))
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapinvreduce(f, Δv, ci, ci_)
    Δv = _mapreduce(f, Δv, c_i, ci_)
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(insert!), i, e, t::AbstractTour)
    Δv = neutral(f)
    isempty(t) && return Δv
    c_i, ci = inedge(t, i)
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapreduce(f, Δv, c_i, e)
    Δv = _mapreduce(f, Δv, e, ci)
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(deleteat!), i, t::AbstractTour)
    Δv = neutral(f)
    isempty(t) && return Δv
    c_i, ci, ci_ = inoutedges(t,i)
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapinvreduce(f, Δv, ci, ci_)
    Δv = _mapreduce(f, Δv, c_i, ci_)
    return Δv
end

# What goes out must be _invreduced. What goes in must be _outreduced

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

function Δmapreduce(f::EdgeMapReduce, ::typeof(swap!), i, j, t::AbstractTour)
    i,j = minmax(i,j)
    Δv = neutral(f)
    i == j && return Δv
    c_i, ci, ci_ = inoutedges(t,i)
    c_j, cj, cj_ = inoutedges(t,j)
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapinvreduce(f, Δv, ci, ci_)
    if (i + 1) == j
        Δv = _mapinvreduce(f, Δv, cj, cj_)
        Δv = _mapreduce(f, Δv, c_i, cj)
        Δv = _mapreduce(f, Δv, cj, ci)
        Δv = _mapreduce(f, Δv, ci, cj_)
        return Δv
    elseif (i == 1 && j == length(t))
        Δv = _mapinvreduce(f, Δv, c_j, cj)
        Δv = _mapreduce(f, Δv, c_j, ci)
        Δv = _mapreduce(f, Δv, ci, cj)
        Δv = _mapreduce(f, Δv, cj, ci_)
        return Δv
    else
        Δv = _mapinvreduce(f, Δv, c_j, cj)
        Δv = _mapinvreduce(f, Δv, cj, cj_)        
        Δv = _mapreduce(f, Δv, c_i, cj)
        Δv = _mapreduce(f, Δv, cj, ci_)
        Δv = _mapreduce(f, Δv, c_j, ci)
        Δv = _mapreduce(f, Δv, ci, cj_)
        return Δv
    end
    return Δv
end


#= Δmapreduce for twoopt!(s, i, j)
c_i - ci - ci_ ... c_j - cj - cj_
            =>
c_i - cj - c_j ... ci_ - ci - cj_
=#

function Δmapreduce(f::EdgeMapReduce, ::typeof(twoopt!), i, j, t::AbstractTour)
    i,j = minmax(i,j)
    Δv = neutral(f)
    (i == j || (i == 1 && j == length(t))) && return Δv
    c_i, ci = inedge(t,i)
    cj, cj_ = outedge(t,j)
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapinvreduce(f, Δv, cj, cj_)
    Δv = _mapreduce(f, Δv, c_i, cj)
    Δv = _mapreduce(f, Δv, ci, cj_)
    return Δv
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

function Δmapreduce(f::EdgeMapReduce, ::typeof(shift!), i, j, t::AbstractTour)
    Δv = neutral(f)
    ((i == j) || ((i == 1) && j == length(t)) || ((i == length(t)) && (j == 1))) && return Δv
    c_i, ci, ci_ = inoutedges(t, i)
    c_j, cj, cj_ = inoutedges(t, j)
    Δv = _mapinvreduce(f, Δv, c_i, ci)
    Δv = _mapinvreduce(f, Δv, ci, ci_)
    Δv = _mapreduce(f, Δv, c_i, ci_)
    if i < j
        Δv = _mapinvreduce(f, Δv, cj, cj_)
        Δv = _mapreduce(f, Δv, cj, ci)
        Δv = _mapreduce(f, Δv, ci, cj_)
    else
        Δv = _mapinvreduce(f, Δv, c_j, cj)
        Δv = _mapreduce(f, Δv, c_j, ci)
        Δv = _mapreduce(f, Δv, ci, cj)
    end
    return Δv
end