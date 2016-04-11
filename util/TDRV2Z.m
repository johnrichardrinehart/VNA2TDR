function Z = TDRV2Z(Vref,Vinc,Zref)
Z = Zref*(1+(Vref./Vinc))./(1-(Vref./Vinc));