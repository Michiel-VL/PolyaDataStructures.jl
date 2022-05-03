# Disjoint Union Iterator
"""
    struct DisjointUnionIterator{I,E}

Iterates over the disjoint union of a set of collections. 

## Example
julia> 
"""
struct DisjointUnionIterator{I,E}
    iters::I

    function DisjointUnionIterator(iters) 
        E = Tuple{Int,eltype(first(iters))}
        return new{typeof(iters),E}(iters)
    end
end

DisjointUnionIterator(iterators...) = DisjointUnionIterator(iterators)

iterators(D::DisjointUnionIterator) = D.iters
#Base.HasShape(::Type{DisjointUnionIterator}) = Iterators.HasShape{1}()
Base.size(D::DisjointUnionIterator) = (sum( s -> *(s...), size.(iterators(D))),)
Base.length(D::DisjointUnionIterator) = first(size(D))
Base.eltype(::DisjointUnionIterator{I,E}) where {I,E} = E
Base.eltype(::Type{DisjointUnionIterator{I,E}}) where {I,E} = Tuple{Int,eltype(eltype(I))}

function Base.iterate(D::DisjointUnionIterator)
    iters = iterators(D)
    ret = iterate(first(iters))
    isnothing(ret) && return nothing
    return (1, ret[1]),(1,ret[2])
end

function Base.iterate(D::DisjointUnionIterator, state)
    i, istate = state
    iters = iterators(D)
    ret = iterate(iters[i], istate)
    while isnothing(ret)
        i == length(iters) && return nothing
        i += 1
        ret = iterate(iters[i])
    end
    return (i, ret[1]),(i,ret[2])
end


function Base.iterate(D::Iterators.Reverse{DisjointUnionIterator{I,E}}) where {I,E}
    iters = iterators(D.itr)
    ret = iterate(last(iters))
    isnothing(ret) && return nothing
    return (length(iters), ret[1]),(1,ret[2])
end

function Base.iterate(D::Iterators.Reverse{DisjointUnionIterator{I,E}}, state) where {I,E}
    i, istate = state
    iters = iterators(D.itr)
    ret = iterate(iters[i], istate)
    while isnothing(ret)
        i == length(iters) && return nothing
        i -= 1
        ret = iterate(iters[i])
    end
    return (i, ret[1]),(i,ret[2])
end

function Base.show(io::IO, ::MIME"text/plain" , d::DisjointUnionIterator)
    print(io, join(iterators(d), " ⊔ "))
end