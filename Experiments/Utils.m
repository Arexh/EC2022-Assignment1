%% Util Functions
classdef Utils
    methods(Static)
        function CurrentSummary = GetSummary(LogPathName)
            CurrentSummary = Summary( ...
            ...
                LogPathName, ... % LogPathName
                'main.log', ... % DFileName
                100, ... % EnvironmentNumber
                31, ... % RunNumber
                (1:14), ... % IndependentProblems
                false, ... % Rerun
                true ... % SimpleLog
            );
            CurrentSummary.LogPath = fullfile('..', 'logs', LogPathName);
            CurrentSummary.DFile = fullfile(CurrentSummary.LogPath, 'main.log');
            CurrentSummary.InitLogFile();
            diary off;
        end

        function LatexTable = CompareTwoResults(Caption, LogNames, TitleNames, Abbreviation)
            ProblemNum = 14;
            Numbers = NaN(ProblemNum, 5);
            Errors = NaN(2, ProblemNum, 31);
            DaggerFlag = false;
            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table}\n');
            LatexTable = LatexTable + sprintf('  \\centering\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{c|rr|rr|r|r}\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multirow{2}{*}{ Problem } & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multirow{2}{*}{ARI} & \\multirow{2}{*}{\\shortstack{%s-%s\\\\t-test}} \\\\\n', TitleNames{1}, TitleNames{2}, Abbreviation{1}, Abbreviation{2});
            LatexTable = LatexTable + sprintf('    \\cline{2-5}\n');
            LatexTable = LatexTable + sprintf('    & Mean & Std & Mean & Std & \\\\\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            for i = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{i});
                Errors(i, :, :) = CurrentSummary.ProblemOfflineErrors;
                Numbers(:, 2 * i - 1) = mean(CurrentSummary.ProblemOfflineErrors, 2);
                Numbers(:, 2 * i) = std(CurrentSummary.ProblemOfflineErrors, 0, 2);
            end
            for i = 1:ProblemNum
                Numbers(i, end) = (1 - Numbers(i, 3) / Numbers(i, 1)) * 100;
                [h,~,~,stat] = ttest2(Errors(1, i, :), Errors(2, i, :), 0.05, 'both');
                if stat.df ~= 60 ; error('FOD error!'); end
                LatexTable = LatexTable + sprintf('    F%d & $%.2f$ & $%.2f$ & $%.2f$ & $%.2f$ & $', i, Numbers(i, 1), Numbers(i, 2), Numbers(i, 3), Numbers(i, 4));
                if Numbers(i, 5) > 0; sprintf('+'); end
                LatexTable = LatexTable + sprintf('%.1f\\%%$', Numbers(i, 5));
                LatexTable = LatexTable + sprintf('& %.2f', stat.tstat);
                if h == 1 ; LatexTable = LatexTable + sprintf('$^\\dagger$'); DaggerFlag = true; end
                LatexTable = LatexTable + sprintf('\\\\\n');
            end
            LatexTable = LatexTable + sprintf('    \\hline\n');
            if DaggerFlag
                LatexTable = LatexTable + sprintf('    \\multicolumn{7}{c}{}\\\\');
                LatexTable = LatexTable + sprintf('    \\multicolumn{7}{l}{\\shortstack{$^\\dagger$A significant $t$ value of a two-tailed test with 60 degrees of freedom \\\\and $\\alpha=0.05$.}}\\\\');
            end
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('\\end{table}');
        end

        function LatexTable = CompareTwoResultsComplete(Caption, LogNames, TitleNames, Abbreviation)
            ProblemNum = 14;
            Numbers = NaN(ProblemNum, 2 * 5 + 1);
            Errors = NaN(2, ProblemNum, 31);
            DaggerFlag = false;
            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table*}\n');
            LatexTable = LatexTable + sprintf('  \\centering\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{c|rrrrr|rrrrr|r|r}\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multirow{2}{*}{Problem} & \\multicolumn{5}{c|}{%s} & \\multicolumn{5}{c|}{%s} & \\multirow{2}{0.6cm}{ARI} & \\multirow{2}{0.6cm}{\\shortstack{%s-%s\\\\t-test}} \\\\\n', TitleNames{1}, TitleNames{2}, Abbreviation{1}, Abbreviation{2});
            LatexTable = LatexTable + sprintf('    \\cline{2-11}\n');
            LatexTable = LatexTable + sprintf('    & \\multicolumn{1}{c}{Best} & \\multicolumn{1}{c}{Worst} & \\multicolumn{1}{c}{Average} & \\multicolumn{1}{c}{Median} & \\multicolumn{1}{c|}{Std} & \\multicolumn{1}{c}{Best} & \\multicolumn{1}{c}{Worst} & \\multicolumn{1}{c}{Average} & \\multicolumn{1}{c}{Median} & \\multicolumn{1}{c|}{Std} & & \\\\');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            for i = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{i});
                Errors(i, :, :) = CurrentSummary.ProblemOfflineErrors;
                Numbers(:, 5 * (i - 1) + 1) = min(CurrentSummary.ProblemOfflineErrors, [], 2);
                Numbers(:, 5 * (i - 1) + 2) = max(CurrentSummary.ProblemOfflineErrors, [], 2);
                Numbers(:, 5 * (i - 1) + 3) = mean(CurrentSummary.ProblemOfflineErrors, 2);
                Numbers(:, 5 * (i - 1) + 4) = median(CurrentSummary.ProblemOfflineErrors, 2);
                Numbers(:, 5 * (i - 1) + 5) = std(CurrentSummary.ProblemOfflineErrors, 0, 2);
            end
            for i = 1:ProblemNum
                Numbers(i, end) = (1 - Numbers(i, 8) / Numbers(i, 3)) * 100;
                [h,~,~,stat] = ttest2(Errors(1, i, :), Errors(2, i, :), 0.05, 'both');
                if stat.df ~= 60 ; error('FOD error!'); end
                LatexTable = LatexTable + sprintf('    F%d &', i);
                for j = 1:10 ; LatexTable = LatexTable + sprintf(' $%.2f$ &', Numbers(i, j)); end
                if Numbers(i, 5) > 0; sprintf('+'); end
                LatexTable = LatexTable + sprintf('$%.2f\\%%$', Numbers(i, 11));
                LatexTable = LatexTable + sprintf('& %.2f', stat.tstat);
                if h == 1 ; LatexTable = LatexTable + sprintf('$^\\dagger$'); DaggerFlag = true; end
                LatexTable = LatexTable + sprintf('\\\\\n');
            end
            LatexTable = LatexTable + sprintf('    \\hline\n');
            if DaggerFlag
                LatexTable = LatexTable + sprintf('    \\multicolumn{13}{c}{}\\\\');
                LatexTable = LatexTable + sprintf('    \\multicolumn{13}{l}{\\shortstack{$^\\dagger$A significant $t$ value of a two-tailed test with 60 degrees of freedom and $\\alpha=0.05$.}}\\\\');
            end
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('\\end{table*}');
        end

        function WriteFile(OuputFile, Content)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%s', Content);
            fclose(f);
        end
    end
end