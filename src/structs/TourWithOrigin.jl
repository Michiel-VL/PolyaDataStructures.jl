
struct TourWithOrigin{T, N, V} <: AbstractTour{T,N,V}
    origin::T
    v::V
    TourWithOrigin(origin::T, v::V) where {T,N,V <: AbstractArray{T,N}} = new{T,N,V}(origin, v)
end

TourWithOrigin(v::Vector) = TourWithOrigin(first(v), v[2:end])


Base.length(t::TourWithOrigin) = length(t.v) + 1
Base.size(t::TourWithOrigin) = (length(t), )

Base.getindex(t::TourWithOrigin, i::Int) = i == 1 ? t.origin : getindex(t.v, i - 1)
Base.setindex!(t::TourWithOrigin, v, I...) = setindex!(t.v, v, I...)

eachedge(t::TourWithOrigin) = EdgeIter(t)