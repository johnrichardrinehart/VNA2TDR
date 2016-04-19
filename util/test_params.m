freqs = 0:.01:10;
S11 = 1./(1+1i*freqs);
filter = kaiser(length(S11)*2-1,6);
filter = filter(.5*(length(filter)+1):end);
[times, step_response] = SParams2TDR(freqs,S11,'filter',filter);
figure(1);
plot(times,step_response,times,1-exp(-times));
figure(3);
plot(times,step_response./max(step_response),times,1-exp(-times))
figure(2);
[times, step_response] = SParams2TDR(freqs,S11);
plot(times,step_response,times,1-exp(-times))
