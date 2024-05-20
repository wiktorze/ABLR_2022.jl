# Estimate panel regression with household and year fixed effects
using Statistics
using CategoricalArrays
using StatFiles
using DataFrames
using StatsBase
using GLM
using JLD2
using FixedEffectModels
function get_fe(df, var)
    df_var = dropmissing(df, [Symbol(var)])
    formula = @eval(@formula($var ~ 1 + fe(year)))
    fe1 = reg(df_var, formula, save = :residuals)
    df_var[!, string(var, "_resid")] = fe1.residuals
    df_var[!, Symbol(string(var, "_hat"))] = df_var[!, Symbol(var)] .- df_var[!, Symbol(string(var, "_resid"))]
    var_hat_mean = combine(groupby(df_var, :hhid), Symbol(string(var, "_hat")) => mean)
    df_var = leftjoin(df_var, var_hat_mean, on = :hhid)
    var_mean = combine(groupby(df_var, :hhid), Symbol(var) => mean)
    df_var = leftjoin(df_var, var_mean, on = :hhid)
    df_var[!, Symbol(string(var, "fe"))] = df_var[!, Symbol(string(var, "_mean"))] .- df_var[!, Symbol(string(var, "_hat_mean"))]
    df = leftjoin(df, df_var[:, [:hhid, :year, Symbol(string(var, "fe"))]], on = [:hhid, :year])
    return df
end

# Define a function to calculate mean with handling missing values
function safe_mean(x)
    if sum(ismissing, x) == length(x)
        missing
    else
        mean(skipmissing(x))
    end
end

# Run HH-specific FE from TFP panel regression on village dummies and extract the residuals
function get_resid(df, dependent_var, fe_var)
    # Use clean df to run the regression without missing values
    df1 = dropmissing(df, [dependent_var, fe_var])
    # Formula using @eval for variable names
    formula = @eval(@formula($(dependent_var) ~ 0 + $(fe_var)))

    # Fit the fixed effects model
    model = reg(df1, formula, save = true) 

    # Extract residuals
    resid = model.residuals

    # Join the residuals
    df_resid = hcat(df1, resid)[!, [:hhid, :x1]]

    df = leftjoin(df, df_resid, on = :hhid)

    # If the fe_var is missing, set x1 to missing
    df.x1[df[!, fe_var] .=== missing] .= missing

    # Rename the residuals
    rename!(df, :x1 => Symbol(string(dependent_var, "i")))
    return df
end

# Flag the data with missing values
function trim_df(df, v, pc) # removes bottom and top pc%
    df1 = dropmissing(df, [v])
    df2 = df[ismissing.(df[!, v]), :]
    vars_pc_lower_value = percentile(df1[!, v], pc)
    vars_pc_upper_value = percentile(df1[!, v], 100-pc)
    # flag variables above or below the threshold
    df1[!, :flag] = (df1[!, v] .<= vars_pc_lower_value) .| (df1[!, v] .>= vars_pc_upper_value)
    df = vcat(df1, df2)
    return df
end

# Get resid with no constant
function get_resid_nocon(df, dependent_var, fe_var)
    # Use clean df to run the regression without missing values or Infinite values
    df1 = dropmissing(df, [dependent_var, fe_var])
    df1 = df1[isfinite.(df1[!, fe_var]), :]
    # Formula using @eval for variable names
    formula = @eval(@formula($(dependent_var) ~ 0 + $(fe_var)))

    # Fit the fixed effects model
    model = reg(df1, formula, save = true) 

    # Extract residuals
    resid = model.residuals

    # Join the residuals
    df_resid = hcat(df1, resid)[!, [:hhid, :x1]]

    df = leftjoin(df, df_resid, on = :hhid)

    # If the fe_var is missing, set x1 to missing
    df.x1[df[!, fe_var] .=== missing] .= missing

    # Rename the residuals
    rename!(df, :x1 => Symbol(string(dependent_var, "_resid")))
    return df
end

function lag_v(year, x)
    result = missings(eltype(x), length(x))
    length(x) < 2 && return result
    last = first(year)
    for i in 2:length(x)
        current = year[i]
        if last == 1993
            current - last == 2 && (result[i] = x[i-1])
        else
        current-last == 1 && (result[i] = x[i-1])
        end
        last = current
    end
    return result
end