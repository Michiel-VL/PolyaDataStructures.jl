module PolyaDataStructures
    

    include("operators/operators.jl")
    include("operators/operatorviews.jl")
    export swap!, twoopt!, shift!, opseq!, twooptseq, shiftseq, TwoOptView, ShiftView

    include("structs/Tour.jl")
    include("structs/TourWithOrigin.jl")
    include("structs/Composite.jl")
    export Tour, TourWithOrigin, EdgeIter, eachedge, RepresentationSequence

    include("iterators/EdgeIter.jl")
    include("iterators/DisjointUnionIterator.jl")
    export EdgeIter, DisjointUnionIterator
            
    include("functions/EdgeMapReduce.jl")
    export EdgeMapReduce, Δmapreduce

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

    const × = Iterators.product


#Polya.objtype(::Type{EdgeMapReduce{F,R,V}}) where {F,R,V} = V 
#Polya.objtype(e::EdgeMapReduce) = objtype(typeof(e))

end # module
