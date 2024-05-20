function t2(;latex = false)
    t2_row1_no_cs = load_object("2_Intermediate/baseline/t2_row1.jld2")
    t2_row1_cs = load_object("2_Intermediate/crosssection_within/t2_row1_cs.jld2")
    t2_row2_no_cs = load_object("2_Intermediate/PlusAcrossVillages/t2_row2.jld2")
    t2_row2_cs = load_object("2_Intermediate/crosssection/t2_row2_cs.jld2")

    t2_c1 = [""; t2_row1_no_cs[1]; t2_row2_no_cs[1]]
    t2_c2 = [""; t2_row1_no_cs[2]; t2_row2_no_cs[2]]
    t2_c3 = [""; t2_row1_no_cs[3]; t2_row2_no_cs[3]]
    t2_c4 = [""; t2_row1_cs[1]; t2_row2_cs[1]]

    names = (["Eliminating misallocation across households", "within villages", "+ across villages"])
    header = (["", "Total", "Across s missalocation", "Land distortion", "Cross-section average"])
    data = hcat(names, t2_c1, t2_c2, t2_c3, t2_c4)
    if latex
        pretty_table(data, backend = Val(:latex), header = header)
    else
        pretty_table(data, backend = Val(:markdown), header = header)
    end
end