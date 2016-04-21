function [times, step_response, impulse_response] = SParams2TDR(Freq,S11,varargin)

% sanitize input and make a frequency interval variable
S11 = makeColumn(S11);
Freq = makeColumn(Freq);
deltaF = Freq(2)-Freq(1);

% Use conjugate symmetry for S11 and make the negative frequency axis.
doubleS11 = makeConjugateSymmetric(S11); % makes a conjugate symmetric array
doubleFreq = [flipud(-Freq(2:end)); Freq]; % extend to negative frequencies

% Make the time array.
times = linspace(0,1/deltaF,length(Freq)); % generate time array
times = makeColumn(times); % force it to be a column

% for n = 1:length(times)
%     for m = 1:length(Freq)
%         if Freq(m) ~= 0
%             step_response(n) = step_response(n) + ...
%                 (1i*2*pi*Freq(m))^-1*doubleS11(m)*exp(1i*2*pi*Freq(m)*times(n));
%         end
%     end         
% end

% vectorize the sum over frequencies.
% exp_array stores e^{i*2*pi*f_{m}*t_{n}} in the (m,n) entry

exp_array = exp(1i*2*pi*doubleFreq*times'); % timen indexes columns, doubleFreq indexes rows

% Below - direct step response attempt (doesn't work because of the delta
% function and convergence issues at DC)
%
%step_response = sum([0;doubleS11(2:end)./(1i*2*pi*Freq(2:end))]*ones(1,length(times)).*...
%    exp_array);
%step_response(1) = doubleS11(1);
%step_response = (Freq(2)-Freq(1))*step_response;
%
% Below - impulse response and its numerical integration (step response)
% impulse_response is in the time domain.

% Generate the impulse response by inverting S11*e^{1i*2*pi*f*t)
impulse_response = deltaF*sum((doubleS11*ones(1,length(times))).*exp_array)';
step_response = cumtrapz(times,impulse_response); % integrate the impulse_response
end

function outArray = makeColumn(array)
if isrow(array) && isvector(array)
   outArray = array';
elseif isvector(array)
    outArray = array;
else
   error('Must be array.');
end
end