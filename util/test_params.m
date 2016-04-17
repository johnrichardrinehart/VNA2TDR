f = linspace(0,10,100);
[freqs, S11] = GenerateSParams(f,@(f)(1./(1+1i*f)));
