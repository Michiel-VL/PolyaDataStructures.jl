
#TODO Add Δmapreduce implementation fot AbstractArrays.
"""
eachedge(v::AbstractArray)

Return the set of edges belonging to v
"""
eachedge(v::AbstractArray) = ((v[i],v[i+1]) for i in 1:length(v)-1)

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
struct EdgeMapReduce{F, M, R, V}
    mf::F
    memo::M # if nothing, no memoization
    rf::R
end

Base.valtype(e::EdgeMapReduce) = valtype(typeof(e))
Base.valtype(::Type{EdgeMapReduce{F,M,R,V}}) where {F,M,R,V} = V

# M can be one of three things: Nothing, Matrix{V} or Dict{Tuple{I,I}, V}. The last case is the most general and can be used for objects with arbitrary indexes. 
# Note on the following note: it is not actually true as it is written now, as M is the memo and not the representation. However, the note holds (I think) for representations whose index-set is not well-defined. In this case the extra functionality is a necessity. Note: Unfortunately, providing delta-evaluation for arbitrary indices requires the inclusion of the necessary order-related mechanisms for the index sets. The delta-evaluations rely on the current position of an element and the position right before and after it. The predecessor and successor functions required to implement these mechanism are currently already implicitely present

# Initialization
EdgeMapReduce(f::F, r::R, ::Type{V}) where {F,R,V} = EdgeMapReduce{F,Nothing,R,V}(f, nothing, r)

# Note: this can be considered a bit of a hack: maybe it is possible 
function EdgeMapReduce(f::F, r::typeof(-), ::Type{V}) where {F,V}
    fnew = (-) ∘ f
    EdgeMapReduce{typeof(fnew), Nothing, typeof(+), V}(fnew, nothing, +)
end

function EdgeMapReduce(f::F, r, G) where {F}
    memo,V = _memoize(f, G)
    EdgeMapReduce{F,typeof(memo), typeof(r), V}(f, memo, r)
end

function EdgeMapReduce(f::F, ::typeof(-), G) where {F}
    memo,V = _memoize(f, G)
    EdgeMapReduce{F, typeof(memo), typeof(+), V}(f, .- memo, +)
end

function _memoize(f, G)
    J = eachindex(G)
    I = Iterators.product(J,J)
    V = typeof(f(first(I)...))
    memo = _memoize(f, I, G, typeof((J)))
    return memo, V
end

_memoize(f, I, G, ::Type{Base.OneTo{Int}}) = map(e -> f(G[e[1]], G[e[2]]), I)
_memoize(f, I, G, _) = Dict(map( e -> e => f(G[e[1]], G[e[2]]), I))



# basis
_map(f::EdgeMapReduce{F, Nothing, R, V}, i, j) where {F,R,V} = f.mf(i,j)
_map(f::EdgeMapReduce, i,j) = f.memo[i,j]

_reduce(f::EdgeMapReduce, v, Δv) = f.rf(v, Δv)
_invreduce(f::EdgeMapReduce, v, Δv) = inv(f)(v, Δv)

_mapreduce(f, v, i, j) = _reduce(f, v, _map(f, i, j))
_mapinvreduce(f, v, i, j) = _invreduce(f, v, _map(f, i, j))

neutral(t::EdgeMapReduce) = neutral(typeof(t))
neutral(::Type{EdgeMapReduce{F,M,R,V}}) where {F,M,R,V} = neutral(V, R)
neutral(T, ::Type{typeof(+)}) = zero(T)
neutral(T, ::Type{typeof(-)}) = zero(T)
neutral(T, ::Type{typeof(*)}) = one(T)
neutral(T, ::Type{typeof(/)}) = one(T)
neutral(T, ::Type{typeof(//)}) = one(T)
# TODO Check for which properties exactly inversion for delta holds. Work with warnings in case of Floating point issues. Rely on Rational where possible.

Base.inv(f::EdgeMapReduce) = inv(typeof(f))
Base.inv(::Type{EdgeMapReduce{F,M,R,V}}) where {F,M,R,V} = inv(R, V)
Base.inv(::Type{typeof(+)}, _) = -
Base.inv(::Type{typeof(-)}, _) = +
Base.inv(::Type{typeof(*)}, ::Type{Float64}) = /
Base.inv(::Type{typeof(*)}, ::Type{Int64}) = /
Base.inv(::Type{typeof(*)}, ::Type{Rational{Int}}) = //
Base.inv(::Type{typeof(÷)}, _) = *
Base.inv(::Type{typeof(/)}, _) = *
Base.inv(::Type{typeof(//)}, _) = *
# Running

function (f::EdgeMapReduce)(s)
    v = neutral(f)
    for e in eachedge(s)
        Δv = _map(f, e...)
        v = _reduce(f, v, Δv)
    end
    return v
end

#(f::EdgeMapReduce)(s, v, m) = _reduce(f, v, Δmapreduce(f, m, s))
(f::EdgeMapReduce)(s, v, m, ϕ...) = _reduce(f, v, Δmapreduce(f, m, ϕ..., s))


function Base.show(io::IO, ::MIME"text/plain", e::EdgeMapReduce{F,M,R,V}) where {F, M <: Nothing, R, V}
    println(io, "x ↦ mapreduce($(e.mf), $(e.rf), eachedge(x))")
end

function Base.show(io::IO, ::MIME"text/plain", e::EdgeMapReduce{F,M,R,V}) where {F, M <: Matrix,R, V}
    println(io, "x ↦ mapreduce($(e.mf), $(e.rf), eachedge(x)), with f memoized.")
end


function Δmapreduce(f::EdgeMapReduce, ::typeof(push!), e, t)
    Δv = neutral(f)
    isempty(t) && return Δv
    r = f.rf
    return r(Δv, _map(f, last(t), e))
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(pop!), t)
    Δv = neutral(f)
    length(t) <= 1 && return Δv
    Δv = _mapinvreduce(f, Δv, t[end-1], t[end])
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(insert!), i, e, t)
    Δv = neutral(f)
    isempty(t) && return Δv
    if i > 1
        Δv = _mapinvreduce(f, Δv, t[i-1], t[i])
        Δv = _mapreduce(f, Δv, t[i-1], e)     
    end
    Δv = _mapreduce(f, Δv, e, t[i])
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(swap!), i, j, t)
    i,j = minmax(i,j)
    Δv = neutral(f)
    i == j && return Δv
    Δv = _mapinvreduce(f, Δv, t[i], t[i+1])
    (i+1 != j) && (Δv = _mapinvreduce(f, Δv, t[j-1], t[j]))
    (i+1 != j) && (Δv = _mapreduce(f, Δv, t[j], t[i+1]))
    (i+1 != j) && (Δv = _mapreduce(f, Δv, t[j-1], t[i]))
    if i > 1
        Δv = _mapinvreduce(f, Δv, t[i-1], t[i])
        Δv = _mapreduce(f, Δv, t[i-1], t[j])
    end
    if j < length(t)
        Δv = _mapinvreduce(f, Δv, t[j], t[j+1])
        Δv = _mapreduce(f, Δv, t[i], t[j+1])
    end
    (i+1 == j) && (Δv = _mapreduce(f, Δv, t[j], t[i]))
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(twoopt!), i, j, t)
    i,j = minmax(i,j)
    Δv = neutral(f)
    (isempty(t) || i == j) && return Δv
    if i > 1
        Δv = _mapinvreduce(f, Δv, t[i-1], t[i])
        Δv = _mapreduce(f, Δv, t[i-1], t[j])
    end
    if j < length(t)
        Δv = _mapinvreduce(f, Δv, t[j], t[j+1])
        Δv = _mapreduce(f, Δv, t[i], t[j+1])
    end
    return Δv
end

function Δmapreduce(f::EdgeMapReduce, ::typeof(shift!), i, j, t)
    Δv = neutral(f)
    i == j && return Δv
    if i < j
        Δv = _mapinvreduce(f, Δv, t[i], t[i+1]) #outedge i
        Δv = _mapreduce(f, Δv, t[j], t[i])
        if i > 1
            Δv = _mapinvreduce(f, Δv, t[i-1], t[i]) # inedge i
            Δv = _mapreduce(f, Δv, t[i-1], t[i+1])  # add new edge over old i
        end
        if j < length(t)
            Δv = _mapinvreduce(f, Δv, t[j], t[j+1]) # outedge j, since that one is where i is inserted
            Δv = _mapreduce(f, Δv, t[i], t[j+1])
        end
    else
        Δv = _mapinvreduce(f, Δv, t[i-1], t[i])
        Δv = _mapreduce(f, Δv, t[i], t[j])
        if i < length(t)
            Δv = _mapinvreduce(f, Δv, t[i], t[i+1])
            Δv = _mapreduce(f, Δv, t[i-1], t[i+1])
        end
        if j > 1
            Δv = _mapinvreduce(f, Δv, t[j-1], t[j])
            Δv = _mapreduce(f, Δv, t[j-1],t[i])
        end
    end
    return Δv
end

#TODO: Implement a visualization of EMR: a tree visualizing the computational steps: The map and reduce are unrolled for the given sequence. If a memo is involved, visualize it as well. Idea: visualize the sequence of elements, with above it the resulting edges and the map a visualization of the corresponding value components. The value components are leaves in the tree visualization, with an extra leave serving as the initial value (according to its value)