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
% PSO每个子�?�群演化一代，包括子�?�群移动，�?�样性维持，子�?�群收敛判断
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    %     if Optimizer.pop(ii).Active==1
    Optimizer.pop(ii).Velocity = Optimizer.x * (Optimizer.pop(ii).Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSize , Optimizer.Dimension).*(Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X)) + (Optimizer.c2*rand(Optimizer.PopulationSize , Optimizer.Dimension).*(repmat(Optimizer.pop(ii).BestPosition,Optimizer.PopulationSize,1) - Optimizer.pop(ii).X)));
    % RandomChoose = rand(Optimizer.PopulationSize, 1) < 0.1 * normalize(Optimizer.pop(ii).FitnessValue, 'norm', 1);
    % Optimizer.pop(ii).Velocity(RandomChoose, :) = 0.5 * normrnd(0, 1, size(Optimizer.pop(ii).Velocity(RandomChoose, :)));

    % RandomChoose = rand(size(Optimizer.PopulationSize)) < 0.1;
    % Optimizer.pop(ii).Velocity(RandomChoose) = normrnd(0, 1, size(Optimizer.pop(ii).Velocity(RandomChoose)));

    % RandomChoose = rand(size(Optimizer.PopulationSize)) < 0.05;
    % Optimizer.pop(ii).Velocity(RandomChoose) = Optimizer.pop(ii).Velocity(RandomChoose) + 0.5*tan(pi*(rand(size(Optimizer.pop(ii).Velocity(RandomChoose)))-1/2));

    % RandomChoose = rand(Optimizer.PopulationSize, 1) < 0.1;
    % Optimizer.pop(ii).Velocity(RandomChoose, :) = 0.5 * normrnd(0, 1, size(Optimizer.pop(ii).Velocity(RandomChoose, :)));
    Optimizer.pop(ii).X = Optimizer.pop(ii).X + Optimizer.pop(ii).Velocity;%更新pop(ii)�?所有个体的坐标
    for jj=1 : Optimizer.PopulationSize%防�??�?体越过上下界
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
    [tmp,Problem] = fitness(Optimizer.pop(ii).X,Problem);%评估pop(ii)所有个体fitness
    if Problem.RecentChange == 1
        return;
    end
    Optimizer.pop(ii).FitnessValue = tmp;
    for jj=1 : Optimizer.PopulationSize%更新pbest
        if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
            Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
            Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
        end
    end
    [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
    if BestPbestValue>Optimizer.pop(ii).BestValue%更新gbest
        Optimizer.pop(ii).BestValue = BestPbestValue;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
    end
    %     end
    for jj=1 : Optimizer.QuantumNumber
        %QuantumPosition = Optimizer.pop(ii).BestPosition + rands(1,Optimizer.Dimension)*Optimizer.QuantumRadius;
        QuantumPosition = Optimizer.pop(ii).BestPosition + rand(1,Optimizer.Dimension)*Optimizer.QuantumRadius;
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
        if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit%两子种群gbest距�?�太近时，初始化表现�?的子种群
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
    if Radius<Optimizer.ConvergenceLimit%判断子�?�群�?否收�?
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
if IsAllConverged == Optimizer.SwarmNumber%重新初�?�化子�?�群
    [Optimizer.pop(WorstSwarmIndex),Problem] = InitializingOptimizer(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
end