function [times, step_response] = SParams2TDR(Freq,S11,varargin)

Freq = makeColumn(Freq);
S11 = makeColumn(S11);
deltaF = Freq(2)-Freq(1);
filterFunction = ones(length(S11),1);
times = [0:max(Freq)^-1:deltaF^-1]';

if length(times) ~= length(S11)
   error('time array is not the right size');
end

for m = 1:2:length(varargin)
   switch varargin{m}
   case 'filter'
      filterFunction = makeColumn(varargin{m+1});
   case 'times'
      times = makeColumn(varargin{m+1});
   end
end

% The below computes eq. 3.24 (page 65) of Phillip Dunsmore's U Leeds
% thesis (The Time-Domain Response of  Coupled-Resonator Filters with 
% Applications to Tuning)

% Generate a matrix with fixed times in the column and fixed frequency
% in the row;
M = zeros(length(Freq)-1,length(times));
for i = 1:length(times);
   M(:,i) = Freq(2:end).*filterFunction(2:end).*exp(1i*Freq(2:end)*times(i))./(1i*Freq(2:end))+ ... 
       S11(1)*deltaF*times(i);
end
% The below is missing the group delay constant
step_response = .5*S11(1) + 2*deltaF*real(sum(M));
step_response = step_response';
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
