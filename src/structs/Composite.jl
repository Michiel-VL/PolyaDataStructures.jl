struct RepresentationSequence{E, N, A <: AbstractArray{E,N}}
    subrepr::A
end

function Base.getindex(r::RepresentationSequence, i::Tuple)
    i1 = first(i)
    t = Base.tail(i)
    if length(t) == 1
        getindex(r.subrepr[i1], first(t))
    else
        getindex(r.subrepr[i1], t)
    end

end

Base.length(r::RepresentationSequence) = length(r.subrepr)
Base.getindex(r::RepresentationSequence, i) = getindex(r.subrepr, i)
Base.setindex!(r::RepresentationSequence, v, i::Tuple) = setindex!(r.subrepr[first(i)], v, Base.tail(i))
Base.setindex!(r::RepresentationSequence, v, i) = setindex!(r.subrepr, v, i)

Base.eachindex(r::RepresentationSequence) = eachindex(r.subrepr)
