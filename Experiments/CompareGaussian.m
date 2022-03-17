%% Add Outside Path
addpath('..');
%% Init Variables
Caption = 'Average Error on IEEE CEC 2022 Competition on DOPs For Bug Distribution and Gaussian Distribution, 31 Runs';
LogNames = {'mQSO-5(15+3)-median', 'mQSO-5(15+3)-median-Qnorm'};
TitleNames = {'Bug', 'Gaussian'};
Abbreviation = {'B', 'G'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, Abbreviation);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareGaussian.tex'), LatexTable);