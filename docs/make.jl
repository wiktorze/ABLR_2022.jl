using ABLR_2022
using Documenter

DocMeta.setdocmeta!(ABLR_2022, :DocTestSetup, :(using ABLR_2022); recursive=true)

makedocs(;
    modules=[ABLR_2022],
    authors="Wiktor Zieliński <120274586+wiktorze@users.noreply.github.com> and contributors",
    sitename="ABLR_2022.jl",
    format=Documenter.HTML(;
        canonical="https://wiktorze.github.io/ABLR_2022.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Results" => "results.md",
        "ReadMe" => "README.md",
    ],
)

deploydocs(;
    repo="github.com/wiktorze/ABLR_2022.jl",
    devbranch="main",
)
