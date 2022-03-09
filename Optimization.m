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
function [Optimizer, Problem] = Optimization(Optimizer,Problem)
    %% Code From: https://github.com/haydenbanting/DE-Global-Numerical-Optimizer/blob/main/main.py
    ScaleFactor = 0.5;
    %% Loop All Individuals
    for i = 1:Optimizer.PopulationSize
        %% Parrent Selection
        DiffSet = setdiff(1:Optimizer.PopulationSize, i);
        SelectedParrents = Optimizer.pop(1).X(DiffSet(randperm(Optimizer.PopulationSize - 1, 3)), :);
        %% Differential Mutation
        Base = SelectedParrents(1, :);
        Perturbation = ScaleFactor * (SelectedParrents(2, :) - SelectedParrents(3, :));
        MutationIndividual = Base + Perturbation;
        %% Crossover
        DimentionSelection = rand(1, Optimizer.Dimension) < 0.1;
        Offspring = DimentionSelection .* Base + (1 - DimentionSelection) .* MutationIndividual;
        %% Prevent Overflow
        for kk=1 : Optimizer.Dimension
            if Offspring(kk) > Optimizer.MaxCoordinate
                Offspring(kk) = Optimizer.MaxCoordinate;
            elseif Offspring(kk) < Optimizer.MinCoordinate
                Offspring(kk) = Optimizer.MinCoordinate;
            end
        end
        %% Evaluation
        [OffspringFitness, Problem] = fitness(Offspring, Problem);
        if Problem.RecentChange == 1 ; return; end
        %% Elite Selection
        if OffspringFitness(1) > Optimizer.pop(1).FitnessValue(1)
            Optimizer.pop(1).X(i, :) = Offspring;
        end
    end
end