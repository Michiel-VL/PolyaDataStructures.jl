# Auxiliary structure for faster testing
struct ΔTour{T,N,V}
    t::Tour{T, N, V}
    removed::Set{Tuple{Int,Int}}
    inserted::Set{Tuple{Int, Int}}
end
ΔTour(t::Tour) = ΔTour(t, Set{Tuple{eltype(t),eltype(t)}}(), Set{Tuple{eltype(t),eltype(t)}}())

tour(t::ΔTour) = t.t
inedge(t::ΔTour, i) = inedge(tour(t), i)
outedge(t::ΔTour, i) = outedge(tour(t), i)

# remove all the edges which occur in both removed and insert
# Take care with bidirectional edges: 
function simplify!(t::ΔTour)
    Φ = collect(t.removed)
    R = t.removed
    I = t.inserted
    for ϕ in Φ
        if ϕ ∈ I
            delete!(R, ϕ)
            delete!(I, ϕ)
        else
            if reverse(ϕ) ∈ I
                delete!(R, ϕ)
                delete!(I, reverse(ϕ))
            end
        end
    end
    return t
end


function swap!(t::ΔTour, i, j)
    i,j = minmax(i,j)
    c_i, ci, ci_ = inoutedges(t,i)
    c_j, cj, cj_ = inoutedges(t,j)

    push!(t.removed, (c_i, ci))
    push!(t.removed, (ci, ci_))
    
    push!(t.removed, (c_j, cj))
    push!(t.removed, (cj, cj_))

    push!(t.inserted, (c_i, cj))
    push!(t.inserted, (cj, ci_))

    push!(t.inserted, (c_j, ci))
    push!(t.inserted, (ci, cj_))
    swap!(t.t, i, j)
    return t
end


function twoopt!(t::ΔTour, i, j)
    i,j = minmax(i,j)
    c_i, ci = inedge(t,i)
    cj, cj_ = outedge(t,j)

    push!(t.removed, (c_i, ci))
    push!(t.removed, (cj, cj_))

    push!(t.inserted, (c_i, cj))
    push!(t.inserted, (ci, cj_))
    twoopt!(t.t, i, j)
    return t
end


function shift!(t::ΔTour, i, j)
    push!(t.removed, inedge(t, i))
    push!(t.removed, outedge(t, i))
    push!(t.inserted, (t.t[i-1], t.t[i+1]))
    if i < j
        push!(t.removed, outedge(t, j))
        push!(t.inserted, (t.t[j], t.t[i]))
        push!(t.inserted, (t.t[i], t.t[j+1]))
    else        
        push!(t.removed, outedge(t, j))
        push!(t.inserted, (t.t[j-1], t.t[i]))
        push!(t.inserted, (t.t[i], t.t[j]))
    end
    shift!(t.t, i, j)
    return t
end


function Base.show(io::IO, m::MIME"text/plain", t::ΔTour)
    show(io,m, tour(t))
    println(io, "Remove: ", join(t.removed, ","))
    println(io, "Insert: ", join(t.inserted, ","))
end