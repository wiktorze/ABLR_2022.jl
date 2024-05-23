module ABLR_2022
using JLD2, MAT, Statistics, JuMP, Ipopt, PrettyTables, GLM, Plots, DataFrames, CSV
export compile
include("t1.jl")
include("t2.jl")
include("simulation.jl")
include("function_simulation_eval.jl")
include("t3.jl")
include("fig1.jl")
include("fig2.jl")

function compile()
    t1(latex = false)
    t2(latex = false)
    t3(latex = false)  
    fig1() 
    fig2()
end

end
