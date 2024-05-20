function fig1()
    ### FIGURE 1 ###
    collapsed_df = CSV.read("2_Intermediate/baseline/collapsed_df.csv", DataFrame)
    # skip missing values from collapsed_df of logLfei and logSfei
    df1 = dropmissing(collapsed_df, [:logLfei, :logSfei, :logleff])
    # regress logLfei on logSfei, calculate predicted values and add the line to the scatter plot
    ols1 = GLM.lm(@formula(logLfei ~ logSfei), df1)

    # do the same but use logKfei instead of logLfei
    df2 = dropmissing(collapsed_df, [:logKfei, :logSfei, :logkeff])
    ols2 = GLM.lm(@formula(logKfei ~ logSfei), df2)

    # Land productivity VS farm TFP
    df3 = dropmissing(collapsed_df, [:logYfei, :logLfei, :logSfei, :logyeff, :logleff])
    df3.logyol = df3.logYfei .- df3.logLfei
    df3.logyoleff = df3.logyeff .- df3.logleff
    ols3 = GLM.lm(@formula(logyol ~ logSfei), df3)

    # Capital productivity VS farm TFP
    df4 = dropmissing(collapsed_df, [:logYfei, :logKfei, :logSfei, :logyeff, :logleff])
    df4.logyok = df4.logYfei .- df4.logKfei
    df4.logyokeff = df4.logyeff .- df4.logkeff
    ols4 = GLM.lm(@formula(logyok ~ logSfei), df4)
    # plot all the figures in (2,2)
    
    # set titlefontsize to 12
    # set xlabfontsize to 10
    # set ylabfontsize to 10
    p = plot(
    scatter(df1.logSfei, df1.logLfei, color = :lightblue, xlims = (-4, 4), ylims = (-4, 4), 
    ylab = "Capital input (log)", xlab = "Farm productivity (log)", legend = false, title = "Land", 
    titlefontsize = 10, xguidefontsize = 8, yguidefontsize = 8),
    scatter(df2.logSfei, df2.logKfei, color = :lightblue, xlims = (-6, 4), ylims = (-4, 6), 
    ylab = "Land input (log)", xlab = "Farm productivity (log)", legend = false, title = "Capital",
    titlefontsize = 10, xguidefontsize = 8, yguidefontsize = 8), 
    scatter(df3.logSfei, df3.logyol, color = :lightblue, 
    ylab = "Land productivity (log)", xlab = "Farm productivity (log)", legend = false, title = "Land productivity",
    titlefontsize = 10, xguidefontsize = 8, yguidefontsize = 8),
    scatter(df4.logSfei, df4.logyok, color = :lightblue, 
    ylab = "Capital productivity (log)", xlab = "Farm productivity (log)", legend = false, title = "Capital productivity",
    titlefontsize = 10, xguidefontsize = 8, yguidefontsize = 8),
    layout = (2,2)
    )
    plot!(p, df1.logSfei, predict(ols1) , color = :darkblue, lw = 2, label = "Fitted line", subplot = 1)
    plot!(p, df1.logSfei, df1.logleff, color = :red, linestyle = :dash, lw = 2,  label = "Efficient allocation line", subplot = 1)

    plot!(df2.logSfei, predict(ols2), color = :darkblue, lw = 2, label = "Fitted line", subplot = 2)
    plot!(df2.logSfei, df2.logkeff, color = :red, linestyle = :dash, lw = 2, label = "Efficient allocation line", subplot = 2)
        
    plot!(df3.logSfei, predict(ols3), color = :darkblue, lw = 2, label = "Fitted line", subplot = 3)
    plot!(df3.logSfei, df3.logyoleff, color = :red,linestyle = :dash, lw = 3, label = "Efficient allocation line", subplot = 3)

    plot!(df4.logSfei, predict(ols4), color = :darkblue, lw = 2, label = "Fitted line", subplot = 4)
    plot!(df4.logSfei, df4.logyokeff, color = :red,linestyle = :dash, lw = 3, label = "Efficient allocation line", subplot = 4)

    savefig("4_Results/Figure1.pdf")
    savefig("4_Results/Figure1.png")
    display(p)

end