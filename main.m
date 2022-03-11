%*****IEEE CEC 2022 Competition on Dynamic Optimization Problems Generated by Generalized Moving Peaks Benchmark******
%Author: Danial Yazdani
%Last Edited: December 06, 2021
%
% ------------
% Reference:
% ------------
%
%  D. Yazdani et al.,
%            "Benchmarking Continuous Dynamic Optimization: Survey and Generalized Test Suite,"
%            IEEE Transactions on Cybernetics (2020).
% 
%  D. Yazdani et al.,
%            "Generalized Moving Peaks Benchmark," arXiv:2106.06174, (2021).
%
%  T. Blackwell and J. Branke,
%            "Multiswarms, exclusion, and anti-convergence in dynamic environments"
%            IEEE Transactions on Evolutionary Computation (2006).
% ------------
% Notification:
% ------------
% This code solves Generalized Moving Peaks Benchmark (GMPB) by mQSO.
% It is assumed that the environmental changes are VISIBLE, therefore,
% mQSO is informed about changes (i.e., mQSO does not need to detect
% environmental changes). Also note that mQSO does not access to a prior knowledge
% about the shift severity value. The shift severity is learned in this code.
%
%
% -------
% Inputs:
% -------
%
%    The Participants can set peak number, change frequency, dimension,
%    and shift severity in lines 59-62 of "main.m" according to the
%    competition instractions available in the following link:
%
%                 https://www.danialyazdani.com/CEC-2022
%
%
% ------------
% Output:
% ------------
%
% Offline error
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% Author: Danial Yazdani
% e-mail: danial.yazdani AT gmail dot com
%         danial.yazdani AT yahoo dot com
% Copyright notice: (c) 2021 Danial Yazdani
%*********************************************************************************************************************
%% Sub Folder
addpath('./ThirdParty/WorkerObjWrapper');
%% Init variables
CurrentSummary = Summary( ...
...
    'mQSO-5(10+5)', ... % LogPathName
    'main.log', ... % DFileName
    100, ... % EnvironmentNumber
    31, ... % RunNumber
    (1:14), ... % IndependentProblems
    true, ... % Rerun
    true ... % SimpleLog
);
disp(CurrentSummary);
%% Init log file
CurrentSummary.InitLogFile();
%% Logs
disp(['Start time: ', datestr(now)]);
TAStart = tic;

%% Independent Run Parallel
for index = 1:length(CurrentSummary.IndependentProblems)
    ProblemNum = CurrentSummary.IndependentProblems(index);
    ProblemRun(ProblemNum, CurrentSummary, true);
end

%% Finish
CurrentSummary.Finish();

%% Logs
disp(['End time: ', datestr(now)]);
disp(['Total time: ', num2str(toc(TAStart))]);

%% Function Definitions
function ProblemRun(ProblemNum, CurrentSummary, IfParallel)
    RunNumber = CurrentSummary.RunNumber;
    disp(['Problem Number: ', num2str(ProblemNum), ' Runnumber: ', num2str(RunNumber)]);

    function UpdateOfflineError(x)
        RunCounter = x(1);
        ElapsedTime = x(2);
        CurrentError = x(3:end);
        CurrentSummary.ProblemOfflineErrors(ProblemNum, RunCounter) = mean(CurrentError);
        CurrentSummary.ProblemElapsedTimes(ProblemNum, RunCounter) = ElapsedTime;
        CurrentSummary.WriteLogs(ProblemNum, RunCounter, CurrentError);
        disp(['Offline Error Updated (Run: ', num2str(x(1)), ').']);
    end

    if IfParallel
        D = parallel.pool.DataQueue;
        D.afterEach(@(x) UpdateOfflineError(x));
        W = WorkerObjWrapper(CurrentSummary.ProblemOfflineErrors(ProblemNum, :));

        parfor RunCounter = 1:RunNumber
            ErrorArray = W.Value;

            if ~isnan(ErrorArray(RunCounter)) && ~CurrentSummary.Rerun
                disp(['Problem: ', num2str(ProblemNum), ' Run: ', num2str(RunCounter), sprintf('\t'), 'already finished.']);
                continue;
            end

            TStart = tic;
            CurrentError = IndependentRun(ProblemNum, RunCounter, CurrentSummary);
            TEnd = toc(TStart);
            send(D, [RunCounter, TEnd, CurrentError]);
        end

    else

        for RunCounter = 1:RunNumber

            if ~isnan(CurrentSummary.ProblemOfflineErrors(ProblemNum, RunCounter))
                disp(['Problem: ', num2str(ProblemNum), ' Run: ', num2str(RunCounter), sprintf('\t'), 'already finished.']);
                continue;
            end

            TStart = tic;
            CurrentError = IndependentRun(ProblemNum, RunCounter, CurrentSummary);
            TEnd = toc(TStart);
            CurrentSummary.ProblemElapsedTimes(ProblemNum, RunCounter) = TEnd;
            CurrentSummary.ProblemOfflineErrors(ProblemNum, RunCounter) = mean(CurrentError);
            CurrentSummary.WriteLogs(ProblemNum, RunCounter, CurrentError);
        end

    end

end

function CurrentError = IndependentRun(ProblemNum, RunCounter, CurrentSummary)
    PeakNumber = CurrentSummary.PeakNumbers(ProblemNum);
    ChangeFrequency = CurrentSummary.ChangeFrequencys(ProblemNum);
    Dimension = CurrentSummary.Dimensions(ProblemNum);
    ShiftSeverity = CurrentSummary.ShiftSeveritys(ProblemNum);
    EnvironmentNumber = CurrentSummary.EnvironmentNumber;
    rng(RunCounter); %This random seed setting is used to initialize the Problem-This must be identical for all peer algorithms to have a fair comparison.
    Problem = BenchmarkGenerator(PeakNumber, ChangeFrequency, Dimension, ShiftSeverity, EnvironmentNumber);
    rng('shuffle'); %Set a random seed for the optimizer based on the system clock
    %% Initialiing Optimizer
    clear Optimizer;
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.PopulationSize = 10;
    Optimizer.MaxCoordinate = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.DiversityPlus = 1;
    Optimizer.x = 0.729843788;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ShiftSeverity = 1;
    Optimizer.QuantumRadius = Optimizer.Dimension * Optimizer.Dimension * Optimizer.ShiftSeverity;
    Optimizer.QuantumNumber = 5;
    Optimizer.SwarmNumber = 5;
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate - Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber)^(1 / Optimizer.Dimension)));
    Optimizer.ConvergenceLimit = Optimizer.ExclusionLimit;
    if ~CurrentSummary.OptimizerLog
        disp(Optimizer);
    end
    CurrentSummary.OptimizerLog = true;

    for ii = 1:Optimizer.SwarmNumber
        [Optimizer.pop(ii), Problem] = InitializingOptimizer(Optimizer.Dimension, Optimizer.MinCoordinate, Optimizer.MaxCoordinate, Optimizer.PopulationSize, Problem);
    end
    tic;
    %% main loop
    while 1
        [Optimizer, Problem] = Optimization(Optimizer, Problem);

        if Problem.RecentChange == 1 %When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer, Problem] = Reaction(Optimizer, Problem);
            clc; disp(['Run number: ', num2str(RunCounter), '   Environment number: ', num2str(Problem.Environmentcounter), ' counter:', num2str(RunCounter), ' PROBLEM NUMBER: ', num2str(ProblemNum)]);
            toc;
            tic;
        end

        if Problem.FE >= Problem.MaxEvals %When termination criteria has been met
            break;
        end

    end    

    CurrentError = Problem.CurrentError;
end
