%% Add Outside Path
addpath('..');
%% Init Variables
Caption = 'Average Error on IEEE CEC 2022 Competition on DOPs For Non-Adaptive and Adaptive, 31 Runs';
LogNames = {'mQSO-5(15+15)-median-Qnorm-lazy', 'mQSO-5(15+15)-median-Qnorm-lazy-adaptive'};
TitleNames = {'Non-Adaptive', 'Adaptive'};
Abbreviation = {'NA', 'A'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, Abbreviation);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareAdative.tex'), LatexTable);