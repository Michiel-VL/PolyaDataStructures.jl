module PolyaDataStructures
    
    using TupleTools, RecipesBase

    include("operators/operators.jl")
    include("operators/operatorviews.jl")
    export swap!, twoopt!, shift!, opseq!, twooptseq, shiftseq, TwoOptView, ShiftView

    include("structs/Tour.jl")
    include("structs/TourWithOrigin.jl")
    export Tour, TourWithOrigin, EdgeIter, eachedge

    include("iterators/EdgeIter.jl")
    include("iterators/OrderedProductIterator.jl")
    include("iterators/DisjointUnionIterator.jl")
    include("iterators/OffsetOrderIterator.jl")
    include("iterators/QuadraticIterators.jl")
    export EdgeIter, 
            OrderedProductIterator,
            orderedproduct,
            DisjointUnionIterator, 
            OffsetOrderIterator,
            offsetorder,
            LowerTriMatrixIterator,
            NoDiagMatrixIterator,
            LTMI,
            NDMI,
            ColMajor,
            RowMajor,
            DiagMajor
            
    include("functions/EdgeMapReduce.jl")
    export EdgeMapReduce, Δmapreduce

    include("plotrecipes/enumerationplot.jl")
    export enumerationplot, enumerationplot!

    export indexset, ×

    function indexset(v::A, depth=1) where {A <: AbstractArray}
        depth == 1 && return eachindex(v)
        #depth == 1 && return DisjointUnionIterator(eachindex.(v))
        return DisjointUnionIterator(indexset.(v, depth-1))
    end

    function Base.getindex(s::A, i::Tuple) where {A <: AbstractArray}
        j = first(i)
        t = Base.tail(i)
        length(t) == 1 && return getindex(s[j], first(t))
        return getindex(s[j], t)
    end

    function Base.setindex!(s::A, v, i::Tuple) where {A <: AbstractArray}
        j = first(i)
        t = Base.tail(i)
        length(t) == 1 && return setindex!(s[j], v, first(t))
        return setindex!(s[j], v, t)

    end

    const × = Iterators.product


#Polya.objtype(::Type{EdgeMapReduce{F,R,V}}) where {F,R,V} = V 
#Polya.objtype(e::EdgeMapReduce) = objtype(typeof(e))

end # module

