using Test
using PolyaDataStructures

seq = [4,2,1,5,3,6,7]
t = Tour(copy(seq))
t2 = TourWithOrigin(copy(seq))

svec = [seq, t, t2]

@testset "Operators" begin
    correct = [4,2,3,5,1,6,7]
    foreach(s -> (@test swap!(s, 3, 5) == correct), svec)
    correct = [4,6,1,5,3,2,7]
    foreach(s -> (@test twoopt!(s, 2, 6) == correct), svec)
    correct = [4,6,1,3,2,7,5]
    foreach(s -> (@test shift!(s, 4, 7) == correct), svec)
    correct = [4,7,6,1,3,2,5]
    foreach(s -> (@test shift!(s, 6, 2) == correct), svec)
end

