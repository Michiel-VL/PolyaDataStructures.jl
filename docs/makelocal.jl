push!(LOAD_PATH, "../src/")
using Pkg
Pkg.activate("..")
ENV["GKSwstype"] = "100"
using Documenter, PolyaDataStructures

makedocs(modules = [PolyaDataStructures],
    sitename = "PolyaDataStructures.jl",
    pages = ["Home" => "index.md",
             "Datastructures" => "datastructures.md",
             "Higher Order Functions" => "ho_functions.md",
             "Operators" => "operators.md",
             "Iterators" => "iterators.md"])


deploydocs(
    repo = "github.com/Michiel-VL/PolyaDataStructures.jl.git"
)
