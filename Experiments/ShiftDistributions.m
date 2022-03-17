MaxClipValue = 130;
ShiftValues = importdata(fullfile('..', 'logs', 'baseline_shifts', 'ShiftValues.dat'));
%% Clip Large Value
ShiftValues(ShiftValues > MaxClipValue) = [];
%% Plot Distribution
h = histfit(ShiftValues, 10, 'gamma');
set(h(1),'facecolor','#ace6f6');
set(h(2),'color','#446491');
%% Plot Mean Line & Median Line
MeanLine = line([mean(ShiftValues), mean(ShiftValues)], ylim, 'LineWidth', 2, 'Color', '#114b5f', 'LineStyle','--');
MedianLine = line([median(ShiftValues), median(ShiftValues)], ylim, 'LineWidth', 2, 'Color', '#fe5f55', 'LineStyle','--');
legend([MeanLine MedianLine], 'Mean', 'Median');
%% Save As PDF
set(gcf, 'PaperPosition', [0 0 7 5]);
set(gcf, 'PaperSize', [7 5]);
xlabel('Shift Value');
ylabel('Frequence');
saveas(gcf, fullfile('Results', 'ShiftDistributions.pdf'));