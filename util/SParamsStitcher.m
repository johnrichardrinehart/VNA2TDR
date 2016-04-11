function [Freqs, S11, S21, S12, S22] = SParamsStitcher(pathCell)
% SParamsStitcher(cell type) expects a cell array with each entry in the
% array containing a single string in the cell describing the path
% of a .s2p file. Note that this only an s2p stitcher (i.e. not an s3p or
% s4p stitcher)

Freqs = []; S11 = []; S21 = []; S12 = []; S22 = [];
for i = 1:length(pathCell)
    [FreqsTmp, S11Tmp, S21Tmp, S12Tmp, S22Tmp] = SParamsImporter(pathCell{i});
    FreqsTmp = condTranspose(FreqsTmp);
    S11Tmp = condTranspose(S11Tmp);
    S21Tmp = condTranspose(S21Tmp);
    S12Tmp = condTranspose(S12Tmp);
    S22Tmp = condTranspose(S22Tmp);
    Freqs = [Freqs; FreqsTmp];
    S11 = [S11; S11Tmp];
    S21 = [S21; S21Tmp];
    S12 = [S12; S12Tmp];
    S22 = [S22; S22Tmp];
end
clear pathCell FreqsTmp S11Tmp S21Tmp S12Tmp S22Tmp;
[Freqs, S11, S21, S12, S22] = SParamsOverlapFixer(Freqs, S11, S21, S12, S22);

end

function inArray = condTranspose(inArray)
% conditional transpose function. Forces row vector to column vector.
if(isrow(inArray))
    inArray = inArray';
end
end