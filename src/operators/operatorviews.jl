abstract type AbstractPermutationView{E, N, A <: AbstractArray{E,N}} <: AbstractArray{E, N} end

Base.length(v::P) where {P <: AbstractPermutationView} = length(v.v)
Base.size(v::P) where {P <: AbstractPermutationView} = size(v.v)
Base.IndexStyle(::Type{P}) where {E, N, A, P <: AbstractPermutationView{E, N, A}} = IndexStyle(A)

Base.getindex(v::P, i::Int) where {P <: AbstractPermutationView} = haschange(v, i) ? v.v[project(v, i)] : v.v[i]


"""
    PermOpView{E, N, A <: AbstractArray{E,N}, F,  Φ}
"""
struct PermOpView{E, N, A <: AbstractArray{E,N}, F, Φ} <: AbstractPermutationView{E, N, A}
    v::A
    f::F
    ϕ::Φ
    PermOpView(v::A, f::F, ϕ...) where {E, N, A <: AbstractArray{E, N}, F} = new{E, N, A, F, typeof(ϕ)}(v, f, ϕ)
end

apply!(v::PermOpView) = v.f(v.v, v.ϕ...)
apply!(v::PermOpView{E, N, P, F, Φ}) where {E, N, P <: AbstractPermutationView, F, Φ} = v.f(apply!(v.v), v.ϕ...)
apply!(v::PermOpView, f, ϕ...) = f(apply!(v), ϕ...)


const TwoOptView{E, N, A} = PermOpView{E, N, A, typeof(twoopt!), Tuple{Int,Int}}

TwoOptView(v, i, j) = PermOpView(v, twoopt!, minmax(i,j)...)
haschange(v::TwoOptView, i) = v.ϕ[1] <= i <= v.ϕ[2]
project(v::TwoOptView, i) = v.ϕ[2] - (i - v.ϕ[1])
twoopt!(v::PermOpView, i, j) = apply!(v, twoopt!, i, j)


const ShiftView{E, N, A} = PermOpView{E, N, A, typeof(shift!), Tuple{Int, Int}}

ShiftView(v, i, j) = PermOpView(v, shift!, i, j)
haschange(v::ShiftView, i) = v.ϕ[1] <= i <= v.ϕ[2] || v.ϕ[2] <= i <= v.ϕ[1]

function project(v::ShiftView, i)
    i == v.ϕ[2] && return v.ϕ[1]
    if v.ϕ[1] < v.ϕ[2]
        return i + 1
    elseif v.ϕ[1] > v.ϕ[2]
        return i - 1
    end
    return i
end

shift!(v::ShiftView, i, j) = apply!(v, shift!, i, j)