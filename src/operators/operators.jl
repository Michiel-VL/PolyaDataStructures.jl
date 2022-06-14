
"""
    swap!(s, i, j)

Swap the entries in `s` at indices `i` and `j` of position.
"""
function swap!(s, i, j)
    s[i],s[j] = s[j],s[i]
    return s
end

swap(s, i, j) = swap!(copy(s), i, j)

"""
    twoopt!(s, i, j)

Invert sequence in `s` between indices `i` and `j`. Assumes `i` < `j`.
"""
function twoopt!(s, i, j)
    ub = abs(j-i) ÷ 2
    i,j = minmax(i,j)
    r = i < j ? (0:ub) : (ub:-1:0)
    for k in r
        swap!(s, i+k, j-k)
    end
    return s
end

twoopt(s, i, j) = twoopt!(copy(s), i, j)

"""
    shift!(s, i, j)

Shift entry at index `i` in `s` to index `j`.
"""
function shift!(s, i, j)
    r = i < j ? (i:j-1) : (i-1):-1:j
    for k in r
        swap!(s,k, k+1)
    end
    return s
end

shift(s, i, j) = shift!(copy(s), i, j)

"""
    opseq!(s, f, Φ)

Serial application of the operation `f(s,ϕ)` for ϕ ∈ Φ, where Φ is ordered.
"""
opseq!(s, f, Φ) = begin foreach(ϕ -> f(s,ϕ...), Φ); return s end
opseq!(s, i, f, Φ) = begin foreach(ϕ -> f(s, (i, ϕ[1]), (i, ϕ[2])), Φ); return s end

twoopt2!(s, i, j) = opseq!(s, swap!, twooptseq(i,j))
shift2!(s, i, j) = opseq!(s, swap!, shiftseq(i, j))

function twooptseq(i,j)
    ub = abs(j-i) ÷ 2
    i, j = minmax(i,j)
    return Iterators.zip(i:i+ub, j:-1:j-ub)
end

function shiftseq(i,j)
    if i < j
        return Iterators.zip(i:j-1, i+1:j)
    else
        return Iterators.zip(i:-1:j+1, i-1:-1:j)
    end
end
