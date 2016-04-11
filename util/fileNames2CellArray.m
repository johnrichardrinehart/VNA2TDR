function pathCell = fileNames2CellArray(reldir, prefix, common, suffixes, tag, fileext)
pathCell = cell(length(suffixes),1); % suffix is the unique set of strings
for i = 1:numel(pathCell)
    pathCell{i} = [reldir '/' prefix common suffixes{i} tag fileext];
end
end