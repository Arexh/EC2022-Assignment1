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
function [Optimizer , Problem] = Optimization(Optimizer,Problem)
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    %     if Optimizer.pop(ii).Active==1
    Optimizer.pop(ii).Velocity = Optimizer.x * (Optimizer.pop(ii).Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSize , Optimizer.Dimension).*(Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X)) + (Optimizer.c2*rand(Optimizer.PopulationSize , Optimizer.Dimension).*(repmat(Optimizer.pop(ii).BestPosition,Optimizer.PopulationSize,1) - Optimizer.pop(ii).X)));
    Optimizer.pop(ii).X = Optimizer.pop(ii).X + Optimizer.pop(ii).Velocity;
    for jj=1 : Optimizer.PopulationSize
        for kk=1 : Optimizer.Dimension
            if Optimizer.pop(ii).X(jj,kk) > Optimizer.MaxCoordinate
                Optimizer.pop(ii).X(jj,kk) = Optimizer.MaxCoordinate;
                Optimizer.pop(ii).Velocity(jj,kk) = 0;
            elseif Optimizer.pop(ii).X(jj,kk) < Optimizer.MinCoordinate
                Optimizer.pop(ii).X(jj,kk) = Optimizer.MinCoordinate;
                Optimizer.pop(ii).Velocity(jj,kk) = 0;
            end
        end
    end 
    [tmp,Problem] = fitness(Optimizer.pop(ii).X,Problem);
    if Problem.RecentChange == 1
        return;
    end
    Optimizer.pop(ii).FitnessValue = tmp;
    for jj=1 : Optimizer.PopulationSize
        if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
            Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
            Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
        end
    end
    [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
    if BestPbestValue>Optimizer.pop(ii).BestValue
        Optimizer.pop(ii).BestValue = BestPbestValue;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
    end
    %     end
    for jj=1 : Optimizer.QuantumNumber
        %QuantumPosition = Optimizer.pop(ii).BestPosition + rands(1,Optimizer.Dimension)*Optimizer.QuantumRadius;
        QuantumPosition = Optimizer.pop(ii).BestPosition + 0.5 * normrnd(0, 1, 1,Optimizer.Dimension)*Optimizer.QuantumRadius;
        for kk=1 : Optimizer.Dimension
            if QuantumPosition > Optimizer.MaxCoordinate
                QuantumPosition(kk) = Optimizer.MaxCoordinate;
            elseif QuantumPosition < Optimizer.MinCoordinate
                QuantumPosition(kk) = Optimizer.MinCoordinate;
            end
        end
        [QuantumFitnessValue,Problem] = fitness(QuantumPosition,Problem);
        if Problem.RecentChange == 1
            return;
        end
        if QuantumFitnessValue > Optimizer.pop(ii).BestValue
            Optimizer.pop(ii).BestValue = QuantumFitnessValue;
            Optimizer.pop(ii).BestPosition = QuantumPosition;
        end
    end
end
%% Exclusion
for ii=1 : Optimizer.SwarmNumber-1
    for jj=ii+1 : Optimizer.SwarmNumber
        if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit
            if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                [Optimizer.pop(ii),Problem] = InitializingOptimizer(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                if Problem.RecentChange == 1
                    return;
                end
            else
                [Optimizer.pop(jj),Problem] = InitializingOptimizer(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                if Problem.RecentChange == 1
                    return;
                end
            end
        end
    end
end
%% Anti Convergence

IsAllConverged = 0;
WorstSwarmValue = inf;
WorstSwarmIndex = [];
for ii=1 : Optimizer.SwarmNumber
    Radius = 0;
    for jj=1 : Optimizer.PopulationSize
        for kk=1 : Optimizer.PopulationSize
            Radius = max(Radius,max(abs(Optimizer.pop(ii).X(jj,:)-Optimizer.pop(ii).X(kk,:))));
        end
    end
    if Radius<Optimizer.ConvergenceLimit
        Optimizer.pop(ii).IsConverged = 1;
    else
        Optimizer.pop(ii).IsConverged = 0;
    end
    IsAllConverged = IsAllConverged + Optimizer.pop(ii).IsConverged;
    if Optimizer.pop(ii).BestValue < WorstSwarmValue
        WorstSwarmValue = Optimizer.pop(ii).BestValue;
        WorstSwarmIndex = ii;
    end
end
if IsAllConverged == Optimizer.SwarmNumber
    [Optimizer.pop(WorstSwarmIndex),Problem] = InitializingOptimizer(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
end