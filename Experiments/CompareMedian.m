%% Add Outside Path
addpath('..');
%% Init Variables
Caption = 'Average Error on IEEE CEC 2022 Competition on DOPs For Mean Shift and Median Shift, 31 Runs';
LogNames = {'mQSO-5(15+3)', 'mQSO-5(15+3)-median'};
TitleNames = {'Mean', 'Median'};
Abbreviation = {'MEA', 'MED'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, Abbreviation);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareMedian.tex'), LatexTable);