push!(LOAD_PATH, "../src/")
using Documenter, PolyaDataStructures

makedocs(
        modules = [PolyaDataStructures],
        sitename = "PolyaDataStructures.jl",
        pages = [
            "index.md"
        ]
)