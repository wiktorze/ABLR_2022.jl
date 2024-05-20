using Statistics
using CategoricalArrays
using StatFiles
using DataFrames
using StatsBase
using GLM
using CovarianceMatrices
using FixedEffectModels
include("function_replication.jl")

# Load the data
df = DataFrame(StatFiles.load("1_Data/StataFiles/clean_data.dta"))
dropmissing!(df, [:hhid, :year])
dropmissing!(df, [:output, :land, :capital])

# Log-output
df.logY = log.(df.output)
# Log-capital input
df.logK = log.(df.capital)
# Log-input bundle
df.logI = df.p_alpha .* df.logL + (1 .- df.p_alpha) .* df.logK

for var in [:logY, :logL, :logK, :logI]
    transform!(groupby(df, :hhid), [:year, var] => lag_v => Symbol(string(var, "_lag")))
end

for var in [:logY, :logL, :logK, :logI]
    df[!, Symbol(string("D", var))] = df[!, var] - df[!, Symbol(string(var, "_lag"))]
end

baseline = DataFrame(StatFiles.load("1_Data/StataFiles/TFP&TFPRbaseline.dta"))
# Save as csv
#CSV.write("1_Data/StataFiles/TFP&TFPRbaseline.csv", baseline)
dropmissing!(baseline, [:hhid])
# Merge the two dataframes
df_merged = outerjoin(df, baseline, on=:hhid)

df_merged.TFPRavg = log.(df_merged.TFPRfei)

### BKR regression
df_merged.logTFPRmeasure = log.(clamp.(df_merged.TFPRavg, 0.0, Inf))

df_merged.interact = df_merged.logTFPRmeasure .* df_merged.DlogI

df_merged = dropmissing!(df_merged, [:DlogY, :logTFPRmeasure, :DlogI, :interact, :year, :village])
# skip Inf and -Inf in [:DlogY, :logTFPRmeasure, :DlogI, :interact, :year, :village]
df_merged = df_merged[.!(isinf.(df_merged.DlogY) .| isinf.(df_merged.logTFPRmeasure) .| isinf.(df_merged.DlogI) .| isinf.(df_merged.interact) .| isinf.(df_merged.year) .| isinf.(df_merged.village)), :]

# turn year and village into Categorical
df_merged.year = CategoricalArray(df_merged.year)
df_merged.village = CategoricalArray(df_merged.village)
# Regression
df_merged[!, :DlogY] = Float64.(df_merged[!, :DlogY])
df_merged[!, :DlogI] = Float64.(df_merged[!, :DlogI])
df_merged[!, :logTFPRmeasure] = Float64.(df_merged[!, :logTFPRmeasure])
df_merged[!, :interact] = Float64.(df_merged[!, :interact])


ols = reg(df_merged, @formula(DlogY ~ 0 + logTFPRmeasure + DlogI + interact + fe(year) + fe(village)), contrasts = Dict(:year => DummyCoding(base = 1995.0)), save = true, Vcov.cluster(:village))

# Extract coefficients
coef_interact = coef(ols)[3]
coef_DlogI = coef(ols)[2]

# Estimate
lambda = 1 + coef_interact / coef_DlogI

# Extract the covariance matrix
vcov_matrix = vcov(ols)[2:3, 2:3]

# Calculate the gradient of the function 'g'
grad_g = [-coef_interact / coef_DlogI^2, 1 / coef_DlogI]

# Standard error calculation - delta method
std_error = sqrt(grad_g' * vcov_matrix * grad_g)

# Estimate
print(lambda / coef_DlogI)
print(std_error)

# confidence interval
lci=lambda - (1.96 * std_error)
hci=lambda + (1.96 * std_error)

# round
lambda = round(lambda, digits=2)
std_error = round(std_error, digits=3)
lci = round(lci, digits=2)
hci = round(hci, digits=2)

t1_col1_BKR = [string(lambda); "($std_error)"; "[$lci, $hci]"]
# Save the results
@save "2_Intermediate/BKRbaseline/t1_col1_BKR.jld2" t1_col1_BKR