abstract type MatrixIterator end

abstract type SquareMatrixIterator{D} <: MatrixIterator end

function Base.iterate(iter::SquareMatrixIterator, state = (1,first(iter)))
    idx, el = state
    idx == (length(iter)+1) && return nothing    
    nextel = next(iter, el)
    return el, (idx+1, nextel)
end

import Base.Iterators: Reverse
function Base.iterate(rev::Reverse{<:SquareMatrixIterator}, state = (1,first(rev)))
    idx, el = state
    idx == (length(rev) + 1) && return nothing
    nextel = next(rev, el)
    return el, (idx+1, nextel)
end

direction(::SquareMatrixIterator{D}) where {D} = D

Base.eltype(::SquareMatrixIterator) = Tuple{Int,Int}
Base.eltype(::Reverse{<:SquareMatrixIterator}) = Tuple{Int,Int}

Base.reverse(iter::SquareMatrixIterator) = Iterators.Reverse(iter)

Base.first(r::Reverse{<:SquareMatrixIterator}) = last(r.itr)
Base.last(r::Reverse{<:SquareMatrixIterator}) = first(r.itr)
next(r::Reverse{<:SquareMatrixIterator}, ϕ) = prev(r.itr, ϕ)
prev(r::Reverse{<:SquareMatrixIterator}, ϕ) = next(r.itr, ϕ)

dimension(r::Reverse{<:SquareMatrixIterator}) = dimension(r.itr)

increment(iter::SquareMatrixIterator, ϕ) = increment(direction(iter), ϕ)
decrement(iter::SquareMatrixIterator, ϕ) = decrement(direction(iter), ϕ)

requires_wrap(iter::SquareMatrixIterator, ϕ) = requires_wrap(iter, direction(iter), ϕ)
requires_backwrap(iter::SquareMatrixIterator, ϕ) = requires_backwrap(iter, direction(iter), ϕ)

wrap(iter, ϕ) = wrap(iter, direction(iter), ϕ)
backwrap(iter, ϕ) = backwrap(iter, direction(iter), ϕ)

function next(iter::SquareMatrixIterator, ϕ)
    ϕ == last(iter) && return (1,1)
    nextϕ = increment(iter, ϕ)
    return requires_wrap(iter, nextϕ) ? wrap(iter, nextϕ) : nextϕ
end
 
function prev(iter::SquareMatrixIterator, ϕ)
    ϕ == first(iter) && return (1,1)
    prevϕ = decrement(iter, ϕ)
    return requires_backwrap(iter, prevϕ) ? backwrap(iter, prevϕ) : prevϕ
end




"""
    I <: IteratorDirection

The iterator direction is used to define different types of iteration in a single iteration space.
"""
abstract type IteratorDirection end

struct ColMajor <: IteratorDirection end
struct RowMajor <: IteratorDirection end
struct DiagMajor <: IteratorDirection end

increment(::Type{ColMajor}, (i,j)) = (i+1,j)
increment(::Type{RowMajor}, (i,j)) = (i,j+1)
increment(::Type{DiagMajor}, (i,j)) = (i+1, j+1)

decrement(::Type{ColMajor}, (i,j)) = (i-1,j)
decrement(::Type{RowMajor}, (i,j)) = (i,j-1)
decrement(::Type{DiagMajor}, (i,j)) = (i-1,j-1)


"""
LowerTriMatrixIterator{D} <: SquareMatrixIterator{D}

Concrete type implementing iteration over the indices of a square matrix, only including the indices of cells below the diagonal.
"""
struct LowerTriMatrixIterator{S,D} <: SquareMatrixIterator{D}
    state::S
end

const LTMI = LowerTriMatrixIterator

dimension(it::LTMI{Int,D}) where {D} = it.state
dimension(it::LTMI{S,D}) where {S,D} = length(it.state)


LowerTriMatrixIterator(::Type{D}, n::S) where {S,D} = LowerTriMatrixIterator{S,D}(n)

# Iterator Interface

Base.length(iter::LTMI) = (dimension(iter)^2 - dimension(iter)) ÷ 2 
Base.size(iter::LTMI) = (length(iter),)

Base.first(::LTMI) = (2,1)
Base.first(iter::LTMI{S,DiagMajor}) where {S} = (dimension(iter), 1)
Base.last(iter::LTMI) = (dimension(iter), dimension(iter)-1)

requires_wrap(iter::LTMI, ::Type{ColMajor}, ϕ) = ϕ[1] == dimension(iter) +1
requires_wrap(::LTMI, ::Type{RowMajor}, ϕ) = ϕ[1] == ϕ[2]
requires_wrap(iter::LTMI, ::Type{DiagMajor}, ϕ) = ϕ[1] == dimension(iter) + 1

wrap(::LTMI, ::Type{ColMajor}, ϕ) = (ϕ[2]+2, ϕ[2]+1)
wrap(::LTMI, ::Type{RowMajor}, ϕ) = (ϕ[1]+1, 1)
wrap(iter::LTMI, ::Type{DiagMajor}, ϕ) = (dimension(iter)-ϕ[2]+1,1)

requires_backwrap(::LTMI, ::Type{ColMajor}, ϕ) = ϕ[1] == ϕ[2]
requires_backwrap(::LTMI, ::Type{RowMajor}, ϕ) = ϕ[2] == 0
requires_backwrap(::LTMI, ::Type{DiagMajor}, ϕ) = ϕ[2] == 0

backwrap(iter::LTMI, ::Type{ColMajor}, ϕ) = (dimension(iter), ϕ[2]-1)
backwrap(::LTMI, ::Type{RowMajor}, ϕ) = (ϕ[1]-1, ϕ[1]-2)
backwrap(iter::LTMI, ::Type{DiagMajor}, ϕ) = (dimension(iter), dimension(iter)-ϕ[1]-1)

function Base.rand(iter::LTMI)
    i = rand(1:dimension(iter))
    j = rand(1:dimension(iter))
    while j == i
        j = rand(1:dimension(iter))
    end
    if i > j
        return (i,j)
    else
        return (j,i)
    end
end



"""
    NoDiagMatrixIterator{D} <: SquareMatrixIterator{D}

Concrete type implementing iteration over the indices of a square matrix, excluding the indices on the diagonal.
"""
struct NoDiagMatrixIterator{S,D} <: SquareMatrixIterator{D}
    state::S
end

const NDMI = NoDiagMatrixIterator

NoDiagMatrixIterator(::Type{D}, n::S) where {S,D} = NoDiagMatrixIterator{S,D}(n)

dimension(iter::NDMI{Int,D}) where {D} = iter.state
dimension(iter::NDMI{S,D}) where {S,D} = length(iter.state)

Base.length(iter::NDMI) = dimension(iter)^2 - dimension(iter)
Base.size(iter::NDMI) = (length(iter),)

Base.first(::NDMI{S,ColMajor}) where S = (2, 1)
Base.first(::NDMI{S,RowMajor}) where S= (1, 2)
Base.first(iter::NDMI{S,DiagMajor}) where S = (dimension(iter), 1)

Base.last(iter::NDMI{S,ColMajor}) where S = (dimension(iter) - 1, dimension(iter))
Base.last(iter::NDMI{S,RowMajor}) where S = (dimension(iter), dimension(iter) - 1)
Base.last(iter::NDMI{S,DiagMajor}) where S = (1, dimension(iter))

function increment(iter::NDMI, ϕ)
    ϕ = increment(direction(iter), ϕ)
    ϕ[1] == ϕ[2] ? increment(iter, ϕ) : ϕ
end

function decrement(iter::NDMI, ϕ)
    ϕ = decrement(direction(iter), ϕ)
    ϕ[1] == ϕ[2] ? decrement(iter, ϕ) : ϕ
end

# NoDiagMatrixIterator requires a specific increment check in the case of landing on the diagonal.
function increment(iter::NDMI{S, DiagMajor}, ϕ) where S
    ϕ = increment(direction(iter), ϕ)
    ϕ[1] == ϕ[2] ? (ϕ[1], ϕ[2]-1) : ϕ
end

function decrement(iter::NDMI{S, DiagMajor}, ϕ) where S
    ϕ = decrement(direction(iter), ϕ)
    ϕ[1] == ϕ[2] ? (ϕ[1], ϕ[2]-1) : ϕ
end


"""
    requires_wrap(iter, ϕ)

Check if the iterator `iter` requires a wrap-around function to be applied to return a valid `ϕ`. If this returns true, the function `wrap(iter, ϕ)` is called. The backward version of `requires_wrap(iter, ϕ)` is `requires_wrap(iter, ϕ)`.
"""
requires_wrap(iter::NDMI, ::Type{ColMajor}, ϕ) = ϕ[1] == dimension(iter) + 1
requires_wrap(iter::NDMI, ::Type{RowMajor}, ϕ) = ϕ[2] == dimension(iter) + 1
requires_wrap(iter::NDMI, ::Type{DiagMajor}, ϕ) = ϕ[1] > ϕ[2] ? ϕ[1] == dimension(iter) + 1 : ϕ[2] == dimension(iter)+1

"""
    wrap(iter, ϕ)

Return the successor of ϕ through wrapping. How to wrap ϕ depends on the type of iterator. This function is only called when `requires_wrap(iter, ϕ)` returns true.
"""
wrap(::NDMI, ::Type{ColMajor}, ϕ) = (1, ϕ[2] + 1) 
wrap(::NDMI, ::Type{RowMajor}, ϕ) = (ϕ[1] + 1, 1)

function wrap(iter::NDMI, ::Type{DiagMajor}, ϕ) 
    if ϕ[1] == dimension(iter) + 1 && ϕ[2] == dimension(iter)
        return (1,2)
    end
    ϕ[1] < ϕ[2] ? (1, 2 + ϕ[2]-ϕ[1]) : (dimension(iter) - ϕ[2] + 1, 1)
end

"""
    requires_backwrap(iter, ϕ)

Check if the iterator `iter` requires a wrap-around function to be applied to return a valid `ϕ`. If this returns true, the function `backwrap(iter, ϕ)` is called. The forward version of `requires_backwrap(iter, ϕ)` is `requires_wrap(iter, ϕ)`.
"""
requires_backwrap(::NDMI, ::Type{ColMajor}, ϕ) = ϕ[1] == 0
requires_backwrap(::NDMI, ::Type{RowMajor}, ϕ) = ϕ[2] == 0
requires_backwrap(::NDMI, ::Type{DiagMajor}, ϕ) = ϕ[1] < ϕ[2] ? ϕ[1] == 0 : ϕ[2] == 0

"""
    wrap(iter, ϕ)

Return the successor of ϕ through wrapping. How to wrap ϕ depends on the type of iterator. This function is only called when `requires_wrap(iter, ϕ)` returns true.
"""
backwrap(iter::NDMI, ::Type{ColMajor}, ϕ) = (dimension(iter), ϕ[2] - 1) 
backwrap(iter::NDMI, ::Type{RowMajor}, ϕ) = (ϕ[1] - 1, dimension(iter))

function backwrap(iter::NDMI, ::Type{DiagMajor}, ϕ) 
    if ϕ[1] == 0
        if ϕ[2] == 1
            return (dimension(iter), dimension(iter)-1)
        else
            return ( dimension(iter)-ϕ[2] + 1 , dimension(iter))
        end
    end 
    if ϕ[2] == 0
        return (dimension(iter), dimension(iter)-ϕ[1]-1)
    end
    #ϕ[1] < ϕ[2] ? (1, 2 + ϕ[2]-ϕ[1]) : (dimension(iter) - ϕ[2] + 1, 1)
end


function Base.rand(iter::NDMI)
    i = rand(1:dimension(iter))
    j = i
    while j == i
        j = rand(1:dimension(iter))
    end
    return (i,j)
end

