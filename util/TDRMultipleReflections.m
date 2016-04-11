function Vcorrected = TDRMultipleReflections(Vmeasured)
% Takes in a voltage as a function of time and reproduces the voltage as a
% function of time accounting for multiple reflections.
%
% Reference: DOI: 10.1109/22.552029
%  ("Reconstruction of nonuniform transmission lines from time-domain
%  reflectometry")
%
% Limitations: 1) Assumes lossless lines
%              2) Assumes the same velocity factor everywhere in the
%              material
%              3) Assumes step of constant amplitude = 1 as incident pulse
%              4) Only accounts for single-order (single) reflections

% Initialize the voltage array
Vcorrected = zeros(length(Vmeasured),1);
Vcorrected(1) = Vmeasured(1); % Vcorrected stores the first reflected voltage

% Initialization
subtrahend = Vcorrected(1);
denom = GammatoT(Vcorrected(1))*GammatoT(-Vcorrected(1)); % T_{01}*T{10}

for i=2:length(Vmeasured)
    Vcorrected(i) = (Vmeasured(i) - subtrahend) / denom;
    subtrahend = subtrahend + Vcorrected(i)*denom; % Update the subtrahend
    denom = denom*...
        GammatoT(Vcorrected(i))*GammatoT(-Vcorrected(i));
end

Vcorrected = circshift(Vcorrected,-1);

end

function T = GammatoT(gamma)    
% Convert reflection coefficient to transmission coefficient
T = 1 + gamma;
end