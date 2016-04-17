function cleanedArray = cleanArray(array,varargin)
% cleanedArray = cleanArray(array)
% cleanArray removes the negligible real and imaginary parts from an array.
% varargin allows special key-value pairs to be used to set how cleanArray
% operates
% Optional parameters: 'threshold' (double); specifies the maximum ratio of
% imag/real or real/imag before value is kept [default: 1e-10]

cleanedArray = zeros(length(array),1); % init output

threshold = 1e-10;
for i = 1:2:length(varargin)
   switch varargin(i)
   case 'threshold'
      threshold = varargin(i+1);
   end
end

realOverImag = abs(real(array)./imag(array));
imagOverReal = abs(imag(array)./real(array));
realTooSmall = realOverImag < threshold; % logical array
imagTooSmall = imagOverReal < threshold; % logical array
neitherTooSmall = ~(imagTooSmall | realTooSmall);
cleanedArray = 1i*imag(array).*realTooSmall + ...
               real(array).*imagTooSmall + ...
               array.*neitherTooSmall;
end
