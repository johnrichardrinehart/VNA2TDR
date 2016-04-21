function conjSymmetric = makeConjugateSymmetric(array)
% conjSymmetric = makeConjugateSymmetric (array)
% array is an array such that imag(array(1)) == 0
% conjSymmetric is a conjugate symmetric array constructed from array

if isvector(array)
   if isrow(array)
      array = array';
   end
else
   error('makeConjugateSymmetric is only defined for arrays.');
end

conjSymmetric = [flipud(conj(array(2:end))); array];

if mod(length(conjSymmetric),2) ~= 1
   error('array does not have an odd number of indices');
end

N = (length(conjSymmetric)-1)/2; % length(array) - 1

first_half = conjSymmetric(1:N);
second_half = conjSymmetric(N+2:end);
if any(first_half - conj(flipud(second_half)))
   error('array is not conjugate symmetric.')
end

end
