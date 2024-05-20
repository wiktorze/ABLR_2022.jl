function t1(;latex = false)
    ### Compiling Table 1
    # Column 1
    t1_col1_noBKR = load_object("2_Intermediate/baseline/t1_col1.jld2")
    t1_col1_BKR = load_object("2_Intermediate/BKRbaseline/t1_col1_BKR.jld2")
    t1_col1 = [""; t1_col1_noBKR; t1_col1_BKR]
    # Column 2
    t1_col2_noBKR = load_object("2_Intermediate/PlusAcrossVillages/t1_col2.jld2")
    t1_col2_BKR = load_object("2_Intermediate/BKRPlusAcrossVillages/t1_col2_BKR.jld2")
    t1_col2 = [""; t1_col2_noBKR; t1_col2_BKR]
    # Column 3
    t1_col3_noBKR = load_object("2_Intermediate/crosssection/t1_col3.jld2")
    t1_col3_BKR = load_object("2_Intermediate/BKRcrosssection/t1_col3_BKR.jld2")
    t1_col3 = [""; t1_col3_noBKR; t1_col3_BKR]

    names = (["Farm TFP", 
    "STD(log)",
    "p90/p10",
    "p75/p25",
    "Farm",
    "STD(log)",
    "p90/p10",
    "p75/p25",
    "CORR (logTFP, logTFPR)",
    "BKR λ",
    "Standard error",
    "95% confidence interval"])
    data = hcat(names, t1_col1, t1_col2, t1_col3)
    header = (["","Household Farm", "Village", "Cross-Section average"])
    # save as .tex
    if latex
        pretty_table(data, backend = Val(:latex), header = header)
    else
        pretty_table(data, backend = Val(:markdown), header = header)
    end
end