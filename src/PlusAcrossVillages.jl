using Statistics
using CategoricalArrays
using StatFiles
using DataFrames
using StatsBase
using GLM
using JLD2
using FixedEffectModels

include("function_replication.jl")

# Load the data
df = DataFrame(StatFiles.load("1_Data/StataFiles/clean_data.dta"))
dropmissing!(df, [:hhid, :year])
df.logpoyield = log.(df.poyield)
df.year = convert.(Int, df.year)
df.hhid = convert.(Int, df.hhid)
df.village = convert.(Int, df.village)

# RUN FE PANEL REGRESSIONS ON TFP, TFPR, Land, Non-agricltural income
for var in [:logTFPQ, :logTFPR, :logL, :logIn]
    df = get_fe(df, var)
end

# COLLAPSE FE TO THE INDIVIDUAL LEVEL
collapsed_df = combine(groupby(df, :hhid)) do group
    DataFrame(
        logTFPQfe = safe_mean(group.logTFPQfe),
        logTFPRfe = safe_mean(group.logTFPRfe),
        logLfe = safe_mean(group.logLfe),
        logInfe = safe_mean(group.logInfe),
        village = safe_mean(group.village),
        logpoyield = safe_mean(group.logpoyield),  
        p_alpha = safe_mean(group.p_alpha),  
        p_gamma = safe_mean(group.p_gamma) 
    )
end

# TFP, TFPR, Land
for var in [:logTFPQfe, :logTFPRfe, :logLfe]
    collapsed_df = get_resid_nocon(collapsed_df, var, :logpoyield)
end

# Drop logTFPQfe, logTFPRfe, logLfe and rename _resid to logTFPQfe, logTFPRfe, logLfe
select!(collapsed_df, Not([:logTFPQfe, :logTFPRfe, :logLfe]))
rename!(collapsed_df, :logTFPQfe_resid => :logTFPQfe)
rename!(collapsed_df, :logTFPRfe_resid => :logTFPRfe)
rename!(collapsed_df, :logLfe_resid => :logLfe)

# REMOVE THE VILLAGE EFFECTS (to get baseline measures to ensure same sample)

# Run HH-specific FE from TFP panel regression on village dummies and extract the residuals
for var in [:logTFPQfe, :logTFPRfe, :logLfe, :logInfe]
    global collapsed_df = get_resid(collapsed_df, var, :village)
end

# fix the village 1402 as the base category
# for village 1402, :logTFPQfei = :logTFPQfe
collapsed_df.logTFPQfei[collapsed_df.village .== 1402] .= collapsed_df.logTFPQfe[collapsed_df.village .== 1402]
collapsed_df.logTFPRfei[collapsed_df.village .== 1402] .= collapsed_df.logTFPRfe[collapsed_df.village .== 1402]
collapsed_df.logLfei[collapsed_df.village .== 1402] .= collapsed_df.logLfe[collapsed_df.village .== 1402]

# Recover levels of variables from the logs
for var in [:logTFPQfei, :logTFPRfei, :logLfei, :logInfei]
    # Subtract the "log" from the name of the variable
    var_level = Symbol(string(var)[4:end])
    collapsed_df[!, var_level] = exp.(collapsed_df[!, var])
end

# Computer other
# gen Yfei = (TFPQfei/(TFPRfei^p_gamma))^(1/(1-p_gamma))
collapsed_df[!, :Yfei] = (collapsed_df[!, :TFPQfei] ./ (collapsed_df[!, :TFPRfei].^collapsed_df[!, :p_gamma])).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))
collapsed_df[!, :Iafei] = collapsed_df[!, :Yfei]
collapsed_df[!, :PHIfei] = (1 ./ collapsed_df[!, :TFPRfei]).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))

# and their logs
for var in [:Iafei, :PHIfei]
    collapsed_df[!, Symbol(string("log", var))] = log.(collapsed_df[!, var])
end

# Trim
collapsed_df.flag .= 0

for var in [:logIafei, :logInfei, :logPHIfei]
    collapsed_df = trim_df(collapsed_df, var, 0.5)
end

# drop logIafei logInfei logPHIfei Iafei Infei PHIfei logTFPRfei TFPRfei logTFPQfei TFPQfei Yfei
select!(collapsed_df, Not([:logIafei, :logInfei, :logPHIfei, :Iafei, :Infei, :PHIfei, :logTFPRfei, :TFPRfei, :logTFPQfei, :TFPQfei, :Yfei]))

for var in [:logLfe, :logInfe, :logTFPRfe, :logTFPQfe]
    collapsed_df[!, Symbol(string(var)[4:end])] = exp.(collapsed_df[!, var])
end

collapsed_df[!, :Yfe] = (collapsed_df[!, :TFPQfe] ./ (collapsed_df[!, :TFPRfe].^collapsed_df[!, :p_gamma])).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))
collapsed_df[!, :Iafe] = collapsed_df[!, :Yfe]
collapsed_df[!, :INfe] = collapsed_df[!, :Yfe] ./ collapsed_df[!, :TFPRfe]
collapsed_df[!, :Kfe] = (collapsed_df[!, :INfe] ./ (collapsed_df[!, :Lfe].^collapsed_df[!, :p_alpha])).^(1 ./ (1 .- collapsed_df[!, :p_alpha]))
collapsed_df[!, :Sfe] = collapsed_df[!, :TFPQfe].^(1 ./ (1 .- collapsed_df[!, :p_gamma]))
collapsed_df[!, :PHIfe] = (1 ./ collapsed_df[!, :TFPRfe]).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))

for var in [:Iafe, :Kfe, :Sfe, :Yfe, :PHIfe]
    collapsed_df[!, Symbol(string("log", var))] = log.(collapsed_df[!, var])
end

# EFFICIENCY GAINS ON FE BASELINE MEASURES + ACROSS VILLAGES 
K = sum(skipmissing(collapsed_df[!, :Kfe]))
L = sum(skipmissing(collapsed_df[!, :Lfe]))
S = sum(skipmissing(collapsed_df[!, :Sfe]))
Yact = sum(skipmissing(collapsed_df[!, :Yfe]))

# The maximum output this economy could attain given its resources
collapsed_df.Y_max = S.^(1 .- collapsed_df.p_gamma) .* (K.^(1 .- collapsed_df.p_alpha) .* L.^collapsed_df.p_alpha).^collapsed_df.p_gamma

collapsed_df.EffGain = collapsed_df.Y_max ./ Yact
EffGain = (collapsed_df.EffGain[1] - 1) * 100
# summarize EffGain variable
describe(collapsed_df.EffGain)

# ACROSS s EFFICIENCY GAINS 
for var in [:logLfe, :logKfe]
    collapsed_df = get_resid_nocon(collapsed_df, var, :logTFPQfe)
    collapsed_df[!, Symbol(string(var, "hat"))] = collapsed_df[!, var] .- collapsed_df[!, Symbol(string(var, "_resid"))]
end

# Reconstruct values of capital, land and output
collapsed_df.Kfehat = exp.(collapsed_df.logKfehat)
collapsed_df.Lfehat = exp.(collapsed_df.logLfehat)
collapsed_df.Yfehat = collapsed_df.TFPQfe .* (collapsed_df.Kfehat.^(1 .- collapsed_df.p_alpha) .* collapsed_df.Lfehat.^collapsed_df.p_alpha).^collapsed_df.p_gamma

# Aggregation
Khat = sum(skipmissing(collapsed_df[!, :Kfehat]))
Lhat = sum(skipmissing(collapsed_df[!, :Lfehat]))
Yhat = sum(skipmissing(collapsed_df[!, :Yfehat]))

collapsed_df.Y_maxhat = S.^(1 .- collapsed_df.p_gamma) .* (Khat.^(1 .- collapsed_df.p_alpha) .* Lhat.^collapsed_df.p_alpha).^collapsed_df.p_gamma

collapsed_df.EffGain_across_s = collapsed_df.Y_maxhat ./ Yhat
describe(collapsed_df.EffGain_across_s)
EffGain_across_s = (collapsed_df.EffGain_across_s[1] - 1) * 100

clean_df = dropmissing(collapsed_df, [:logIafe, :logInfe, :logPHIfe, :logTFPQfe, :logTFPRfe])
cov_IaIn = cor(clean_df[!, :logIafe], clean_df[!, :logInfe])
cov_IaPHI = cor(clean_df[!, :logIafe], clean_df[!, :logPHIfe])
cov_InPHI = cor(clean_df[!, :logInfe], clean_df[!, :logPHIfe])

# Compute STD of incomes and distortions
std_Ia = std(clean_df[!, :logIafe])
std_In = std(clean_df[!, :logInfe])
std_PHI = std(clean_df[!, :logPHIfe])

# Compute STD, Percentile Differences, and COV on TFP's and TFPR's
std_TFP = std(clean_df[!, :logTFPQfe])
logTFPQ_90_10 = quantile(clean_df[!, :logTFPQfe], 0.9) - quantile(clean_df[!, :logTFPQfe], 0.1)
logTFPQ_75_25 = quantile(clean_df[!, :logTFPQfe], 0.75) - quantile(clean_df[!, :logTFPQfe], 0.25)
std_TFPR = std(clean_df[!, :logTFPRfe])
logTFPR_90_10 = quantile(clean_df[!, :logTFPRfe], 0.9) - quantile(clean_df[!, :logTFPRfe], 0.1)
logTFPR_75_25 = quantile(clean_df[!, :logTFPRfe], 0.75) - quantile(clean_df[!, :logTFPRfe], 0.25)
cov_TFP_TFPR = cov(clean_df[!, :logTFPQfe], clean_df[!, :logTFPRfe])

# Compute Correlations for key variables
cor_TFPQ_TFPR = cor(clean_df[!, :logTFPQfe], clean_df[!, :logTFPRfe])
cor_Ia_PHI = cor(clean_df[!, :logIafe], clean_df[!, :logPHIfe])
cor_In_PHI = cor(clean_df[!, :logInfe], clean_df[!, :logPHIfe])
cor_Ia_In = cor(clean_df[!, :logIafe], clean_df[!, :logInfe])

# Extract percentile ratios from log percentile differences
TFPQ_90_10 = exp(logTFPQ_90_10)
TFPQ_75_25 = exp(logTFPQ_75_25)
TFPR_90_10 = exp(logTFPR_90_10)
TFPR_75_25 = exp(logTFPR_75_25)

# summarize std_TFP, TFPQ_90_10, TFPQ_75_25, std_TFPR, TFPR_90_10, TFPR_75_25
println(std_TFP)
println(std_TFPR)
describe([TFPQ_90_10, TFPQ_75_25, TFPR_90_10, TFPR_75_25])

# table 1 column 2
t1_col2 = [std_TFP; TFPQ_90_10; TFPQ_75_25; missing; std_TFPR; TFPR_90_10; TFPR_75_25; cor_TFPQ_TFPR]
t1_col2 = round.(t1_col2, digits = 2)
@save "2_Intermediate/PlusAcrossVillages/t1_col2.jld2" t1_col2

# table 2 row 2
t2_row2 = [round(EffGain, digits = 2); round(EffGain_across_s, digits = 2); ""]
@save "2_Intermediate/PlusAcrossVillages/t2_row2.jld2" t2_row2