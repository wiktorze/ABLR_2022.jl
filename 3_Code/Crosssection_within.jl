using StatFiles
using DataFrames
using StatsBase
using GLM
using DataFramesMeta
using StatsModels
using FixedEffectModels
using JLD2

#LOAD CLEANED DATA ON AGRICULTURAL PRODUCTION, NON-AGRICULTURAL INCOME, AND LAND QUALITY
#df=CSV.read("./clean_data.csv",DataFrame)
df=DataFrame(load("1_Data/StataFiles/clean_data.dta"))
df=dropmissing(df,:TFP)

#convert values to Float64 as variables in .dta files are read as Float32
df[!,:logTFPQ]=convert.(Float64,df[!,:logTFPQ])
df[!,:logTFPR]=convert.(Float64,df[!,:logTFPR])
df[!,:logL]=convert.(Float64,df[!,:logL])
df[!,:p_gamma]=convert.(Float64,df[!,:p_gamma])
df[!,:p_alpha]=convert.(Float64,df[!,:p_alpha])
df[!,:village]=convert.(Int,df[!,:village])

#RUN REGRESSIONS OF TFP, TFPR, Land, on LQ and Extract the Residuals
ols1 = reg(df,@formula(logTFPQ~0+village); contrasts = Dict(:village => DummyCoding(base=1402)), save=true)
show(ols1)
df.logTFPQcs = residuals(ols1)

ols2 = reg(df,@formula(logTFPR~0+village); contrasts = Dict(:village => DummyCoding(base=1402)), save=true)
show(ols2)
df.logTFPRcs = residuals(ols2)

ols3 = reg(df,@formula(logL~0+village); contrasts = Dict(:village => DummyCoding(base=1402)), save=true)
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
	
	gd1=combine(gd,:EffGain => mean)
	eg=combine(gd1,:EffGain_mean => mean)
eg=100 .*(eg.EffGain_mean_mean.-1)
eg = round(eg[1], digits = 1)

save_object("2_Intermediate/crosssection_within/EffGain.jld2",eg)