%% Add Outside Path
addpath('..');
%% Init Variables
Prefix = 'baseline_distributions/';
Caption = 'Average Error On F8 For Different Quantum Distributions, 31 Runs';
LogNames = {'mQSO-10(5+5)-bug', 'mQSO-10(5+5)-uniform', ...
            'mQSO-10(5+5)-cauchy-0.5', 'mQSO-10(5+5)-gaissian-0.33'};
TitleNames = {'mQSO-10(5+5)-Bug', 'mQSO-10(5+5)-Uniform', ...
              'mQSO-10(5+5)-Cauchy-0.5', 'mQSO-10(5+5)-Gaissian-0.33'};
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
    LatexTable = LatexTable + sprintf('    %d & %s & $%.3f$ & ', i, TitleNames{i}, Numbers(i, 1));
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
Utils.WriteFile(fullfile('Results', 'CompareDistributions.tex'), LatexTable);