function fig2()
    collapsed_df = CSV.read("2_Intermediate/baseline/collapsed_df.csv", DataFrame)
    collapsed_df.logTFPReff = log.(collapsed_df.TFPReff)
    df5 = dropmissing(collapsed_df, [:logTFPRfei, :logTFPQfei, :logTFPReff])
    ols = GLM.lm(@formula(logTFPRfei ~ logTFPQfei), df5)
    p = scatter(df5.logTFPQfei, df5.logTFPRfei, color = :lightblue, xlims = (-2.5, 1.5), ylims = (-3.5, 2.5),
    ylab = "Farm TFPR (log)", xlab = "Farm TFP (log)", legend = false,
    xguidefontsize = 10, yguidefontsize = 10)
    plot!(p, df5.logTFPQfei, predict(ols), color = :darkblue, lw = 2, label = "Fitted line")
    plot!(p, df5.logTFPQfei, df5.logTFPReff, color = :red, linestyle = :dash, lw = 3, label = "Efficient allocation line")
    savefig("4_Results/Figure2.pdf")
    display(p)
end