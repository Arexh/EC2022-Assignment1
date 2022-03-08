classdef Summary

    properties
        LogPath;
        DFile;
        EnvironmentNumber;
        RunNumber;
        ParallelProblems;
        IndependentProblems;
        ProblemOfflineErrors;
        ProblemElapsedTimes;
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
                RunNumber, ParallelProblems, IndependentProblems) %¹¹Ôìº¯Êý
            obj.LogPath = fullfile('.', 'logs', LogPathName);
            obj.DFile = fullfile(obj.LogPath, DFileName);
            obj.EnvironmentNumber = EnvironmentNumber;
            obj.RunNumber = RunNumber;
            obj.ParallelProblems = ParallelProblems;
            obj.IndependentProblems = IndependentProblems;
            obj.ProblemOfflineErrors = NaN(obj.ProblemTotalNum, RunNumber);
            obj.ProblemElapsedTimes = NaN(obj.ProblemTotalNum, RunNumber);
        end

        function InitLogFile(obj)
            diary off;
            if ~exist(obj.LogPath, 'dir'); mkdir(obj.LogPath); end
            obj.createSubFolder('running_time');
            obj.createSubFolder('offline_error');
            obj.createSubFolder('summary');
            obj.createSubFolder('all_offline_error');
            obj.createSubFolder('all_offline_error_plot');
            for index = 1:obj.ProblemTotalNum
                obj.createSubFolder(fullfile('all_offline_error', sprintf('F%d', index)));
                obj.createSubFolder(fullfile('all_offline_error_plot', sprintf('F%d', index)));
            end
            if exist(obj.DFile, 'file'); delete(obj.DFile); end
            diary(obj.DFile);
            diary on;
            obj.ReadOfflineError();
            obj.ReadElapsedTime();
        end

        function createSubFolder(obj, FolderName)
            if ~exist(fullfile(obj.LogPath, FolderName), 'dir'); mkdir(fullfile(obj.LogPath, FolderName)); end
        end

        function ReadOfflineError(obj)

            for index = 1:length(obj.ParallelProblems)
                ProblemNum = obj.ParallelProblems(index);
                obj.ProblemOfflineErrors(ProblemNum, :) = obj.ReadProblemOfflineError(ProblemNum);
            end

            for index = 1:length(obj.IndependentProblems)
                ProblemNum = obj.IndependentProblems(index);
                obj.ProblemOfflineErrors(ProblemNum, :) = obj.ReadProblemOfflineError(ProblemNum);
            end

        end

        function ReadElapsedTime(obj)

            for index = 1:length(obj.ParallelProblems)
                ProblemNum = obj.ParallelProblems(index);
                obj.ProblemElapsedTimes(ProblemNum, :) = obj.ReadProblemElapsedTime(ProblemNum);
            end

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

                if size(OfflineError, 1) ~= obj.RunNumber
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

                if size(ElapsedTime, 1) ~= obj.RunNumber
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
            NotNaNElements = obj.ProblemOfflineErrors(ProblemNum, ~isnan(obj.ProblemOfflineErrors(ProblemNum, :)));
            fprintf(f, '--------------------- Problem %d ---------------------\n', ProblemNum);
            fprintf(f, 'Best: %f\n', min(NotNaNElements));
            fprintf(f, 'Worst: %f\n', max(NotNaNElements));
            fprintf(f, 'Average: %f\n', mean(NotNaNElements));
            fprintf(f, 'Median: %f\n', median(NotNaNElements));
            fprintf(f, 'Standard Deviation: %f\n', std(NotNaNElements) / sqrt(obj.RunNumber));
            fprintf(f, 'Average Time for One Run: %f\n', mean(obj.ProblemElapsedTimes(ProblemNum, ~isnan(obj.ProblemElapsedTimes(ProblemNum, :)))));
            fprintf(f, '--------------------- Problem %d ---------------------\n', ProblemNum);
            fprintf(f, '\n');
            fclose(f);
        end

        function WriteAllOfflineError(obj, ProblemNum, RunCounter, AllOfflineError)
            Summary.WriteFile(obj.GetAllOfflineErrorFile(ProblemNum, RunCounter), AllOfflineError)
        end

        function PlotAllOfflineError(obj, ProblemNum, RunCounter, AllOfflineError)
            figure('visible','off');
            plot(AllOfflineError);
            print(obj.GetAllOfflineErrorPlotFile(ProblemNum, RunCounter), '-dpng');
        end

    end

    methods (Static)
        %% Util Function
        function WriteFile(OuputFile, OfflineError)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%f ', OfflineError);
            fclose(f);
        end

        function [OfflineError] = ReadFile(OuputFile)
            OfflineError = str2double(split(fileread(OuputFile)));
            OfflineError = OfflineError(1:end - 1);
        end

    end

end
