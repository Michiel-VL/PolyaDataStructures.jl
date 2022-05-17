using Pkg
Pkg.activate("")
using PolyaDataStructures

# Apply an operator
A = rand(1:100, 10)
I = indexset(A)
println(A)

swap!(A, 3, 5)
println(A)

# Apply a sequence of operators
Ilt = Iterators.filter(ϕ -> ϕ[1] < ϕ[2] && iseven(ϕ[1]), I × I)
A = opseq!(A, shift!, Ilt)
println(A)
# Operator View

B = TwoOptView(A, 3, 8)
println(B)