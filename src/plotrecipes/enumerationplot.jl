projectonmat((x,y), xn) = (y, xn - (x-1))


"""
    enumerationplot(Φ, dims; order = true, freecolor = :lightgray, usedcolor = :black, arrowcolor = :black, free)
    
# Example
julia> Φ = Iterators.product(1:5, 1:5); dims = (6,6);

julia> enumerationplot(Φ, dims)

"""
@userplot EnumerationPlot

@recipe function f(e::EnumerationPlot; order = true, freecolor = :lightgray, usedcolor = :black, arrowcolor = :black)
    Φ = collect(e.args[1])
    dims = e.args[2]
    xn, yn = dims
    # We want a matrix-style plot, so we flip the X- and Y-coordinates, mirror the x-axis and project the 
    # y-coordinates.
    Φ = projectonmat.(Φ, xn)
    X = first.(Φ)
    Y = last.(Φ)
    fontfamily := "Computer Modern"

    yticks := 1:yn, string.(reverse(1:yn))

    xmirror := true
    ymirror := false
    legend := false
    
    # Parameters in product of dims
    @series begin
        seriestype := :scatter
        markerstrokecolor --> freecolor
        markercolor --> freecolor
        marker := :circle
        G = Iterators.product(1:first(dims), 1:last(dims))
        first.(G), last.(G)
    end

    @series begin
        seriestype := :scatter
        color --> usedcolor
        markerstrokecolor --> usedcolor
        marker := :circle 
        X, Y
    end

    if order
        @series begin
            seriestype := :quiver
            color --> arrowcolor
            arrow --> :closed
            headlength --> 1
            headwidth --> 1
            quiver := get_arrows(X[1:end],Y[1:end])
            X[1:end-1], Y[1:end-1]
        end

    end

end

function get_arrows(X, Y)
    V = Vector{Tuple{eltype(X), eltype(Y)}}()
    P = collect(zip(X,Y))
    #@show P
    I = zip(P[1:end-1], P[2:end])
    for (i,(p1, p2)) in enumerate(I)
        push!(V, p2 .- p1)
    end
    #@show V
        #push!(V, (0,0))
    return V
end