using StatFiles
using DataFrames
using StatsBase
using GLM
using DataFramesMeta
using PanelDataTools
using CategoricalArrays
using Statistics
using StatsModels
using FixedEffectModels
using JLD2

#LOAD CLEANED DATA ON AGRICULTURAL PRODUCTION, NON-AGRICULTURAL INCOME, AND LAND QUALITY
df=DataFrame(load("1_Data/StataFiles/clean_data.dta"))
df=dropmissing(df,:TFP)
df=dropmissing(df,:output)
df=dropmissing(df,:land)
df=dropmissing(df,:capital)

#convert all variables subsequently used to Float64
df[!,:output]=convert.(Float64,df[!,:output])
df[!,:capital]=convert.(Float64,df[!,:capital])
df[!,:logL]=convert.(Float64,df[!,:logL])

#Log-output
df.logY = log.(df.output)
df.logK = log.(df.capital)
df.logI = df.p_alpha .* df.logL .+ (1 .- df.p_alpha) .* df.logK

#sort observations according to household id and year
sort!(df, [:hhid,:year])

#create a panel by setting the id and t variables. Panel consists of a cross-section of HHs (farms) and a time series of years
paneldf!(df,:hhid,:year)

#create change in log-output between any current and once lagged values
lag!(df,:logY,name="L1logY")
lag!(df,:logL,name="L1logL")
lag!(df,:logK,name="L1logK")
lag!(df,:logI,name="L1logI")

#because one lag takes only difference between consecutive years for 1993-1995, we need to take a second lag
lag!(df,:logY,2,name="L2logY")
lag!(df,:logL,2,name="L2logL")
lag!(df,:logK,2,name="L2logK")
lag!(df,:logI,2,name="L2logI")

df.DlogY = df.logY .- df.L1logY
df.DlogL = df.logL .- df.L1logL
df.DlogK = df.logK .- df.L1logK
df.DlogI = df.logI .- df.L1logI
df.DlogY[df.year .== 1995] .= df.logY[df.year.==1995] .- df.L2logY[df.year.==1995]
df.DlogL[df.year .== 1995] .= df.logL[df.year.==1995] .- df.L2logL[df.year.==1995]
df.DlogK[df.year .== 1995] .= df.logK[df.year.==1995] .- df.L2logK[df.year.==1995]
df.DlogI[df.year .== 1995] .= df.logI[df.year.==1995] .- df.L2logI[df.year.==1995]

sort!(df, [:hhid,:year])

#compute average of logTFPR over current and previous period using the current permanent measure of s and averages of inputs over the two years
df1=DataFrame(load("1_Data/StataFiles/TFP&TFPRcrosssection.dta"))
# Save as csv
#CSV.write("1_Data/StataFiles/TFP&TFPRcrosssection.csv", df1)
df_merge=leftjoin(df,df1,on=[:hhid,:year])
sort!(df_merge,[:hhid,:year])
df_merge.TFPRavg = log.(df_merge.TFPRcs)
df_merge.year_cutoff .= 0
df_merge.year_cutoff[(convert.(Int, df_merge.year) .>= 1993) .& (convert.(Int, df_merge.year) .<= 1998)] .= 1
#BKR regressions
df_merge.TFPRmeasure = df_merge.TFPRavg
df_merge=dropmissing(df_merge,:TFPRmeasure)
df_merge=df_merge[df_merge.TFPRmeasure .>0 ,:]
df_merge[!,:TFPRmeasure]=convert.(Float64,df_merge[!,:TFPRmeasure])
df_merge=dropmissing(df_merge,:DlogY)
df_merge[!,:DlogI]=convert.(Float64,df_merge[!,:DlogI])
#df_merge.year=string.(df_merge.year)
#df_merge.village=string.(df_merge.village)
df_merge[!,:DlogY]=convert.(Float64,df_merge[!,:DlogY])

df_merge.logTFPRmeasure .= NaN
df_merge.logTFPRmeasure = log.(df_merge.TFPRmeasure)
df_merge.interact = df_merge.logTFPRmeasure .* df_merge.DlogI


#Regression with village and year dummies + clustering of SE at the village level
df_merge[!,:village]=convert.(Int,df_merge[!,:village])
df_merge[!,:year]=convert.(Int,df_merge[!,:year])
df_merge.year = categorical(df_merge.year)
df_merge.village = categorical(df_merge.village)

ols1 = reg(df_merge,@formula(DlogY ~ 0+logTFPRmeasure+DlogI+interact+fe(year)+fe(village)),Vcov.cluster(:village))

#Compute the standard errors using the Delta method
coef_interact = coef(ols1)[3]
coef_DlogI = coef(ols1)[2]
vcov_matrix = vcov(ols1)[2:3, 2:3]
grad_g = [-coef_interact / coef_DlogI^2, 1 / coef_DlogI]
std_error = sqrt(grad_g' * vcov_matrix * grad_g)

#Compute the confidence interval
coef_null=1+(coef_interact/coef_DlogI)
coef_logTFPRmeasure=coef(ols1)[1]
lci=coef_null - (1.96 * std_error)
hci=coef_null + (1.96 * std_error)
# round
coef_null = round(coef_null, digits=2)
std_error = round(std_error, digits=3)
lci = round(lci, digits=2)
hci = round(hci, digits=2)

t1_col3 = [string(coef_null); "($std_error)"; "[$lci, $hci]"]

@save "2_Intermediate/BKRcrosssection/t1_col3_BKR.jld2" t1_col3