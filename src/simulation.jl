function Table3(CorrData = 1)

    # #Generate data for benchmark economy
    if CorrData == 1
        global cor_df=matread("1_Data/MatlabFiles/CorrData.mat")
        # Save to JLD2 format
        #@save "1_Data/MatlabFiles/CorrData.jld2" cor_df
    else
        global cor_df=matread("1_Data/MatlabFiles/NoCorrData.mat")
        # Save to JLD2
        #@save "1_Data/MatlabFiles/NoCorrData.jld2" cor_df
    end

    
    #Load calibrated parameters
    global par=matread("1_Data/MatlabFiles/Calibrated_Parameters.mat")

    # Save to JLD2
    #@save "1_Data/MatlabFiles/Calibrated_Parameters.jld2" par

    #Exponential transformation
    global LNgen=exp.(cor_df["Ngen"])
    global vecSA=LNgen[:,1]
    global vecFI=LNgen[:,2]
    global vecSN=LNgen[:,3]

    #Parameter values
    global GAMMA=0.54
    global ALPHA=2/3
    global OMEGA=0.01

    #Experiment: exogenous increase in TFP
    #An=par["An"]*1.10
    global An = par["An"]
    #Solve for equilibrium
    global wn = An

    # Initial guess for fsolve
    global guess = 0.18
    global ETA = par["ETA"]
    global L = par["L"]
    global Ka = par["Ka"]
    global Aa = par["Aa"]
    global An = par["An"]
    global aBAR = par["aBAR"]

    m = Model(Ipopt.Optimizer, print_level=0)
    @variable(m, x >= 1e-6, start = guess)
    @NLobjective(m,  Min, simulation_eval(x, wn))
    JuMP.optimize!(m)
    is_solved_and_feasible(m)
    f = objective_value(m) # much smaller than in matlab

    wa = value(x)

    Ia_tilda_vec      = wa.*vecSA.*vecFI
    In_tilda_vec      = (1-ETA).*wn.*vecSN

    # Occupational Choice Decisions
    OC_Ind = zeros(length(Ia_tilda_vec))
    OC_Ind[Ia_tilda_vec .> In_tilda_vec] .= 1

    # Total Population
    N = length(OC_Ind)

    # Share of Employment in Agriculture
    Na = sum(OC_Ind) / N

    # Effective units of labor in non-agriculture
    vec_Zn = (ones(length(OC_Ind)) .- OC_Ind) .* vecSN
    Zn = sum(vec_Zn) / N

    # Non-agricultural output
    Yn = An * Zn

    # Effective units of labor in agriculture including distortions
    Za_hat = sum(OC_Ind .* vecSA .* vecFI) / N

    # Effective units of labor in agriculture
    Za = sum(OC_Ind .* vecSA) / N

    # Sum of idiosyncratic components for agricultural output
    vec_PSIy = OC_Ind .* vecSA .* vecFI .* (vecFI .^ (GAMMA - 1))
    PSIy = sum(vec_PSIy) / N

    # Solve for the rental price of land
    q = (Za_hat / L) * wa * ALPHA * GAMMA

    # Solve for the rental price of capital
    r = (Za_hat / Ka) * wa * (1 - ALPHA) * GAMMA

    # Solve for the relative price of agriculture
    pa = (wa / ((Aa) * ((GAMMA) ^ (GAMMA / (1 - GAMMA))) * (((1 - ALPHA) / r) ^ ((GAMMA * (1 - ALPHA)) / (1 - GAMMA))) * ((ALPHA / q) ^ ((ALPHA * GAMMA) / (1 - GAMMA))))) ^ (1 - GAMMA)

    # Total agricultural output produced
    vec_Ya = (wa / pa) .* OC_Ind .* vecSA .* vecFI .* (vecFI .^ (GAMMA - 1))
    Ya = sum(vec_Ya) / N

    # Transfers from output taxes on farmers
    vec_TAU = ones(length(OC_Ind)) .- (vecFI .^ (1 - GAMMA))
    vec_T = pa .* OC_Ind .* vec_TAU .* ((wa / pa) .* vecSA .* vecFI .* (vecFI .^ (GAMMA - 1)))
    T = sum(vec_T) / N

    # Incomes
    Ia_vec = wa .* vecSA .* vecFI .+ T .* ones(length(OC_Ind))
    In_vec = (1 - ETA) .* wn .* vecSN .+ T .* ones(length(OC_Ind))
    I_vec = max.(Ia_vec, In_vec)
    INC = sum(I_vec) / N
    INCa = sum(OC_Ind .* I_vec) / N
    INCn = sum((ones(length(OC_Ind)) .- OC_Ind) .* I_vec) / N

    # Common component of land demand
    l_bar = (ALPHA * GAMMA / q) * wa

    # Array of land demands by agricultural effective ability
    l_vec = l_bar .* vecSA .* vecFI

    # Total demand for land
    LD = sum(OC_Ind .* l_vec) / N

    # CHECK: that land market clearing condition holds
    fL = LD - L

    # Common component of capital demand
    k_bar = ((1 - ALPHA) * GAMMA) * (wa / r)

    # Array of capital demand by agricultural effective ability
    k_vec = k_bar .* vecSA .* vecFI

    # Total demand for capital
    KD = sum(OC_Ind .* k_vec) / N

    # Consumption choices
    ca_vec = aBAR .* ones(length(OC_Ind)) + (OMEGA / pa) .* (I_vec - pa .* aBAR .* ones(length(OC_Ind)))
    cn_vec = (1 - OMEGA) .* (I_vec - pa .* aBAR .* ones(length(OC_Ind)))

    # Total agricultural consumption
    Ca = sum(ca_vec) / N

    # Total non-agricultural consumption
    Cn = sum(cn_vec) / N

    # GDP
    GDP = pa .* Ca + Cn

    # Agricultural market clearing condition holds
    fCa = Ya - Ca

    # STATISTICS OF INTEREST

    # Real Agricultural Productivity (Ya/Na)
    print("Real Agricultural Productivity (Ya/Na)")
    YNa = Ya/Na

    # Share of Employment in Agriculture (Na)
    print("Share of Employment in Agriculture (Na)")
    Na

    # Real Non-Agricultural Productivity (Yn/Nn)
    print("Real Non-Agricultural Productivity (Yn/Nn)")
    YNn = Yn/(1-Na)

    # Nominal Agricultural Productivity Gap (Yn/Nn)/(pa*Ya/Na)
    print("Nominal APG (Yn/Nn)/(pa*Ya/Na)")
    NomAPG = (Yn/(1-Na))/(pa*Ya/Na)

    # Real Agricultural Productivity Gap (Yn/Nn)/(Ya/Na)
    print("Real APG (Yn/Nn)/(Ya/Na)")
    RealAPG = (Yn/(1-Na))/(Ya/Na)

    # Average Effective Ability of Workers in Agriculture (Za/Na)
    print("Average Effective Ability of Workers in Agriculture (Za/Na)")
    ZNa = Za/Na

    # Average Ability of Workers in Non-Agriculture (Zn/Nn)
    print("Average Ability of Workers in Non-Agriculture (Zn/Nn)")
    ZNn = Zn/(1-Na)

    pa_star = 1
    # Real GDP per worker
    print("Real GDP Per Worker (pa_star*(Ya/Na*(Na) + (Yn/Nn)*Nn")
    YN = pa_star*(Ya/Na)*(Na) + (Yn/(1-Na))*(1-Na)

    # Ratio of Effective Abilities (Zn/Nn)/(Za/Na)
    print("Ratio of Effective Abilities (Zn/Nn)/(Za/Na)")
    ZGAP = (Zn/(1-Na))/(Za/Na)

    # Relative Price of Agriculture (pa)
    print("Relative Price of Agriculture (pa)")
    pa

    # Rental Price of Land (q)
    print("Renatal Price of Land (q)")
    q

    # Agricultural TFP (TFP = A (Za/Na)^1-GAMMA)
    print("Agricultural TFP (TFPa)")
    TFPa = YNa/((((L^ALPHA)*(Ka^(1-ALPHA)))/Na)^GAMMA)

    #**************************************************************************
    # DISTRIBUTION OF TFP
    #**************************************************************************

    # find indices of individuals active in agriculture
    indACTIVE = (findall(OC_Ind .== 1))

    # sa's of active farmers
    SA_ac = vecSA[indACTIVE]

    # TFPs of active farmers
    TFP_ac = SA_ac .^ (1 - GAMMA)

    # log of active TFPs
    lTFP_ac = log.(TFP_ac)

    # Standard Deviation of active log-TFPs
    STD_TFP = std(lTFP_ac)

    #**************************************************************************
    # DISTRIBUTION OF TFPR
    #**************************************************************************

    # TFPRs of all farms
    vecTFPR = (vecFI .^ (-(1 - GAMMA)))

    # TFPRs of active farmers
    TFPR_ac = vecTFPR[indACTIVE]

    # log of active TFPRs
    lTFPR_ac = log.(TFPR_ac)

    # Standard Deviation of active log-TFPRs
    STD_TFPR = std(lTFPR_ac)

    #**************************************************************************
    # CORRELATION OF log(TFP)-log(TFPR) OF ACTIVE FARMS
    #**************************************************************************
    CORR_TFP_TFPR = cor(lTFP_ac, lTFPR_ac)

    #**************************************************************************
    # MOMENTS OF INCOMES OF ACTIVE FARMERS
    #**************************************************************************

    # agricultural incomes of active farmers (net of transfers)
    Ia_series = Ia_tilda_vec[indACTIVE]

    # log of agricultural incomes of active farmers
    lIa_series = log.(Ia_series)

    # Standard Deviation of agricultural incomes of active farmers
    STD_logIa = std(lIa_series)

    # non-agricultural incomes of active farmers (net of transfers)
    In_series = In_tilda_vec[indACTIVE]

    # log of non-agricultural incomes of active farmers
    lIn_series = log.(In_series)

    # Standard Deviation of non-agricultural incomes of active farmers
    STD_logIn = std(lIn_series)

    # Correlation of log(Ia) - log(In) of active farmers
    CORR_logIa_logIn = cor(lIa_series, lIn_series)
    #**************************************************************************
    # CORRELATION OF ABILITIES ACROSS OCCUPATIONS CONDITIONAL ON GOING TO AGR
    #**************************************************************************

    # agricultural ability of active farmers
    sa_series = vecSA[indACTIVE]

    # non-agricultural ability of active farmers
    sn_series = vecSN[indACTIVE]

    # log of agricultural ability of active farmers
    lsa_series = log.(sa_series)

    # log of non-agricultural ability of active farmers
    lsn_series = log.(sn_series)

    # Correlation of log(sa) - log(sn) of active farms
    CORR_logsa_logsn = cor(lsa_series, lsn_series)

    # Benchmark economy values
    Yna_BE	=	0.436318
    TFPa_BE	=	0.838517
    YNn_BE	=	1.722506
    ZNa_BE	=	3.427307
    ZNn_BE	=	1.722506
    YN_BE   =	1.131126

    # Values relative to the benchmark economy
    relYNa  = YNa/Yna_BE
    relTFPa = TFPa/TFPa_BE
    relYNn  = YNn/YNn_BE
    relZNa  = ZNa/ZNa_BE
    relZNn  = ZNn/ZNn_BE
    relYN   = YN/YN_BE

    # Table Results
    TableResults = [relYNa;Na;relTFPa;relYNn;relZNa;relZNn;relYN;
    STD_TFP;STD_TFPR;CORR_TFP_TFPR;CORR_logsa_logsn;CORR_logIa_logIn]

    # Save as JD
    col = CorrData == 1 ? "col1" : "col2"
    @save "2_Intermediate/simulation/"*col*".jld2" TableResults
    return TableResults
end