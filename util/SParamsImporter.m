function [Freqs, S11, S21, S12, S22] = SParamsImporter(path)
% [Freqs, S11, S21, S12, S22] = SParamsImporter(string)
% S parameters are returned in complex number format (real + imaginary)
%%% S parameters file importer. Assumes Touchstone file format

fileread = dlmread(path,' ',9,0);
% Assume the data starts at row 10 and is in log-mag format
Freqs = fileread(1:end,1);
S11Mag = fileread(1:end,2);
S11Phase = fileread(1:end,3);
S21Mag = fileread(1:end,4);
S21Phase = fileread(1:end,5);
S12Mag = fileread(1:end,6);
S12Phase = fileread(1:end,7);
S22Mag = fileread(1:end,8);
S22Phase = fileread(1:end,9);

S11 = 10.^(S11Mag/20).*exp(-1i*S11Phase*pi/180); % Change the phase to -1 for the SParams -> TDR
S21 = 10.^(S21Mag/20).*exp(1i*S21Phase*pi/180);
S12 = 10.^(S12Mag/20).*exp(1i*S12Phase*pi/180);
S22 = 10.^(S22Mag/20).*exp(1i*S22Phase*pi/180);