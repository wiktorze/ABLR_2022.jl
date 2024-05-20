using StatFiles
using DataFrames
using StatsBase
using GLM
using DataFramesMeta
using CSV
using JLD2

#LOAD CLEANED DATA ON AGRICULTURAL PRODUCTION, NON-AGRICULTURAL INCOME, AND LAND QUALITY
#df=CSV.read("./clean_data.csv",DataFrame)

df=DataFrame(load("1_Data/StataFiles/clean_data.dta"))
df=dropmissing(df,:TFP)
df=dropmissing(df,:poyield)
transform!(df,:poyield => (x -> log.(x)) => :logpoyield)
# df[!,:poyield]=convert.(Float64,df[!,:poyield])
df=df[df.logpoyield .> -Inf, :]

#convert values to Float64 as variables in .dta files are read as Float32
df[!,:logTFPQ]=convert.(Float64,df[!,:logTFPQ])
df[!,:logTFPR]=convert.(Float64,df[!,:logTFPR])
df[!,:logL]=convert.(Float64,df[!,:logL])
df[!,:logpoyield]=convert.(Float64,df[!,:logpoyield])
df[!,:p_gamma]=convert.(Float64,df[!,:p_gamma])
df[!,:p_alpha]=convert.(Float64,df[!,:p_alpha])

#RUN REGRESSIONS OF TFP, TFPR, Land, on LQ and Extract the Residuals
ols1 = lm(@formula(logTFPQ ~ 0+logpoyield), df)
show(ols1)
df.logTFPQcs = residuals(ols1)

ols2 = lm(@formula(logTFPR ~ 0+logpoyield), df, dropcollinear=true)
show(ols2)
df.logTFPRcs = residuals(ols2)

ols3 = lm(@formula(logL ~ 0+logpoyield), df, dropcollinear=true)
show(ols3)
df.logLcs = residuals(ols3)


df.TFPRcs = exp.(df.logTFPRcs)
df.TFPQcs = exp.(df.logTFPQcs)

df.Ycs = (df.TFPQcs ./ (df.TFPRcs .^ df.p_gamma)) .^ (1 ./ (1 .- df.p_gamma))
df.Iacs = df.Ycs
df.PHIcs=(1 ./ df.TFPRcs) .^ (1 ./ (1 .- df.p_gamma))

df.logIacs = log.(df.Iacs)
df.logPHIcs = log.(df.PHIcs)

sort!(df, [:year, :TFPQcs])
	
	grouped_df=groupby(df,:year)
	for group in grouped_df
		drop_obs=round(Int,nrow(group) * 0.01)	
		value_end=nrow(group) - drop_obs
		group[drop_obs:value_end,:]
		
	end
# DROP OUTLIERS
	
	# df1=df1[drop_obs:nrow(df)-drop_obs,:]
	df1=vcat(grouped_df...)
	
	# COMPUTE VARIABLES OF INTEREST
	df1.Lcs=exp.(df1.logLcs)
	
	df1.INcs = df1.Ycs ./ df1.TFPRcs
	df1.Kcs = (df1.INcs ./ (df1.Lcs .^ df1.p_alpha)) .^ (1 ./ (1 .- df1.p_alpha))
	df1.Scs = df1.TFPQcs .^ (1 ./ (1 .- df1.p_gamma))
	
	df1.logKcs = log.(df1.Kcs)
	df1.logScs = log.(df1.Scs)
	df1.logYcs = log.(df1.Iacs)

	# EFFICIENCY GAINS
	sort!(df1,[:year])
	K = combine(groupby(df1,[:year]), :Kcs => sum => :K)
	L = combine(groupby(df1,[:year]), :Lcs => sum => :L)
	S = combine(groupby(df1,[:year]), :Scs => sum => :S)
	Yact = combine(groupby(df1,[:year]), :Ycs => sum => :Yact)
	df1 = leftjoin(df1,K,on=:year)
	df1 = leftjoin(df1,L,on=:year)
	df1 = leftjoin(df1,S,on=:year)
	df1 = leftjoin(df1,Yact,on=:year)

    #*The maximum output this economy could attain given its resource constraints.
	#Notes from Yann: had to use DataFramesMeta as DataFrames kept crashing on my end.
	gd = @groupby(df1,:year);
	@transform!(gd,:Y_max=(:S .^(1 .- :p_gamma) .* (:K.^(1 .-:p_alpha).* :L .^(:p_alpha)) .^ :p_gamma))
	@transform!(gd,:EffGain=:Y_max ./ :Yact)

#SUMMARY STATISTICS
#Generate statistics on TFPR 
year_local = [1993, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002]

logTFPR_90_10 = []
logTFPR_75_25 = []
TFPR_std = []
for year in year_local
    subset = df1[df1[:,:year] .== year, :logTFPRcs]
    push!(logTFPR_90_10, quantile(subset, 0.9) - quantile(subset, 0.1))
    push!(logTFPR_75_25, quantile(subset,0.75)-quantile(subset,0.25))
    push!(TFPR_std,std(subset))
end

# Compute correlation between TFPQcs and TFPRcs

TFPRstats = DataFrame(year=year_local,
    logTFPR_90_10=logTFPR_90_10,
    logTFPR_75_25=logTFPR_75_25,
    TFPR_std=TFPR_std)
println(TFPRstats)

#SUMMARY STATISTICS
	#Generate statistics on TFPQ
	
	logTFPQ_90_10 = []
	logTFPQ_75_25 = []
	TFPQ_std = []
	corr = []
	for year in year_local
        subset = df1[df1[:,:year] .== year, :logTFPQcs]
        push!(logTFPQ_90_10, quantile(subset, 0.9) - quantile(subset, 0.1))
		push!(logTFPQ_75_25, quantile(subset,0.75) - quantile(subset,0.25))
		push!(TFPQ_std,std(subset))
		subset_r = df1[df1[:,:year] .== year, :logTFPRcs]
		push!(corr,cor(subset,subset_r))
    end
	
	# Compute correlation between TFPQcs and TFPRcs
	corr = cor(df1[:,:logTFPQcs], df1[:,:logTFPRcs])
	TFPQstats = DataFrame(year=year_local,
		logTFPQ_90_10=logTFPQ_90_10,
		logTFPQ_75_25=logTFPQ_75_25,
		TFPQ_std=TFPQ_std,
		correlation=corr)
	println(TFPQstats)

    #*Extract percentile ratios from log percentile differences
	TFPQ_90_10 = mean(exp.(TFPQstats[!,:logTFPQ_90_10]))
	TFPQ_75_25 = mean(exp.(TFPQstats[!,:logTFPQ_75_25]))
	TFPR_90_10 = mean(exp.(TFPRstats[!,:logTFPR_90_10]))
	TFPR_75_25 = mean(exp.(TFPRstats[!,:logTFPR_75_25]))

	println(mean(df1.EffGain))
	println(mean(TFPQ_std))
	println(TFPQ_90_10)
	println(TFPQ_75_25)
	println(mean(TFPR_std))
	println(TFPR_90_10)
	println(TFPR_75_25)

# Table 1 Column 3
t1_col3 = [mean(TFPQ_std); TFPQ_90_10; TFPQ_75_25; missing; mean(TFPR_std); TFPR_90_10; TFPR_75_25; corr]
t1_col3 = round.(t1_col3, digits = 2)
@save "2_Intermediate/crosssection/t1_col3.jld2" t1_col3
# Table 2 Row 2
EffGain = round(100*(mean(df1.EffGain)-1), digits = 1)
@save "2_Intermediate/crosssection/t2_row2_cs.jld2" EffGain