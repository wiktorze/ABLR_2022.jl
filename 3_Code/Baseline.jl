
using Statistics
using CategoricalArrays
using StatFiles
using DataFrames
using StatsBase
using GLM
using JLD2
using FixedEffectModels
using CSV

include("function_replication.jl")

# Load the data
df = DataFrame(StatFiles.load("1_Data/StataFiles/clean_data.dta"))
# Save as csv
#CSV.write("1_Data/StataFiles/clean_data.csv", df)
dropmissing!(df, [:hhid, :year])
df.year = convert.(Int, df.year)
df.hhid = convert.(Int, df.hhid)
df.village = convert.(Int, df.village)

sort!(df, [:hhid, :year])


for var in [:logTFPQ, :logTFPR, :logL, :logIn]
    df = get_fe(df, var)
end

# Collapse to hh-level
# Group by hhid and calculate the mean of specified variables
collapsed_df = combine(groupby(df, :hhid)) do group
    DataFrame(
        logTFPQfe = safe_mean(group.logTFPQfe),
        logTFPRfe = safe_mean(group.logTFPRfe),
        logLfe = safe_mean(group.logLfe),
        logInfe = safe_mean(group.logInfe),
        village = first(group.village),  # Assuming village is constant within each hhid
        p_alpha = first(group.p_alpha),  # Assuming p_alpha is constant within each hhid
        p_gamma = first(group.p_gamma)   # Assuming p_gamma is constant within each hhid
    )
end

# show descriptive statistics
describe(collapsed_df, :min, :mean, :max)

# Run HH-specific FE from TFP panel regression on village dummies and extract the residuals
# turn village to Categorical variable
collapsed_df.village = CategoricalArray(collapsed_df.village)

# Step 2
# Run HH-specific FE from TFP panel regression on village dummies and extract the residuals
#dropmissing!(collapsed_df, [:logTFPQfe_mean, :village])
for var in [:logTFPQfe, :logTFPRfe, :logLfe, :logInfe]
    global collapsed_df = get_resid(collapsed_df, var, :village)
end
# fix the village 1402 as the base category
# for village 1402, :logTFPQfei = :logTFPQfe
collapsed_df.logTFPQfei[collapsed_df.village .== 1402] .= collapsed_df.logTFPQfe[collapsed_df.village .== 1402]
collapsed_df.logTFPRfei[collapsed_df.village .== 1402] .= collapsed_df.logTFPRfe[collapsed_df.village .== 1402]
collapsed_df.logLfei[collapsed_df.village .== 1402] .= collapsed_df.logLfe[collapsed_df.village .== 1402]

# Compute variables of interest

# Recover levels of variables from the logs
for var in [:logTFPQfei, :logTFPRfei, :logLfei, :logInfei]
    # Subtract the "log" from the name of the variable
    var_level = Symbol(string(var)[4:end])
    collapsed_df[!, var_level] = exp.(collapsed_df[!, var])
end

# Computer other
collapsed_df[!, :Yfei] = (collapsed_df[!, :TFPQfei] ./ (collapsed_df[!, :TFPRfei].^collapsed_df[!, :p_gamma])).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))
collapsed_df[!, :Iafei] = collapsed_df[!, :Yfei]
collapsed_df[!, :INfei] = collapsed_df[!, :Yfei] ./ collapsed_df[!, :TFPRfei]
collapsed_df[!, :Kfei] = (collapsed_df[!, :INfei] ./ (collapsed_df[!, :Lfei].^collapsed_df[!, :p_alpha])).^(1 ./ (1 .- collapsed_df[!, :p_alpha]))
collapsed_df[!, :Sfei] = collapsed_df[!, :TFPQfei].^(1 ./ (1 .- collapsed_df[!, :p_gamma]))
collapsed_df[!, :PHIfei] = (1 ./ collapsed_df[!, :TFPRfei]).^(1 ./ (1 .- collapsed_df[!, :p_gamma]))

# and their logs
for var in [:Iafei, :Kfei, :Sfei, :Yfei, :PHIfei]
    collapsed_df[!, Symbol(string("log", var))] = log.(collapsed_df[!, var])
end

# Drop observations falling into the top and bottom 0.5% of the distribution 
# we have to avoid comparison on missing values
summary = describe(collapsed_df, :min, :mean, :max)
collapsed_df.flag .= 0

for var in [:logIafei, :logInfei, :logPHIfei]
    collapsed_df = trim_df(collapsed_df, var, 0.5)
end

# drop if flag == 1
collapsed_df = filter(row -> row.flag == 0, collapsed_df)
# somehow, 12,519 observations here, 12,443 in Stata


# Aggregation
K = sum(skipmissing(collapsed_df[!, :Kfei]))
L = sum(skipmissing(collapsed_df[!, :Lfei]))
S = sum(skipmissing(collapsed_df[!, :Sfei]))
Yact = sum(skipmissing(collapsed_df[!, :Yfei]))

# Max output under these inputs
collapsed_df.Y_max = S.^(1 .- collapsed_df.p_gamma) .* (K.^(1 .- collapsed_df.p_alpha) .* L.^collapsed_df.p_alpha).^collapsed_df.p_gamma
collapsed_df.TFPReff = collapsed_df.Y_max ./ (K.^(1 .- collapsed_df.p_alpha) .* L.^collapsed_df.p_alpha)

# Efficiency gain
collapsed_df.EffGain = collapsed_df.Y_max ./ Yact
EffGain = (collapsed_df.EffGain[1] - 1)*100

# ACROSS s EFFICIENCY GAINS 
for var in [:logLfei, :logKfei]
    collapsed_df = get_resid_nocon(collapsed_df, var, :logTFPQfei)
    collapsed_df[!, Symbol(string(var, "hat"))] = collapsed_df[!, var] .- collapsed_df[!, Symbol(string(var, "_resid"))]
end

# Reconstruct values of capital, land and output
collapsed_df.Kfeihat = exp.(collapsed_df.logKfeihat)
collapsed_df.Lfeihat = exp.(collapsed_df.logLfeihat)
collapsed_df.Yfeihat = collapsed_df.TFPQfei .* (collapsed_df.Kfeihat.^(1 .- collapsed_df.p_alpha) .* collapsed_df.Lfeihat.^collapsed_df.p_alpha).^collapsed_df.p_gamma

# Aggregation
Khat = sum(skipmissing(collapsed_df[!, :Kfeihat]))
Lhat = sum(skipmissing(collapsed_df[!, :Lfeihat]))
Yhat = sum(skipmissing(collapsed_df[!, :Yfeihat]))

# Max output under these inputs
collapsed_df.Y_maxhat = S.^(1 .- collapsed_df.p_gamma) .* (Khat.^(1 .- collapsed_df.p_alpha) .* Lhat.^collapsed_df.p_alpha).^collapsed_df.p_gamma

# gen EffGain_across_s=Y_maxhat/Yhat
collapsed_df.EffGain_across_s = collapsed_df.Y_maxhat ./ Yhat
EffGain_across_s = (collapsed_df.EffGain_across_s[1] - 1)*100

# DECOMPOSITION OF EFFICIENCY GAINS INTO OUTPUT WEDGE AND CAPITAL/LAND WEDGE
# Average products	
collapsed_df.APKi = collapsed_df.Yfei ./ collapsed_df.Kfei
collapsed_df.APLi = collapsed_df.Yfei ./ collapsed_df.Lfei

#Marginal products
collapsed_df.MPKi = (1 .- collapsed_df.p_alpha) .* collapsed_df.p_gamma .* collapsed_df.APKi
collapsed_df.MPLi = collapsed_df.p_alpha .* collapsed_df.p_gamma .* collapsed_df.APLi

# Normalize
collapsed_df.q .= 1
collapsed_df.r .= 1

# Wedges from FOC
collapsed_df.wedgeLi = collapsed_df.MPLi ./ collapsed_df.q
collapsed_df.wedgeKi = collapsed_df.MPKi ./ collapsed_df.r

# TFPR from factor wedges
collapsed_df.TFPRi = (collapsed_df.wedgeLi.^collapsed_df.p_alpha) .* (collapsed_df.wedgeKi.^(1 .- collapsed_df.p_alpha)) .* ((collapsed_df.q ./ (collapsed_df.p_alpha .* collapsed_df.p_gamma)).^collapsed_df.p_alpha) .* ((collapsed_df.r ./ (collapsed_df.p_gamma .* (1 .- collapsed_df.p_alpha))).^(1 .- collapsed_df.p_alpha))

collapsed_df.wedgeYi = 1 ./ collapsed_df.TFPRi

# Land input demand

collapsed_df.distLSi = collapsed_df.Sfei .* (collapsed_df.wedgeYi.^(1 ./ (1 .- collapsed_df.p_gamma)))
SUMdistLSi = sum(skipmissing(collapsed_df[!, :distLSi]))
collapsed_df.Li = collapsed_df.distLSi .* L ./ SUMdistLSi

# Capital input demand

collapsed_df.distKSi = collapsed_df.Sfei .* (collapsed_df.wedgeYi.^(1 ./ (1 .- collapsed_df.p_gamma)))
SUMdistKSi = sum(skipmissing(collapsed_df[!, :distKSi]))
collapsed_df.Ki = collapsed_df.distKSi .* K ./ SUMdistKSi

# Output supply
collapsed_df.Yi = (collapsed_df.Sfei.^(1 .- collapsed_df.p_gamma)) .* (collapsed_df.Li.^(collapsed_df.p_alpha .* collapsed_df.p_gamma)) .* (collapsed_df.Ki.^(collapsed_df.p_gamma .* (1 .- collapsed_df.p_alpha)))
AggOutput = sum(skipmissing(collapsed_df[!, :Yi]))

# Implied Output Gains
collapsed_df.OutputGains = collapsed_df.Y_max ./ AggOutput
OutputGains = (collapsed_df.OutputGains[1] - 1)*100

# Compute the efficient allocation used for graphing purposes only.
collapsed_df.k_eff = collapsed_df.Sfei ./ S .* K
collapsed_df.l_eff = collapsed_df.Sfei ./ S .* L
collapsed_df.y_eff = collapsed_df.Sfei.^(1 .- collapsed_df.p_gamma) .* (collapsed_df.k_eff.^(1 .- collapsed_df.p_alpha) .* collapsed_df.l_eff.^collapsed_df.p_alpha).^collapsed_df.p_gamma
collapsed_df.logkeff = log.(collapsed_df.k_eff)
collapsed_df.logleff = log.(collapsed_df.l_eff)
collapsed_df.logyeff = log.(collapsed_df.y_eff)
# save collapsed_df
CSV.write("2_Intermediate/baseline/collapsed_df.csv", collapsed_df)

### SUMMARY STATISTICS ###
# Compute contemporary COV on incomes and distortions
clean_df = dropmissing(collapsed_df, [:logIafei, :logInfei, :logPHIfei])
cov_IaIn = cov(clean_df[!, :logIafei], clean_df[!, :logInfei])
cov_IaPHI = cov(clean_df[!, :logIafei], clean_df[!, :logPHIfei])
cov_InPHI = cov(clean_df[!, :logInfei], clean_df[!, :logPHIfei])

# Compute STD of incomes and distortions
std_Ia = std(clean_df[!, :logIafei])
std_In = std(clean_df[!, :logInfei])
std_PHI = std(clean_df[!, :logPHIfei])

# Compute STD, Percentile Differences, and COV on TFP's and TFPR's
std_TFP = std(clean_df[!, :logTFPQfei])
logTFPQ_90_10 = quantile(clean_df[!, :logTFPQfei], 0.9) - quantile(clean_df[!, :logTFPQfei], 0.1)
logTFPQ_75_25 = quantile(clean_df[!, :logTFPQfei], 0.75) - quantile(clean_df[!, :logTFPQfei], 0.25)
std_TFPR = std(clean_df[!, :logTFPRfei])
logTFPR_90_10 = quantile(clean_df[!, :logTFPRfei], 0.9) - quantile(clean_df[!, :logTFPRfei], 0.1)
logTFPR_75_25 = quantile(clean_df[!, :logTFPRfei], 0.75) - quantile(clean_df[!, :logTFPRfei], 0.25)
cov_TFP_TFPR = cov(clean_df[!, :logTFPQfei], clean_df[!, :logTFPRfei])

# Compute Correlations for key variables
cor_TFPQ_TFPR = cor(clean_df[!, :logTFPQfei], clean_df[!, :logTFPRfei])
cor_Ia_PHI = cor(clean_df[!, :logIafei], clean_df[!, :logPHIfei])
cor_In_PHI = cor(clean_df[!, :logInfei], clean_df[!, :logPHIfei])
cor_Ia_In = cor(clean_df[!, :logIafei], clean_df[!, :logInfei])

# Extract percentile ratios from log percentile differences
TFPQ_90_10 = exp(logTFPQ_90_10)
TFPQ_75_25 = exp(logTFPQ_75_25)
TFPR_90_10 = exp(logTFPR_90_10)
TFPR_75_25 = exp(logTFPR_75_25)

# Table 1 column 1 (except BKR)
t1_col1 = [std_TFP; TFPQ_90_10; TFPQ_75_25; missing; std_TFPR; TFPR_90_10; TFPR_75_25; cor_TFPQ_TFPR]
t1_col1 = round.(t1_col1, digits = 2)
@save "2_Intermediate/baseline/t1_col1.jld2" t1_col1

# Table 2 row 1
t2_row1 = [EffGain; EffGain_across_s; OutputGains]
t2_row1 = round.(t2_row1, digits = 1)
@save "2_Intermediate/baseline/t2_row1.jld2" t2_row1