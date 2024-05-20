using JLD2, MAT, Statistics, JuMP, Ipopt, PrettyTables, GLM, Plots, DataFrames, CSV

### Compiling Table 1
include("t1.jl")
t1(latex = false)
#Compiling Table 2
include("t2.jl")
t2(latex = false)

# Compiling Table 3
include("simulation.jl")
include("function_simulation_eval.jl")
include("t3.jl")
t3(latex = false)

# Figure 1
include("fig1.jl")
fig1()

# Figure 2
include("fig2.jl")
fig2()