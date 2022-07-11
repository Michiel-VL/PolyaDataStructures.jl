module PolyaDataStructures
    
    using TupleTools, RecipesBase

    include("operators/operators.jl")
    include("operators/operatorviews.jl")
    export swap!, swap, twoopt!, twoopt, shift!, shift, opseq!, twooptseq, shiftseq, TwoOptView, ShiftView

    include("functions/EdgeMapReduce.jl")
    export EdgeMapReduce, EdgeMapReduceMemoized, Δmapreduce

    include("structs/AbstractTour.jl")
    include("structs/Tour.jl")
    include("structs/TourWithOrigin.jl")
    export Tour, TourWithOrigin, EdgeIter, eachedge

    include("iterators/EdgeIter.jl")
    include("iterators/OrderedProductIterator.jl")
    include("iterators/DisjointUnionIterator.jl")
    include("iterators/OffsetOrderIterator.jl")
    include("iterators/QuadraticIterators.jl")
    include("iterators/predefined_iterators.jl")
    export EdgeIter, 
            OrderedProductIterator,
            orderedproduct,
            oproduct,
            DisjointUnionIterator, 
            OffsetOrderIterator,
            offsetorder,
            LowerTriMatrixIterator,
            NoDiagMatrixIterator,
            LTMI,
            NDMI,
            ColMajor,
            RowMajor,
            DiagMajor,
            colmajor,colmajor2,colmajor3,colmajor4,
            rowmajor,rowmajor2,rowmajor3,rowmajor4,
            ltmi,ndmi,
            uppertriangle,lowertriangle,nodiagonal,
            evenrows,evencols,oddrows,oddcols,
            offset,offset2,offset3,offset4,
            offset5,offset6,offset7,offset8,
            predefined_iterators

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

