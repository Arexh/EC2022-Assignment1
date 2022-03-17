%% Add Outside Path
addpath('..');
%% Init Variables
Caption = 'Average Error on IEEE CEC 2022 Competition on DOPs For Bug Distribution and Gaussian Distribution, 31 Runs';
LogNames = {'baseline', 'mQSO-5(15+15)-median-Qnorm-lazy-adaptive'};
TitleNames = {'Baseline', 'Ours'};
Abbreviation = {'B', 'O'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResultsComplete(Caption, LogNames, TitleNames, Abbreviation);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareBaseline.tex'), LatexTable);