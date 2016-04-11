function [Times, Step, riseTimeIdx] = StepMaker(deltat,onTime,dur)
% function [RCTimes, RCStep] = RCStepMaker(deltat,riseTime,duration)
% Times - time array
% Step - output (generated step)
% riseTimeIdx - time when the pulse jumps
Step = zeros(floor(dur/deltat),1);
Times = linspace(0,dur,floor(dur/deltat))';
riseTimeIdx = floor((dur-onTime)/(2*deltat));
Step(riseTimeIdx:riseTimeIdx+floor(onTime/deltat)) = ones(1,length(floor(onTime/deltat)));
end