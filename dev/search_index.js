var documenterSearchIndex = {"docs":
[{"location":"results/#Results-of-the-Replication-Exercise","page":"Results","title":"Results of the Replication Exercise","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":"In this section, we present the all replicated results displayed in the main text of the paper. ","category":"page"},{"location":"results/#Table-1:-Mismeasurement-in-Productivity-and-Distortions","page":"Results","title":"Table 1: Mismeasurement in Productivity and Distortions","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":" Household Farm Village Cross-Section average\nFarm TFP   \nSTD(log) 0.37 0.68 0.81\np90/p10 2.2 4.53 5.93\np75/p25 1.48 2.09 2.36\nFarm   \nSTD(log) 0.49 0.84 1.0\np90/p10 3.15 7.55 10.33\np75/p25 1.77 2.75 3.28\nCORR (logTFP, logTFPR) 0.91 0.89 0.9\nBKR λ 1.0 0.96 0.9\nStandard error (0.025) (0.039) (0.023)\n95% confidence interval [0.95, 1.05] [0.88, 1.03] [0.86, 0.95]","category":"page"},{"location":"results/#Table-2:-Efficiency-Gains-from-Reallocation","page":"Results","title":"Table 2: Efficiency Gains from Reallocation","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":" Total Across s missalocation Land distortion Cross-section average\nEliminating misallocation across households    \nwithin villages 24.9 13.9 14.0 71.4\n+ across villages 57.46 27.56 - 118.5","category":"page"},{"location":"results/#Table-3:-The-Effects-of-Correlated-Distortions","page":"Results","title":"Table 3: The Effects of Correlated Distortions","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":" Benchmark Economy No Correlated Distortions\nReal Agricultural Productivity (Ya=Na) 1.0 2.96\nShare of Employment in Agriculture (Na) (%) 0.46 0.16\nTFP in Agriculture (TFP_a) 1.0 1.67\nReal Non-Agricultural Productivity (Yn/Nn) 1.0 0.78\nAverage Ability in Agriculture (Za/Na) 1.0 2.34\nAverage Ability in Non-Agriculture (Zn/Nn) 1.0 0.78\nReal GDP per Worker (Y=N) 1.0 1.18\nSTD of log-farm TFP 0.56 0.39\nSTD of log-farm TFPR 0.48 0.14\nCORR of log-(farm TFP, farm TFPR) 0.97 0.44\nCORR of log-(agr. ability, non-agr. ability) 0.15 0.49\nCORR of log-(agr. income, non-agr. income) 0.03 0.4","category":"page"},{"location":"results/#Figure-1:-Factor-Allocations-by-Farm-Productivity","page":"Results","title":"Figure 1: Factor Allocations by Farm Productivity","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":"(Image: Replication of Figure 1)","category":"page"},{"location":"results/#Figure-2:-Farm-specifc-Distortions-and-Productivity","page":"Results","title":"Figure 2: Farm-specifc Distortions and Productivity","text":"","category":"section"},{"location":"results/","page":"Results","title":"Results","text":"(Image: Replication of Figure 2)","category":"page"},{"location":"README/#Overview","page":"ReadMe","title":"Overview","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"This README describes the replication procedure for Adamapoulos et al. (2022). We translate code from the following files in the original replication package to Julia. Subsequently, we compile the results into an intermediate folder and we will use a single .jl file to produce the compiled version for quick reference.","category":"page"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Running time of reproducing all the results: 46 seconds.","category":"page"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"CPU: Apple M1\nRAM: 8 GB\nOS: Sonoma 14","category":"page"},{"location":"README/#Data-Availability","page":"ReadMe","title":"Data Availability","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"The data used for this replication is available at the website of the Econometrics Society here.","category":"page"},{"location":"README/#Software-Requirements","page":"ReadMe","title":"Software Requirements","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Julia (version used for this replication: 1.10.3)\nThe following julia packages need to be installed. The versions of all packages can be found in Manifest.toml\nCategoricalArrays\nCSV\nCovarianceMatrices\nDataFrames\nDataFramesMeta\nFixedEffectModels\nGLM\nIpopt\nJLD2\nJuMP\nMAT\nPanelDataTools\nPlots\nPrettyTables\nStatFiles\nStatsBase\nStatistics","category":"page"},{"location":"README/#Files","page":"ReadMe","title":"Files","text":"","category":"section"},{"location":"README/#Inputs-and-outputs-table","page":"ReadMe","title":"Inputs and outputs table","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"File Input Output\nfunction\\_replication.jl - -\nfunction_simulation_eval.jl - -\nBaseline.jl 1_Data/clean_data.dta, 3_Code/function_replication.jl 2_Intermediate/baseline/t1_col1.jld2, 2_Intermediate/baseline/t2_row1.jld2, 2_Intermediate/baseline/collapsed_df.csv\nBKRbaseline.jl 1_Data/clean_data.dta, 3_Code/function_replication.jl, 1_Data/StataFiles/TFP&TFPRbaseline.dta 2_Intermediate/BKRbaseline/t1_col1_BKR.jld2\nCrosssection.jl 1_Data/clean_data.dta 2_Intermediate/crosssection/t1_col3.jld2, 2_Intermediate/crosssection/t2_row2_cs.jld2\nBKRcrosssection.jl 1_Data/clean_data.dta, 1_Data/StataFiles/TFP&TFPRcrosssection.dta 2_Intermediate/BKRcrosssection/t1_col3_BKR.jld2\nCrosssection_within.jl 1_Data/clean_data.dta 2_Intermediate/crosssection_within/EffGain.jld2\nPlusAcrossVillages.jl 1_Data/clean_data.dta, 3_Code/function_replication.jl 2_Intermediate/PlusAcrossVillages/t1_col2.jld2, 2_Intermediate/PlusAcrossVillages/t2_row2.jld2\nBKRPlusAcrossVillages.jl 1_Data/clean_data.dta, 3_Code/function_replication.jl, 1_Data/StataFiles/TFP&TFPRpacrossvil.dta 2_Intermediate/BKRPlusAcrossVillages/t1_col2_BKR.jld2\nsimulation.jl 1_Data/MatlabFiles/CorrData.mat, 1_Data/MatlabFiles/NoCorrData.mat, 1_Data/MatlabFiles/Calibrated_Parameters.mat, 3_Code/function_simulation_eval.jl 2_Intermediate/simulation/col1.jld2, 2_Intermediate/simulation/col2.jld2\nt1.jl 2_Intermediate/baseline/t1_col1.jld2, 2_Intermediate/BKRbaseline/t1_col1_BKR.jld2, 2_Intermediate/PlusAcrossVillages/t1_col2.jld2, 2_Intermediate/BKRPlusAcrossVillages/t1_col2_BKR.jld2, 2_Intermediate/crosssection/t1_col3.jld2, 2_Intermediate/BKRcrosssection/t1_col3_BKR.jld2 copy console to 4_Results/table1.md\nt2.jl 2_Intermediate/baseline/t2_row1.jld2, 2_Intermediate/crosssection_within/t2_row1_cs.jld2, 2_Intermediate/PlusAcrossVillages/t2_row2.jld2, 2_Intermediate/crosssection/t2_row2_cs.jld2 copy console to 4_Results/table2.md\nt3.jl 3_Code/simulation.jl copy console to 4_Results/table3.md\nfig1.jl 2_Intermediate/baseline/collapsed_df.csv 4_Results/Figure1.pdf, 4_Results/Figure1.png\nfig2.jl 2_Intermediate/baseline/collapsed_df.csv 4_Results/Figure2.pdf, 4_Results/Figure2.png\nCompile.jl 3_Code/t1.jl, 3_Code/t2.jl, 3_Code/simulation.jl, 3_Code/function_simulation_eval.jl, 3_Code/t3.jl, 3_Code/fig1.jl, 3_Code/fig2.jl copy console to 4_Results/tableN.md 4_Results/Figure1.pdf, 4_Results/Figure1.png, 4_Results/Figure2.pdf, 4_Results/Figure2.png","category":"page"},{"location":"README/#Compile.jl","page":"ReadMe","title":"Compile.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Table 1, 2, 3 and Figures 1, 2 of the paper.","category":"page"},{"location":"README/#Baseline.jl","page":"ReadMe","title":"Baseline.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Baseline.jl is based on Baseline.do in the authors' replication package. It reproduces efficiency gains and summary statistics under the baseline fixed effects estimates of TFP, TFPR, land input, and non-agricultural income using the two-step procedure. The results correspond to Figure 1, Figure 2, Table 1 Column 1 (except BKR), Table 2, first line of 3 first columns.","category":"page"},{"location":"README/#BKRbaseline.jl","page":"ReadMe","title":"BKRbaseline.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"BKRbaseline.jl is based on BKRbaseline.do in authors' replication package. It runs the BKR regression for the baseline fixed effect measures of TFP and TFPR. The output is an estimate of the lambda coefficient from the BKR regression along with standard errors, and confidence intervals. Results reported in the paper in Table 1 (last line, first column).","category":"page"},{"location":"README/#Crosssection.jl","page":"ReadMe","title":"Crosssection.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Crosssection.jl is based on Crosssection.do in the authors' replication package. It reproduces efficiency gains and summary statistics for the repeated cross-section of households. The results correspond to Table 1 Column 3 and Table 2 Line 2 Column 2 of the original paper.","category":"page"},{"location":"README/#Crosssection_within.jl","page":"ReadMe","title":"Crosssection_within.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Crosssectionwithin.jl is based on Crosssectionwithin.do in the authors' replication package. Similar to Crosssection.jl, this file reproduces efficiency gains for the repeated cross-section of households. The results correspond to Table 2 Line 1 Column 4 of the original paper.","category":"page"},{"location":"README/#BKRcrosssection.jl","page":"ReadMe","title":"BKRcrosssection.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"BKRcrosssection.jl is based on BKRcrosssection.do in the authors' replication package. This runs the BKR regressions for the cross-sectional TFP and TFPR measures. The output estimates the lambda coefficient, standard errors and confidence intervals in last line of Table 1 Column 3.","category":"page"},{"location":"README/#PlusAcrossVillages.jl","page":"ReadMe","title":"PlusAcrossVillages.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"PlusAcrossVillages.jl is based on PlusAcrossVillages.do in the authors' replication package. It reproduces efficiency gains and summary statistics under the fixed effects estimates of TFP, TFPR, land input and non-agricultural income, without removing village effects, except for land quality. The results correspond to Table 1 Column 2 (except BKR), Table 2 Row 2 Column 1 and 2.","category":"page"},{"location":"README/#BKRPlusAcrossVillages.jl","page":"ReadMe","title":"BKRPlusAcrossVillages.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"BKRPlusAcrossVillages.jl is based on BKRPlusAcrossVillages.do in the authors' replication package. It reproduces BKR regression for the fixed effect measures of TFP and TFPR, which do not remove the village effects. The output is an estimate of the lambda coefficient from the BKR regression along with standard errors, and confidence intervals. The results correspond to Table 1 Last Row Column 2.","category":"page"},{"location":"README/#simulation.jl","page":"ReadMe","title":"simulation.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"simulation.jl is based on simulation.m in the authors' replication package. It simulates the two-sector model, given the calibrated population moments and other parameters. This program uses the generated data on individuals to solve for equilibrium in the two-sector model, and compute statistics of interest. The results correspond to Table 3.","category":"page"},{"location":"README/#function_replication.jl","page":"ReadMe","title":"function_replication.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Contains functons used in Baseline.jl, BKRbaseline.jl, PlusAcrossVillages.jl, BKRPlusAcrossVillages.jl. The functions include estimating household fixed effects (getfe()), calculating mean with missing values (safemean()), estimating residuals from household-specific fixed effects regression (getresid()), trimming the data (trimdf()), estimating residuals from fixed-effects model with no constant (getresidnocon()), lagging variables in a panel dataset with missing values (lag_v()).","category":"page"},{"location":"README/#function*simulation*eval.jl","page":"ReadMe","title":"functionsimulationeval.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"functionsimulationeval.jl is based on simulation_eval.m in the authors' replication package. It solves for the equilibrium of the two-sector model, given a guess for the agricultural common return wa.","category":"page"},{"location":"README/#fig1.jl","page":"ReadMe","title":"fig1.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Figure 1. Output is saved in 4_Results as Figure1.pdf.","category":"page"},{"location":"README/#fig2.jl","page":"ReadMe","title":"fig2.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Figure 2. Output is saved in 4_Results as Figure2.pdf.","category":"page"},{"location":"README/#t1.jl","page":"ReadMe","title":"t1.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Table 1. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.","category":"page"},{"location":"README/#t2.jl","page":"ReadMe","title":"t2.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Table 2. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.","category":"page"},{"location":"README/#t3.jl","page":"ReadMe","title":"t3.jl","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Reproduces Table 3. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.","category":"page"},{"location":"README/#Figures-/-Tables","page":"ReadMe","title":"Figures / Tables","text":"","category":"section"},{"location":"README/#Functions-to-reproduce-the-tables-and-figures","page":"ReadMe","title":"Functions to reproduce the tables and figures","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"The results from the previous Julia files are saved in an intermediate folder called \"intermediate\". They are then compiled using the file Compile.jl to produce the actual tables from the paper. To reproduce table X, run a function in Compile.jl called tX(). The output will display in the console. To reproduce figure X, run figX() in Compile.jl. The output will be stored in 4_Results as a PDF file.","category":"page"},{"location":"README/#Comparison-Stata-vs-Julia","page":"ReadMe","title":"Comparison Stata vs Julia","text":"","category":"section"},{"location":"README/","page":"ReadMe","title":"ReadMe","text":"Based on the exercise, we noticed three key areas of difference which could pinpoint the small differences we picked up from our replication and the results in the paper. Firstly, as we performed the logarithmic transformation on variables multiple times per .jl file, we had to manually clean the data such that values out of bounds in were omitted in Julia while the process for dropping such values in Stata is more opaque to the user. Secondly, Stata and Julia handles missing values differently and for us, we manually cleaned the data on our end to drop the missing data in Julia. Lastly, given these differences, the residuals and the number of observations computed in Stata and in Julia for regression analysis are likely to differ slightly because of this.  ","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ABLR_2022","category":"page"},{"location":"#ABLR_2022","page":"Home","title":"ABLR_2022","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ABLR_2022.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ABLR_2022]","category":"page"}]
}
