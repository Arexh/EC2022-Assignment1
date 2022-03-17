classdef Summary < handle

    properties
        LogPath;
        DFile;
        EnvironmentNumber;
        RunNumber;
        IndependentProblems;
        ProblemOfflineErrors;
        ProblemElapsedTimes;
        Rerun;
        SimpleLog;
        OptimizerLog;
    end

    properties (Constant = true)
        PeakNumbers = [5, 10, 25, 50, 100, 10, 10, 10, 10, 10, 10, 10, 1, 10];
        ChangeFrequencys = [5000, 5000, 5000, 5000, 5000, 2500, 1000, 500, 5000, 5000, 5000, 5000, 5000, 5000];
        Dimensions = [5, 5, 5, 5, 5, 5, 5, 5, 10, 20, 5, 5, 5, 2];
        ShiftSeveritys = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 5, 1, 1];
        ProblemTotalNum = 14;
    end

    methods

        function obj = Summary(LogPathName, ...
                DFileName, EnvironmentNumber, ...
                RunNumber, IndependentProblems, ...
                Rerun, SimpleLog) %¹¹Ôìº¯Êý
            obj.LogPath = fullfile('.', 'logs', LogPathName);
            obj.DFile = fullfile(obj.LogPath, DFileName);
            obj.EnvironmentNumber = EnvironmentNumber;
            obj.RunNumber = RunNumber;
            obj.IndependentProblems = IndependentProblems;
            obj.ProblemOfflineErrors = NaN(obj.ProblemTotalNum, RunNumber);
            obj.ProblemElapsedTimes = NaN(obj.ProblemTotalNum, RunNumber);
            obj.Rerun = Rerun;
            obj.SimpleLog = SimpleLog;
            obj.OptimizerLog = false;
        end

        function InitLogFile(obj)
            diary off;
            if ~exist(obj.LogPath, 'dir'); mkdir(obj.LogPath); end
            obj.CreateSubFolder('running_time');
            obj.CreateSubFolder('offline_error');
            obj.CreateSubFolder('summary');
            obj.CreateSubFolder('all_offline_error');
            obj.CreateSubFolder('all_offline_error_plot');
            obj.CreateSubFolder('quantum_radius');

            for index = 1:length(obj.IndependentProblems)
                obj.CreateSubFolder(fullfile('all_offline_error', sprintf('F%d', obj.IndependentProblems(index))));
                obj.CreateSubFolder(fullfile('all_offline_error_plot', sprintf('F%d', obj.IndependentProblems(index))));
            end

            if exist(obj.DFile, 'file'); delete(obj.DFile); end
            diary(obj.DFile);
            diary on;
            if ~obj.Rerun
                obj.ReadOfflineError();
                obj.ReadElapsedTime();
            end
        end

        function Finish(obj)
            diary off;
            obj.ReadOfflineError();
            obj.ReadElapsedTime();
            obj.WriteAllSummary();
        end

        function CreateSubFolder(obj, FolderName)
            if ~exist(fullfile(obj.LogPath, FolderName), 'dir'); mkdir(fullfile(obj.LogPath, FolderName)); end
        end

        function ReadOfflineError(obj)

            for index = 1:length(obj.IndependentProblems)
                ProblemNum = obj.IndependentProblems(index);
                obj.ProblemOfflineErrors(ProblemNum, :) = obj.ReadProblemOfflineError(ProblemNum);
            end

        end

        function ReadElapsedTime(obj)

            for index = 1:length(obj.IndependentProblems)
                ProblemNum = obj.IndependentProblems(index);
                obj.ProblemElapsedTimes(ProblemNum, :) = obj.ReadProblemElapsedTime(ProblemNum);
            end

        end

        function [OutputFile] = GetOutputFile(obj, ProblemNum)
            OutputFile = fullfile(obj.LogPath, 'offline_error', sprintf('F%d.dat', ProblemNum));
        end

        function [ElapsedTimeFile] = GetElapsedTimeFile(obj, ProblemNum)
            ElapsedTimeFile = fullfile(obj.LogPath, 'running_time', sprintf('F%d.dat', ProblemNum));
        end

        function [SummaryFile] = GetSummaryFile(obj, ProblemNum)
            SummaryFile = fullfile(obj.LogPath, 'summary', sprintf('F%d.log', ProblemNum));
        end

        function [AllOfflineErrorFile] = GetAllOfflineErrorFile(obj, ProblemNum, RunCounter)
            AllOfflineErrorFile = fullfile(obj.LogPath, 'all_offline_error', sprintf('F%d', ProblemNum), sprintf('%d.dat', RunCounter));
        end

        function [AllOfflineErrorPlotFile] = GetAllOfflineErrorPlotFile(obj, ProblemNum, RunCounter)
            AllOfflineErrorPlotFile = fullfile(obj.LogPath, 'all_offline_error_plot', sprintf('F%d', ProblemNum), sprintf('%d', RunCounter));
        end

        function [OfflineError] = ReadProblemOfflineError(obj, ProblemNum)
            OuputFile = obj.GetOutputFile(ProblemNum);

            if exist(OuputFile, "file")
                OfflineError = Summary.ReadFile(OuputFile);

                if size(OfflineError, 2) ~= obj.RunNumber
                    OfflineError = NaN(1, obj.RunNumber);
                end

            else
                OfflineError = NaN(1, obj.RunNumber);
            end

        end

        function [ElapsedTime] = ReadProblemElapsedTime(obj, ProblemNum)
            ElapsedTimeFile = obj.GetElapsedTimeFile(ProblemNum);

            if exist(ElapsedTimeFile, "file")
                ElapsedTime = Summary.ReadFile(ElapsedTimeFile);

                if size(ElapsedTime, 2) ~= obj.RunNumber
                    ElapsedTime = NaN(1, obj.RunNumber);
                end

            else
                ElapsedTime = NaN(1, obj.RunNumber);
            end

        end

        function WriteOfflineError(obj, ProblemNum)
            Summary.WriteFile(obj.GetOutputFile(ProblemNum), obj.ProblemOfflineErrors(ProblemNum, :));
        end

        function WriteElapsedTime(obj, ProblemNum)
            Summary.WriteFile(obj.GetElapsedTimeFile(ProblemNum), obj.ProblemElapsedTimes(ProblemNum, :));
        end

        function WriteSummary(obj, ProblemNum)
            f = fopen(obj.GetSummaryFile(ProblemNum), 'w');
            fprintf(f, obj.GetProblemSummary(ProblemNum));
            fclose(f);
        end

        function WriteAllSummary(obj)
            f = fopen(fullfile(obj.LogPath, 'summary.log'), 'w');

            for index = 1:length(obj.IndependentProblems)
                ProblemNum = obj.IndependentProblems(index);
                fprintf(f, obj.GetProblemSummary(ProblemNum));
                fprintf('\n');
            end

            fprintf(f, 'Approx Total Time: %f', sum(obj.ProblemElapsedTimes(~isnan(obj.ProblemElapsedTimes))) / 8);
            fprintf(f, '\n--------------------- Optimizer ---------------------\n');
            % fprintf(f, sprintf('%s', obj.Optimizer));
            fprintf(f, '\n--------------------- Optimizer ---------------------\n');
            fclose(f);
        end

        function WriteAllOfflineError(obj, ProblemNum, RunCounter, AllOfflineError)
            Summary.WriteFile(obj.GetAllOfflineErrorFile(ProblemNum, RunCounter), AllOfflineError)
        end

        function WriteQuantumRadius(obj, ProblemNum, RunCounter, RadiusList)
            Summary.WriteFile(fullfile(obj.LogPath, 'quantum_radius', sprintf('F%d_%d.dat', ProblemNum, RunCounter)), RadiusList);
        end

        function PlotAllOfflineError(obj, ProblemNum, RunCounter, AllOfflineError)
            figure('visible', 'off');
            plot(AllOfflineError);
            print(obj.GetAllOfflineErrorPlotFile(ProblemNum, RunCounter), '-dpng');
        end

        function [SummaryString] = GetProblemSummary(obj, ProblemNum)
            NonNaNErrors = obj.ProblemOfflineErrors(ProblemNum, ~isnan(obj.ProblemOfflineErrors(ProblemNum, :)));
            NonNaNTimes = obj.ProblemElapsedTimes(ProblemNum, ~isnan(obj.ProblemElapsedTimes(ProblemNum, :)));
            FormatString = '--------------------- Problem %d ---------------------\n';
            FormatString = append(FormatString, 'Best: %f\n');
            FormatString = append(FormatString, 'Worst: %f\n');
            FormatString = append(FormatString, 'Average: %f\n');
            FormatString = append(FormatString, 'Median: %f\n');
            FormatString = append(FormatString, 'Standard Deviation: %f\n');
            FormatString = append(FormatString, 'Average Time: %f\n');
            FormatString = append(FormatString, 'Approx Total Time (Parallel): %f\n');
            FormatString = append(FormatString, '--------------------- Problem %d ---------------------\n');
            SummaryString = sprintf(FormatString, ProblemNum, ...
                min(NonNaNErrors), max(NonNaNErrors), ...
                mean(NonNaNErrors), median(NonNaNErrors), ...
                std(NonNaNErrors) / sqrt(obj.RunNumber), ...
                mean(NonNaNTimes), sum(NonNaNTimes) / 8, ...
                ProblemNum);
        end

        function WriteLogs(obj, ProblemNum, RunCounter, CurrentError)
            obj.WriteOfflineError(ProblemNum);
            obj.WriteElapsedTime(ProblemNum);
            obj.WriteSummary(ProblemNum);
            obj.PlotAllOfflineError(ProblemNum, RunCounter, CurrentError);
            if ~obj.SimpleLog
                obj.WriteAllOfflineError(ProblemNum, RunCounter, CurrentError);
            end
        end

    end

    methods (Static)
        %% Util Function
        function WriteFile(OuputFile, Content)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%f ', Content);
            fclose(f);
        end

        function [OfflineError] = ReadFile(OuputFile)
            OfflineError = str2double(split(fileread(OuputFile)));
            OfflineError = OfflineError.';
            OfflineError = OfflineError(1:end - 1);
        end

    end

end
