%% Bug Distribution VS. Fixed Distribution
%% VS. Gaussian Distribution VS. Cauchy Distribution
SamplePointNumber = 100;
Dimension = 2;
PointSize = 12;
OffsetSize = 0.08;
CenterPoint = zeros(1, Dimension);
Colors = {'#f9a852'; '#f07654'; '#ee4c58'; '#2f7bbd'};
Titles = {'Bug Sample', 'Uniform Sample', 'Gaussian Sample', 'Cauchy Sample'};

RndPoints = NaN(4, SamplePointNumber, Dimension);
RndPoints(1,:,:) = CenterPoint + rand(SamplePointNumber, Dimension); % BugPoints
RndPoints(2,:,:) = CenterPoint + (rand(SamplePointNumber, Dimension) * 2 - 1); % FixedPoints
RndPoints(3,:,:) = CenterPoint + (1/3) * normrnd(0, 1, SamplePointNumber, Dimension); % GaussianPoints
RndPoints(4,:,:) = CenterPoint + 0.5 * trnd(1, SamplePointNumber, Dimension); % CauchyPoints

for i = 1:4
    subplot1 = subplot(2,2,i);
    scatter(RndPoints(i, :, 1), RndPoints(i, :, 2), PointSize, 'filled', 'MarkerFaceColor', Colors{i});
    xlim(subplot1, [-1.5 1.5]);
    ylim(subplot1, [-1.5 1.5]);
    xlabel('x');
    ylabel('y');
    grid on;
    t = title(sprintf('SubPlot %d: %s', i, Titles{i}));
    set(t,'position',get(t,'position')+[0 OffsetSize 0])
end

set(gcf, 'PaperPosition', [0 0 5 5]);
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, fullfile('Results', 'Distributions.pdf'));