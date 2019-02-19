function out=writescv(varargin)
if nargin == 0
[filem,pathname] = uigetfile('*.mat');
currentdir = cd(pathname);
load(filem);
M = [time' Area' AspectRatio' Roundness' Solidity' Displacement' AvgStress' ...
    AvgRStress' MaxStress' MaxRStress' totalForce' totalRForce' StrainEnergy'];
csvwrite([filem,'.csv'],M,1,1);
out=cd(currentdir);
else
    return
end
end
