%% Add Outside Path
addpath('..');
ProblemNum = 14;
ColorText = '\cellcolor{lightgray!65}';
Caption = 'Average Offline Error on the IEEE CEC 2022 Competition on DOPs, 31 Runs';
%% Init Variables
LogNames = {'baseline', 'mQSO-5(10+5)', ...
            'mQSO-5(15+3)', ...
            'mQSO-5(15+3)-median', 'mQSO-5(15+3)-median-Qnorm', ...
            'mQSO-5(15+15)-median-Qnorm-lazy', 'mQSO-5(15+15)-median-Qnorm-lazy-adaptive'};
ConfigName = {'10(5+5)', '5(10+3)', '5(15+3)', ...
              'M', 'M-N', 'M-N-L', 'M-N-L-A'};
LatexTable = "";
Numbers = NaN(length(LogNames), ProblemNum + 1);
LatexTable = LatexTable + sprintf('\\begin{table*}\n');
LatexTable = LatexTable + sprintf('  \\centering\n');
LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
LatexTable = LatexTable + sprintf('  \\begin{tabular}{l|cccccccccccccc|c}\n');
LatexTable = LatexTable + sprintf('    Config & F1 & F2 & F3 & F4 & F5 & F6 & F7 & F8 & F9 & F10 & F11 & F12 & F13 & F14 & Avg \\\\\n');
LatexTable = LatexTable + sprintf('    \\hline\n');
for i = 1:length(LogNames)
    CurrentSummary = Utils.GetSummary(LogNames{i});
    MeanError = mean(CurrentSummary.ProblemOfflineErrors, 2);
    Numbers(i, :) = [mean(CurrentSummary.ProblemOfflineErrors, 2).', mean(MeanError, 'all')];
end
for i = 1:length(LogNames)
    if i == 4 ; LatexTable = LatexTable + sprintf('    \\hline\n'); end
    LatexTable = LatexTable + sprintf('    %s &', ConfigName{i});
    for j = 1:ProblemNum
        if min(Numbers(:, j)) == Numbers(i, j)
            LatexTable = LatexTable + sprintf(' %s$\\mathbf{%.2f}$ &', ColorText, Numbers(i, j));
        else
            LatexTable = LatexTable + sprintf(' $%.2f$ &', Numbers(i, j));
        end
    end
    if min(Numbers(:, end)) == Numbers(i, end)
        LatexTable = LatexTable + sprintf(' %s$\\mathbf{%.2f}$', ColorText, Numbers(i, end));
    else
        LatexTable = LatexTable + sprintf(' $%.2f$', Numbers(i, end));
    end
    LatexTable = LatexTable + sprintf('\\\\\n');
end
LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
LatexTable = LatexTable + sprintf('\\end{table*}\n');
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareAll.tex'), LatexTable);