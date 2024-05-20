function simulation_eval(x, wn)
    wa = x

    # Calculate Ia_tilda_vec and In_tilda_vec
    Ia_tilda_vec = wa .* vecSA .* vecFI
    In_tilda_vec = (1 - ETA) .* wn .* vecSN

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

    # CHECK
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
    f = (Ya - Ca)^2

    return f    
end