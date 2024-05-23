function t3(;latex = false)
    names = (["Real Agricultural Productivity (Ya=Na)", 
    "Share of Employment in Agriculture (Na) (%)",
    "TFP in Agriculture (TFP_a)",
    "Real Non-Agricultural Productivity (Yn/Nn)",
    "Average Ability in Agriculture (Za/Na)",
    "Average Ability in Non-Agriculture (Zn/Nn)",
    "Real GDP per Worker (Y=N)",
    "STD of log-farm TFP",
    "STD of log-farm TFPR",
    "CORR of log-(farm TFP, farm TFPR)",
    "CORR of log-(agr. ability, non-agr. ability)",
    "CORR of log-(agr. income, non-agr. income)"])
    col1 = round.(Table3(1), digits = 2)
    col2 = round.(Table3(0), digits = 2)
    data = hcat(names, col1, col2)
    header = (["","Benchmark Economy", "No Correlated Distortions"])
    if latex
        pretty_table(data, backend = Val(:latex), header = header)
    else
        pretty_table(data, backend = Val(:markdown), header = header)
    end
end