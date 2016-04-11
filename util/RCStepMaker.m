function [RCTimes, RCStep, riseTimeIdx] = RCStepMaker(deltat,riseTime,dur)
% function [RCTimes, RCStep, riseTimeIdx] = RCStepMaker(deltat,riseTime,duration)
% deltat - time-domain spacing
% riseTime - 0-100 rise-time (not 10-90)
% riseTime
% dur - time duration of step

RCTimes = (0:deltat:dur)';
RCStep = ones(length(RCTimes),1);

[~,riseTimeIdx] = min(abs(RCTimes-riseTime));
W = 2*riseTime/pi;
RCStep(1:riseTimeIdx) = (sin(RCTimes(1:riseTimeIdx)/W)).^2;