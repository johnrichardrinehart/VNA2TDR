function [Freq, S11] = S11OverlapFixer(Freq, S11)

if iscolumn(S11)
    S11 = S11.';
end
if iscolumn(Freq)
    Freq = Freq.';
end

% Make sure the frequency array is valid
check = zeros(1,length(Freq)-1);

for j=1:1:length(Freq)-1
    check(1,j) = Freq(j+1)-Freq(j);
end
check = check - check(1,1); % nonzero if difference between adjacent elements
                            %is anywhere different from the difference between the first two.
if any(check)
    warning(['Not all your frequencies are the same distance from each other.'...
        ' I''m going to try to fix this. Read the docs for more information.']);
    locs = find(check); % Get locations of differences;
    samelocs = cell(length(locs),1); % Make cell from locs array
    for i = 1:length(locs)
        temp = Freq - Freq(locs(i)); % Turn all the same Freq locs into zero
        samelocs{i,1} = find(not(temp)); % Finds all locations where Freq(loc(i)) == Freq
    end
    
    for i = 1:length(samelocs)
        for j = 1:length(samelocs{i,1})-1
            startfreq = samelocs{i,1}(j); % Start of same frequency block
            stopfreq = samelocs{i,1}(j+1); % distance between ith and ith+1 instances of the frequencies
            Freq(startfreq:stopfreq-1) = []; % remove all the redundant frequencies
            %S11(startfreq:stopfreq) = mean([S11(startfreq:stopfreq-1),S11(stopfreq:stopfreq+(stopfreq-startfreq-1))]);
            S11(startfreq:stopfreq-1) = []; % remove all redundant S11s
            for k = i+1:length(samelocs)
                samelocs{k,1} = samelocs{k,1}-(stopfreq-startfreq); % shift all the locs down by the amount that's been removed
            end
        end
    end
    check = zeros(1,length(Freq)-1);
    for j = 1:length(Freq)-1
        check(1,j) = Freq(j+1)-Freq(j);
    end
    check = check - check(1,1);
    if any(check)
        error('Failed to fix the overlapping frequencies.')
    end
end