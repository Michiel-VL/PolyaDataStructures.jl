using TupleTools
import Base.Iterators: ProductIterator


"""
    struct OrderedProductIterator{I,N}
    
Datastructure encoding a sequence of the elements of the cartesian product of multiple iterators. The sequence is ordered based on the permutation-passed at construction, where the permutation indicates the order in which the iterators are incremented. The default is the same as the regular ProductIterator, which increments in a lexicographic manner, i.e. the last element first.
"""
struct OrderedProductIterator{I, N}
    iterator::ProductIterator{I}
    order::NTuple{N, Int}

    function OrderedProductIterator(iterators, order::Tuple)
        I = Iterators.product(TupleTools.permute(iterators, order)...)
        return new{typeof(I.iterators), length(order)}(I, order)
    end
end

orderedproduct(order, iterators...) = OrderedProductIterator(iterators, order)
oproduct(order, iterators...) = OrderedProductIterator(iterators, order)

Base.eltype(::Type{OrderedProductIterator{I,N}}) where {I,N} = eltype(ProductIterator{I})


Base.IteratorSize(::Type{OrderedProductIterator{I,N}}) where {I,N} = Base.HasShape{1}()

Base.size(iter::OrderedProductIterator) = (length(iter),)
Base.length(iter::OrderedProductIterator) = length(iterator(iter))

iterator(iter::OrderedProductIterator) = iter.iterator
order(iter::OrderedProductIterator) = iter.order

function Base.iterate(it::OrderedProductIterator)
    res = iterate(iterator(it))
    return TupleTools.permute(res[1], order(it)), res[2]
end

function Base.iterate(it::OrderedProductIterator, states)
    res = iterate(iterator(it), states)
    isnothing(res) && return nothing
    return TupleTools.permute(res[1], order(it)), last(res)
end