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
% PSO姣忎釜瀛愮�嶇兢�?�斿寲涓�?浠ｏ紝鍖�?�?瀛愮�嶇兢绉诲姩锛屽�氭牱鎬х�?鎸侊紝瀛愮�嶇兢鏀舵暃鍒ゆ�?
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    %% Randomly pick 'PopulationSize' groups, each group contains three individuals
    RandomPicks = zeros(Optimizer.PopulationSize, 3);
    for jj = 1:Optimizer.PopulationSize
        RandomPicks(jj, :) = randperm(Optimizer.PopulationSize, 3);
    end
    %% Diff Evo
    NewPops = Optimizer.pop(ii).X(RandomPicks(:, 1), :);
    %% Prevent Overflow
    for jj=1 : Optimizer.PopulationSize
        for kk=1 : Optimizer.Dimension
            if NewPops(jj,kk) > Optimizer.MaxCoordinate
                NewPops(jj,kk) = Optimizer.MaxCoordinate;
            elseif NewPops(jj,kk) < Optimizer.MinCoordinate
                NewPops(jj,kk) = Optimizer.MinCoordinate;
            end
        end
    end
    %% Crossover
    CrossoverPick = rand(Optimizer.PopulationSize, Optimizer.Dimension) < 0.9;
    ParrentOnlyIndex = find(sum(CrossoverPick, 2)) == true;
    for i = ParrentOnlyIndex
        CrossoverPick(i, randi(Optimizer.Dimension)) = true;
    end
    NewPops = CrossoverPick .* NewPops + (1 - CrossoverPick) .* Optimizer.pop(ii).X;
    %% Evaluation
    [tmp,Problem] = fitness(NewPops,Problem);
    if Problem.RecentChange == 1
        return;
    end
    % if ii == 1
    %     disp(tmp);
    % end
    %% Selection
    % if ii == 1
    %     % disp(Optimizer.pop(ii).FitnessValue);
    %     % pause(0.1);
    %     disp(tmp);
    %     disp(Optimizer.pop(ii).FitnessValue);
    % end
    NextPops = Optimizer.pop(ii).X;
    NextFitness = Optimizer.pop(ii).FitnessValue;
    SelectedOffsprings = tmp > Optimizer.pop(ii).FitnessValue;
    NextPops(SelectedOffsprings) = NewPops(SelectedOffsprings);
    NextFitness(SelectedOffsprings) = tmp(SelectedOffsprings);
    Optimizer.pop(ii).FitnessValue = NextFitness;
    Optimizer.pop(ii).X = NextPops;
    for jj=1 : Optimizer.PopulationSize% Update pbset
        if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
            Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
            Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
        end
    end
    [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
    if BestPbestValue>Optimizer.pop(ii).BestValue% Update gbest
        Optimizer.pop(ii).BestValue = BestPbestValue;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
    end
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
        if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit% When two pop too close, init the worse one
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
    if Radius<Optimizer.ConvergenceLimit% Judge whether convergence
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
if IsAllConverged == Optimizer.SwarmNumber%閲嶆柊鍒濆��?寲瀛愮�嶇�?
    [Optimizer.pop(WorstSwarmIndex),Problem] = InitializingOptimizer(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
end