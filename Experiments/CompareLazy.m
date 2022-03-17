%% Add Outside Path
addpath('..');
%% Init Variables
Caption = 'Average Error on IEEE CEC 2022 Competition on DOPs For Non-Lazy and Lazy Strategy, 31 Runs';
LogNames = {'mQSO-5(15+3)-median-Qnorm', 'mQSO-5(15+15)-median-Qnorm-lazy'};
TitleNames = {'Non-Lazy', 'Lazy'};
Abbreviation = {'NL', 'L'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, Abbreviation);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareLazy.tex'), LatexTable);