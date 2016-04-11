function Average = AverageScatteringParameters(SPars)
dimSPars = size(SPars);
for i = 1:dimSPars(3)
    S{i} = AlfredS2PToStructure(SPars(:,:,i),'dB','RI');
end
Average.S11 = 0; 
Average.S12 = 0;
Average.S21 = 0;
Average.S22 = 0;

for i = 1:length(S)
    Average.S11 = Average.S11 + S{i}.S11;
    Average.S12 = Average.S12 + S{i}.S12;
    Average.S21 = Average.S21 + S{i}.S21;
    Average.S22 = Average.S22 + S{i}.S22;
end

Average.Frequencies = SPars(:,1,1);
Average.S11 = Average.S11/length(S);
Average.S12 = Average.S12/length(S);
Average.S21 = Average.S21/length(S);
Average.S22 = Average.S22/length(S);