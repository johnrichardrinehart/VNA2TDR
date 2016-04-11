function fig = SParamsPlotter(frequencies, varargin)
% This function will plot the scattering parameters.
% length(varargin) == 1 -> S11
% length(varargin) == 2 -> S11, S21
% length(varargin) == 4 -> S11, S21, S12, S22
if length(varargin) == 1
    fig = figure;
    plot(frequencies*1e-9, 20*log10(abs(varargin{1})));
    title('$S_{11}$ as a function of Frequency');
    xlabel('f (GHz)'); ylabel('$| S_{11} |$ (dB)');
elseif length(varargin) == 2
    fig = figure;
    plot(frequencies*1e-9, 20*log10(abs(varargin{1})), ...
        frequencies*1e-9, 20*log10(abs(varargin{2})));
    title('S_{11} and S_{21} as a function of Frequency');
    xlabel('f (GHz)'); ylabel('$| S_{11}| $, $| S_{21} |$ (dB)');
elseif length(varargin) == 4
    close all;
    fig = figure(1);
    plot(frequencies*1e-9, 20*log10(abs(varargin{1})), ...
        frequencies*1e-9, 20*log10(abs(varargin{3})), ...
        frequencies*1e-9, 20*log10(abs(varargin{2})), ...
        frequencies*1e-9, 20*log10(abs(varargin{4})));
    legend('S11','S21','S12','S22','Location','southeast');
    title('S2P as a function of Frequency');
    xlabel('f (GHz)'); ylabel('$| S_{ij} |$ (dB)');   
end