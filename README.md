# ABLR_2022

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://wiktorze.github.io/ABLR_2022.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://wiktorze.github.io/ABLR_2022.jl/dev/)
[![Build Status](https://github.com/wiktorze/ABLR_2022.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/wiktorze/ABLR_2022.jl/actions/workflows/CI.yml?query=branch%3Amain)

The project was created for Computational Economics course led by Florian Oswald at Sciences Po Paris:
https://floswald.github.io/NumericalMethods/

This README describes the replication procedure for "Misallocation, Selection and Productivity: A Quantitative Analysis with Panel Data from China" by Adamapoulos et al. (2022). We translate code from the following files in the original replication package to Julia. Subsequently, we compile the results into an intermediate folder and we will use a single .jl file to produce the compiled version for quick reference.

Running time of reproducing all the results: 46 seconds.
- CPU: Apple M1
- RAM: 8 GB
- OS: Sonoma 14

## Data Availability 

The data used for this replication is available at the website of the Econometrics Society [here](https://www.econometricsociety.org/publications/econometrica/browse/2022/05/01/misallocation-selection-and-productivity-quantitative-analysis).

## Software Requirements
- Julia (version used for this replication: 1.10.3)
- The following julia packages need to be installed. The versions of all packages can be found in Manifest.toml
    - CategoricalArrays
    - CSV
    - CovarianceMatrices
    - DataFrames
    - DataFramesMeta
    - FixedEffectModels
    - GLM
    - Ipopt
    - JLD2
    - JuMP
    - MAT
    - PanelDataTools
    - Plots
    - PrettyTables
    - StatFiles
    - StatsBase
    - Statistics

## How to run the code
To run the code, set the directory as the downloaded folder, so run cd("YourDownloadPath/ABLR_2022.jl-main"). 

Then, add all the packages needed to run the code. In Julia REPL, type "]" and "add CategoricalArrays, CSV, CovarianceMatrices, DataFrames, DataFramesMeta, FixedEffectModels, GLM, Ipopt, JLD2, JuMP, MAT, PanelDataTools, Plots, PrettyTables, StatFiles, StatsBase, Statistics". 

Then, use backspace to come back to julia mode. Run 3_Code/Compile.jl to produce all the results. Tables will display in the console while figures will be saved in 4_Results folder.

To produce the intermediate results for tables 1, 2 and figures 1,2, run all the files from 3_Code that are not functions: Baseline.jl, BKRbaseline.jl, Crosssection.jl, BKRcrosssection.jl, Crosssection_within.jl, PlusAcrossVillages.jl, BKRPlusAcrossVillages.jl.

## Files
### Inputs and outputs table
| File       | Input                  | Output                 |
|------------|:----------------------|:----------------------|
| function\_replication.jl | - | - |
| function\_simulation\_eval.jl | - | - |
| Baseline.jl | 1\_Data/clean\_data.dta, 3\_Code/function\_replication.jl | 2\_Intermediate/baseline/t1\_col1.jld2, 2\_Intermediate/baseline/t2\_row1.jld2, 2\_Intermediate/baseline/collapsed\_df.csv |
| BKRbaseline.jl |  1\_Data/clean\_data.dta, 3\_Code/function\_replication.jl, 1\_Data/StataFiles/TFP&TFPRbaseline.dta | 2\_Intermediate/BKRbaseline/t1\_col1\_BKR.jld2|
| Crosssection.jl | 1\_Data/clean\_data.dta | 2\_Intermediate/crosssection/t1\_col3.jld2, 2\_Intermediate/crosssection/t2\_row2\_cs.jld2 |
| BKRcrosssection.jl | 1\_Data/clean\_data.dta, 1\_Data/StataFiles/TFP&TFPRcrosssection.dta | 2\_Intermediate/BKRcrosssection/t1\_col3\_BKR.jld2
| Crosssection\_within.jl | 1\_Data/clean\_data.dta | 2\_Intermediate/crosssection\_within/EffGain.jld2 |
| PlusAcrossVillages.jl | 1\_Data/clean\_data.dta, 3\_Code/function\_replication.jl | 2\_Intermediate/PlusAcrossVillages/t1\_col2.jld2, 2\_Intermediate/PlusAcrossVillages/t2\_row2.jld2 |
| BKRPlusAcrossVillages.jl | 1\_Data/clean\_data.dta, 3\_Code/function\_replication.jl, 1\_Data/StataFiles/TFP&TFPRpacrossvil.dta | 2\_Intermediate/BKRPlusAcrossVillages/t1\_col2\_BKR.jld2 |
| simulation.jl | 1\_Data/MatlabFiles/CorrData.mat, 1\_Data/MatlabFiles/NoCorrData.mat, 1\_Data/MatlabFiles/Calibrated\_Parameters.mat, 3\_Code/function\_simulation\_eval.jl | 2\_Intermediate/simulation/col1.jld2, 2\_Intermediate/simulation/col2.jld2 |
| t1.jl | 2\_Intermediate/baseline/t1\_col1.jld2, 2\_Intermediate/BKRbaseline/t1\_col1\_BKR.jld2, 2\_Intermediate/PlusAcrossVillages/t1\_col2.jld2, 2\_Intermediate/BKRPlusAcrossVillages/t1\_col2\_BKR.jld2, 2\_Intermediate/crosssection/t1\_col3.jld2, 2\_Intermediate/BKRcrosssection/t1\_col3\_BKR.jld2 | copy console to 4\_Results/table1.md |
| t2.jl | 2\_Intermediate/baseline/t2\_row1.jld2, 2\_Intermediate/crosssection\_within/t2\_row1\_cs.jld2, 2\_Intermediate/PlusAcrossVillages/t2\_row2.jld2, 2\_Intermediate/crosssection/t2\_row2\_cs.jld2 | copy console to 4\_Results/table2.md |
| t3.jl | 3\_Code/simulation.jl | copy console to 4\_Results/table3.md |
| fig1.jl | 2\_Intermediate/baseline/collapsed\_df.csv | 4\_Results/Figure1.pdf, 4\_Results/Figure1.png |
| fig2.jl | 2\_Intermediate/baseline/collapsed\_df.csv | 4\_Results/Figure2.pdf, 4\_Results/Figure2.png |
| Compile.jl | 3\_Code/t1.jl, 3\_Code/t2.jl, 3\_Code/simulation.jl, 3\_Code/function\_simulation\_eval.jl, 3\_Code/t3.jl, 3\_Code/fig1.jl, 3\_Code/fig2.jl | copy console to 4\_Results/tableN.md 4\_Results/Figure1.pdf, 4\_Results/Figure1.png, 4\_Results/Figure2.pdf, 4\_Results/Figure2.png |

### Compile.jl
Reproduces Table 1, 2, 3 and Figures 1, 2 of the paper.
### Baseline.jl
Baseline.jl is based on Baseline.do in the authors' replication package. It reproduces efficiency gains and summary statistics under the baseline fixed effects estimates of TFP, TFPR, land input, and non-agricultural income using the two-step procedure. The results correspond to Figure 1, Figure 2, Table 1 Column 1 (except BKR), Table 2, first line of 3 first columns.
### BKRbaseline.jl
BKRbaseline.jl is based on BKRbaseline.do in authors' replication package. It runs the BKR regression for the baseline fixed effect measures of TFP and TFPR. The output is an estimate of the lambda coefficient from the BKR regression along with standard errors, and confidence intervals. Results reported in the paper in Table 1 (last line, first column).
### Crosssection.jl
Crosssection.jl is based on Crosssection.do in the authors' replication package. It reproduces efficiency gains and summary statistics for the repeated cross-section of households. The results correspond to Table 1 Column 3 and Table 2 Line 2 Column 2 of the original paper.
### Crosssection_within.jl
Crosssection_within.jl is based on Crosssection_within.do in the authors' replication package. Similar to Crosssection.jl, this file reproduces efficiency gains for the repeated cross-section of households. The results correspond to Table 2 Line 1 Column 4 of the original paper.
### BKRcrosssection.jl
BKRcrosssection.jl is based on BKRcrosssection.do in the authors' replication package. This runs the BKR regressions for the cross-sectional TFP and TFPR measures. The output estimates the lambda coefficient, standard errors and confidence intervals in last line of Table 1 Column 3.
### PlusAcrossVillages.jl
PlusAcrossVillages.jl is based on PlusAcrossVillages.do in the authors' replication package. It reproduces efficiency gains and summary statistics under the fixed effects estimates of TFP, TFPR, land input and non-agricultural income, without removing village effects, except for land quality. The results correspond to Table 1 Column 2 (except BKR), Table 2 Row 2 Column 1 and 2.
### BKRPlusAcrossVillages.jl
BKRPlusAcrossVillages.jl is based on BKRPlusAcrossVillages.do in the authors' replication package. It reproduces BKR regression for the fixed effect measures of TFP and TFPR, which do not remove the village effects. The output is an estimate of the lambda coefficient from the BKR regression along with standard errors, and confidence intervals. The results correspond to Table 1 Last Row Column 2.
### simulation.jl
simulation.jl is based on simulation.m in the authors' replication package. It simulates the two-sector model, given the calibrated population moments and other parameters. This program uses the generated data on individuals to solve for equilibrium in the two-sector
model, and compute statistics of interest. The results correspond to Table 3.
### function_replication.jl
Contains functons used in Baseline.jl, BKRbaseline.jl, PlusAcrossVillages.jl, BKRPlusAcrossVillages.jl. The functions include estimating household fixed effects (get_fe()), calculating mean with missing values (safe_mean()), estimating residuals from household-specific fixed effects regression (get_resid()), trimming the data (trim_df()), estimating residuals from fixed-effects model with no constant (get_resid_nocon()), lagging variables in a panel dataset with missing values (lag_v()).
### function_simulation_eval.jl
function_simulation_eval.jl is based on simulation_eval.m in the authors' replication package. It solves for the equilibrium of the two-sector model, given a guess for the agricultural common return wa.
### fig1.jl
Reproduces Figure 1. Output is saved in 4_Results as Figure1.pdf.
### fig2.jl
Reproduces Figure 2. Output is saved in 4_Results as Figure2.pdf.
### t1.jl
Reproduces Table 1. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.
### t2.jl
Reproduces Table 2. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.
### t3.jl
Reproduces Table 3. Table displays in the console. Pass latex = true as an argument to produce a latex formatted table. Otherwise, the output will be in MarkDown.
## Figures / Tables
### Functions to reproduce the tables and figures
The results from the previous Julia files are saved in an intermediate folder called "intermediate". They are then compiled using the file Compile.jl to produce the actual tables from the paper. To reproduce table X, run a function in Compile.jl called tX(). The output will display in the console. To reproduce figure X, run figX() in Compile.jl. The output will be stored in 4_Results as a PDF file.
### Comparison Stata vs Julia
Based on the exercise, we noticed three key areas of difference which could pinpoint the small differences we picked up from our replication and the results in the paper. Firstly, as we performed the logarithmic transformation on variables multiple times per .jl file, we had to manually clean the data such that values out of bounds in were omitted in Julia while the process for dropping such values in Stata is more opaque to the user. Secondly, Stata and Julia handles missing values differently and for us, we manually cleaned the data on our end to drop the missing data in Julia. Lastly, given these differences, the residuals and the number of observations computed in Stata and in Julia for regression analysis are likely to differ slightly because of this.  
