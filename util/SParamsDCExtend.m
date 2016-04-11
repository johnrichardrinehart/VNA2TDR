function [Freqs, S11] = SParamsDCExtend(Freqs, S11)
    deltaf = Freqs(2)-Freqs(1);
    numextrapts = round(Freqs(1)/deltaf);
    phasechange = angle(S11(1,1))/numextrapts; % amount by which to reverse the phase (in radians)
    
    % extend the S11 down to DC, rolling down the phase
    extrapts = zeros(length(numextrapts),1);
    for j = 1:1:numextrapts
        extrapts(numextrapts-j+1,1) = S11(1,1)*exp(-1i*(j*phasechange));
    end
    extrapts(1,1) = abs(extrapts(1,1)); % (imag(S11(1,1)) < 10^-12) -> 0
    S11 = [extrapts; S11];
    
    % extend the Freqsuencies
    newFreqs = (Freqs(1)-numextrapts*deltaf:deltaf:Freqs(1)-deltaf)';
    Freqs = [newFreqs; Freqs];
end