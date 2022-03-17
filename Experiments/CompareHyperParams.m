%% Add Outside Path
addpath('..');
%% Init Variables
Prefix = 'baseline_hyper/';
Caption = 'Average Error On F8 For Different Hyper-Parameters, 31 Runs';
LogNames = {'mQSO-10(5+5)', 'mQSO-20(3+2)', ...
            'mQSO-5(10+10)', 'mQSO-5(10+5)', ...
            'mQSO-5(5+10)', 'mQSO-5(15+3)'};
Numbers = NaN(length(LogNames), 2);
LatexTable = "";
LatexTable = LatexTable + sprintf('\\begin{table}\n');
LatexTable = LatexTable + sprintf('  \\centering\n');
LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
LatexTable = LatexTable + sprintf('  \\begin{tabular}{|c|l|c|c|}\n');
LatexTable = LatexTable + sprintf('    \\hline\n');
LatexTable = LatexTable + sprintf('    Index & \\multicolumn{1}{c|}{Configuration} & Average & Compare to Baseline \\\\\n');
LatexTable = LatexTable + sprintf('    \\hline\n');
for i = 1:length(LogNames)
    CurrentSummary = Utils.GetSummary(strcat(Prefix,LogNames{i}));
    Numbers(i, 1) = mean(CurrentSummary.ProblemOfflineErrors(8,:));
    Numbers(i, 2) = (1 - Numbers(i, 1) / Numbers(1, 1)) * 100;
    if i == 4 || i == 6 ; LatexTable = LatexTable + sprintf('    \\hline\n'); end
    LatexTable = LatexTable + sprintf('    %d & %s & $%.3f$ & ', i, LogNames{i}, Numbers(i, 1));
    if i == 1
        LatexTable = LatexTable + sprintf('0\\%%');
    else
        if Numbers(i, 2) > 0; LatexTable = LatexTable + sprintf('+'); end
        LatexTable = LatexTable + sprintf('%.2f\\%%', Numbers(i, 2));
    end
    LatexTable = LatexTable + sprintf('\\\\\n');
end
LatexTable = LatexTable + sprintf('    \\hline\n');
LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
LatexTable = LatexTable + sprintf('\\end{table}\n');
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('Results', 'CompareHyperParams.tex'), LatexTable);