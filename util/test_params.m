clear all; close all;

% Set up frequencies
deltaF = 1e-1;
maxF = 1e1;
freqs = 0:deltaF:maxF;

% Define transfer function, RC high-pass filter (R is load)
transfer_function = @(f)(1i*2*pi*f./(1+1i*2*pi*f));
S11 = transfer_function(freqs);

% Filter the signal
filt_coeffs = fftshift(kaiser(length(freqs)*2-1,6));
filt_coeffs = filt_coeffs(1:length(freqs));
S11 = S11.*filt_coeffs';

% Obtain the step and impulse responses
[times, step_response, imp_response] = SParams2TDR(freqs,S11);

% !! Magical line below!!
step_response_flipped_and_shifted = flipud(step_response)+.5;

figure(1);

plot(times, step_response,'r',...
    times,step_response_flipped_and_shifted,'k',...
    times,1-exp(-1*times),'b');
title('Numerical output vs. Analytical values');
legend('Numerical - unflipped and unshifted',...
    'Numerical - flipped and shifted',...
    'Analytic','Location','southwest'); 
ylabel('Voltage/Whatever you want (V/whatever units)');
xlabel('Time (s)');
export_fig([getenv('HOMEDRIVE') getenv('HOMEPATH') filesep 'Downloads' filesep 'output.png']); 
% figure(2);
% plot(times,imp_response);
% title('impulse response');