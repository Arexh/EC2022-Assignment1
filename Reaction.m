%*********************************mQSO*****************************************
%Author: Danial Yazdani
%Last Edited: June 03, 2021
%
% ------------
% Reference:
% ------------
%  T. Blackwell and J. Branke,
%            "Multiswarms, exclusion, and anti-convergence in dynamic environments"
%            IEEE Transactions on Evolutionary Computation (2006).
% 
%**********************************************************************************
function [Optimizer,Problem] = Reaction(Optimizer,Problem)
%% Updating Shift Severity
dummy = NaN(Optimizer.SwarmNumber,Problem.EnvironmentNumber);
for jj=1 : Optimizer.SwarmNumber
    if sum(isnan(Optimizer.pop(jj).Gbest_past_environment))==0
        Optimizer.pop(jj).Shifts = [Optimizer.pop(jj).Shifts , pdist2(Optimizer.pop(jj).Gbest_past_environment,Optimizer.pop(jj).BestPosition)];
    end
    dummy(jj,1:length(Optimizer.pop(jj).Shifts)) = Optimizer.pop(jj).Shifts;
end
dummy = dummy(~isnan(dummy(:)));
if ~isempty(dummy)
    Optimizer.ShiftSeverity = mean(dummy);
end
Optimizer.QuantumRadius = Optimizer.ShiftSeverity;
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
    [Optimizer.pop(jj).PbestValue,Problem] = fitness(Optimizer.pop(jj).PbestPosition , Problem);
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    [Optimizer.pop(jj).BestValue,BestPbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).PbestPosition(BestPbestID,:);
    Optimizer.pop(jj).IsConverged = 0;
end
end