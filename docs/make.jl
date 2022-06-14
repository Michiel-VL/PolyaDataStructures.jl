ENV["GKSwstype"] = "100"
using Documenter, PolyaDataStructures

makedocs(modules = [PolyaDataStructures],
    sitename = "PolyaDataStructures.jl",
    pages = ["Home" => "index.md",
             "Datastructures" => "datastructures.md",
             "Operators" => "operators.md",
             "Iterators" => "iterators.md"])


deploydocs(
    repo = "github.com/Michiel-VL/PolyaDataStructures.jl.git"
)
