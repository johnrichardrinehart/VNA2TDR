function [Freq, S11, varargout] = SParamsOverlapFixer(Freq, S11, varargin)

% Process inputs below
if isrow(S11)
    S11 = S11';
end
if ~isempty(varargin)
    varargout = varargin;
end

% Make sure the frequency array is valid (regularly spaced)
check = zeros(1,length(Freq)-1);

for j=1:1:length(Freq)-1
    check(1,j) = Freq(j+1)-Freq(j);
end
check = check - check(1,1);
if any(check)
    warning(['Not all your frequencies are the same distance from each other.'...
        ' I''m going to try to fix this. Read the docs for more information.']);
    locs = find(check);
    samelocs = cell(length(locs),1);
    for i = 1:length(locs)
        temp = Freq - Freq(locs(i)); % Turn all the same Freq locs into zero
        samelocs{i,1} = find(not(temp)); % Finds all locations where Freq(loc(i)) == Freq
    end
    
    for i = 1:length(samelocs)
        for j = 1:length(samelocs{i,1})-1
            startfreq = samelocs{i,1}(j); % Start of same frequency block
            stopfreq = samelocs{i,1}(j+1); % distance between ith and ith+1 instances of the frequencies
            Freq(startfreq:stopfreq-1) = []; % remove all the redundant frequencies
            % Adjust the scattering parameters accordingly
            %           S11 = AdjustSParams(startfreq,stopfreq,S11); S21 = AdjustSParams(startfreq,stopfreq,S21);
            %           S12 = AdjustSParams(startfreq,stopfreq,S12); S22 = AdjustSParams(startfreq,stopfreq,S22);
            %S11(startfreq:stopfreq) = mean([S11(startfreq:stopfreq-1); S11(stopfreq:stopfreq+(stopfreq-startfreq-1))]);
            S11(startfreq:stopfreq-1) = [];
            if ~isempty(varargin)
                for k = 1:length(varargin)
                    %varargout{k}(startfreq:stopfreq) = mean([varargin{1}(startfreq:stopfreq-1); varargin{1}(stopfreq:stopfreq+(stopfreq-startfreq-1))]);
                    % remove all redundant scattering parameters
                    varargout{k}(startfreq:stopfreq-1) = [];
                end
            end
            for k = i+1:length(samelocs)
                samelocs{k,1} = samelocs{k,1}-(stopfreq-startfreq); % shift all the indices down
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
end