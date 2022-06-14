# Quadratic iterators

# Precedence to first var, precedence to lower values in each variable
colmajor(s) = product(indexset(s), indexset(s))
# Precedence to first var, precedence to lower values in first variable, higher in second variable
colmajor2(s) = product(indexset(s), Iterators.reverse(indexset(s)))
# Precedence to first var, precedence to higher values in first variable, lower in second variable
colmajor3(s) = product(Iterators.reverse(indexset(s)), indexset(s))
# Precedence to first var, precedence to higher values in both variables
colmajor4(s) = product(Iterators.reverse(indexset(s)), Iterators.reverse(indexset(s)))

# Precedence to second var, precedence to lower values in each variable
rowmajor(s) = orderedproduct((2,1), indexset(s), indexset(s))
# Precedence to second var, precedence to lower values in first var, higher in second var
rowmajor2(s) = orderedproduct((2,1), indexset(s), Iterators.reverse(indexset(s)))
# Precedence to second var, precedence to higher values in first var, lower in second var
rowmajor3(s) = orderedproduct((2,1), Iterators.reverse(indexset(s)), indexset(s))
# Precedence to second var, precedence to higher values in both variables
rowmajor4(s) = orderedproduct((2,1), Iterators.reverse(indexset(s)), Iterators.reverse(indexset(s)))



ltmi(s, T = ColMajor) = LowerTriMatrixIterator(T, length(indexset(s)))
ndmi(s, T = ColMajor) = NoDiagMatrixIterator(T, length(indexset(s)))


# Filters on quadratic iterators
uppertriangle(I) = Iterators.filter(ϕ -> ϕ[1] < ϕ[2], I)
lowertriangle(I) = Iterators.filter(ϕ -> ϕ[1] > ϕ[2], I)
nodiagonal(I) = Iterators.filter(ϕ -> ϕ[1] != ϕ[2], I)

evenrows(I) = Iterators.filter(ϕ -> iseven(ϕ[1]), I)
oddrows(I) = Iterators.filter(ϕ -> isodd(ϕ[1]), I)
evencols(I) = Iterators.filter(ϕ -> iseven(ϕ[2]), I)
oddcols(I) = Iterators.filter(ϕ -> isodd(ϕ[2]), I)

offset(s) = OffsetOrderIterator(colmajor(s), length(s))
offset2(s) = OffsetOrderIterator(colmajor2(s), length(s))
offset3(s) = OffsetOrderIterator(colmajor3(s), length(s))
offset4(s) = OffsetOrderIterator(colmajor4(s), length(s))
offset5(s) = OffsetOrderIterator(rowmajor(s), length(s))
offset6(s) = OffsetOrderIterator(rowmajor2(s), length(s))
offset7(s) = OffsetOrderIterator(rowmajor3(s), length(s))
offset8(s) = OffsetOrderIterator(rowmajor4(s), length(s))
