function [times, step_response] = SParams2TDR(Freq,S11,varargin)

Freq = makeColumn(Freq);
S11 = makeColumn(S11);
deltaF = Freq(2)-Freq(1);
filterFunction = ones(length(S11),1);
times = 0:max(Freq)^-1:deltaF^-1;

if length(times) ~= length(S11)
   error('time array is not the right size');
end

for m = 1:2:length(varargin)
   param = varargin{m};
   switch param
   case 'filter'
      filterFunction = makeColumn(varargin{m+1});
   case 'times'
      times = makeColumn(varargin{m+1});
   end
end

% Generate a matrix with fixed times in the column and fixed frequency in the
% row;
M = zeros(length(Freq),length(times));
for i = 1:length(times)
   M(:,i) = deltaF * S11 .* exp(2*pi*1i*times(i)*Freq);
end
step_response =sum(M);
%step_response = step_response';
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
