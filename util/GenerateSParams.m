function [Freqs S11] = GenerateSParams(freqs, func)
Freqs = freqs;
S11 = func(freqs);
