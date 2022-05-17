push!(LOAD_PATH, "../src/")
using Documenter, PolyaDataStructures

makedocs(modules = [PolyaDataStructures],
    sitename = "PolyaDataStructures.jl",
    pages = ["Home" => "index.md",
             "Datastructures" => "datastructures.md",
             "Iterators" => "iterators.md"])