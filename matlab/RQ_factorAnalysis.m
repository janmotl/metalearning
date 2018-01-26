% RQ: What is the contribution of chi2, relevance and duplication models?
% Data: see factorAnalysis.xslx
% Conclusion: see factorAnalysis.r

% Setting
databaseNames = {'Accidents', 'AustralianFootball', 'Basketball_men', 'Biodegradability', 'Carcinogenesis', 'ccs', 'Chess', 'CORA', 'financial', 'Hepatitis_std', 'Mondial', 'mutagenesis', 'nations', 'PremierLeague', 'PTE', 'Student_loan', 'VisualGenome', 'Walmart', 'WebKP', 'world'};
databaseNames = {'mutagenesis'};

% Logger
logger = [];

% Loop
for i=1:length(databaseNames)
    databaseName = databaseNames{i};

    % Get optimal ordering and the predicted ordering of the features for
    % the given database.
    [optimal, obtained] = anytimeLearning(databaseName, true, true, false);
    
    % Random curve
    % We correct for the bias due to duplication. But since the correction
    % is based on simulation, it is slow.
    [random_curve, lower_pi, upper_pi, x] = ci(obtained, 100);    
%     x = [0; sum(optimal.run_time)];
%     random_curve = [0; sum(optimal.is_new .* optimal.chi2)];
    
    
    % Get KI - "percent of perfect"
    pop = ki([0; cumsum(optimal.run_time)],...
             [0; cumsum(optimal.is_new .* optimal.chi2)],...
             [0; cumsum(obtained.run_time)],...
             [0; cumsum(obtained.is_new .* obtained.chi2)],...
             x,...
             random_curve);

    % Log
    logger = [logger; pop];
         
    % Plot
    clf
    plot([0; cumsum(optimal.run_time)], [0; cumsum(optimal.is_new .* optimal.chi2)], 'linewidth', 2)
    hold on
    plot([0; cumsum(obtained.run_time)], [0; cumsum(obtained.is_new .* obtained.chi2)], 'k',  'linewidth', 2)
    plot(x, random_curve, 'r', 'linewidth', 2)
    legend({'optimal','obtained', 'random'}, 'Location', 'NorthWest', 'FontSize', 14)
    xlabel('runtime [s]', 'FontSize', 14)
    ylabel('cumsum(chi2)', 'FontSize', 14)
    title(sprintf('%s, KI=%0.3f', databaseName, pop), 'Interpreter', 'none')
    set(gca, 'FontSize',14)
    axis([0, sum(optimal.run_time), 0, sum(optimal.is_new .* optimal.chi2)])

    % Export
    set(gcf, 'PaperPosition', [0 0.05 5 3]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    set(gcf, 'PaperSize', [5 3.05]); %Keep the same paper size
    saveas(gcf, ['curve_', databaseName, '.pdf'], 'pdf')
end

mean(logger)
logger


% RQ1: How to deal with duplicates? Test multiple approaches.
%   median threshold with doubled penalization: 0.5162
%   median threshold with single penalization: 0.5127
%   0.5 threshold with single penalization: 0.5122
%   unconditional with single penalization: 0.5055
%   rand() threshold with doubled penalization: 0.4873
% Conclusion:
%   Median threshold with doubled penalization is the best (has highest 
%   average KI).



  
%% Fit the random_curve in its PI with Beta cdf
upperSmooth = cdfBetaSmoothing(x, upper_pi);
lowerSmooth = cdfBetaSmoothing(x, lower_pi);
random_curveSmooth = cdfBetaSmoothing(x, random_curve);  

% Plot
clf
plot([0; cumsum(optimal.run_time)], [0; cumsum(optimal.is_new .* optimal.chi2)], 'linewidth', 2)
hold on
hob = plot([0; cumsum(obtained.run_time)], [0; cumsum(obtained.is_new .* obtained.chi2)], 'linewidth', 2);
plot(x, random_curveSmooth, 'k', 'linewidth', 2)

% Prediction interval
h = ciplot(lowerSmooth, upperSmooth, x);
set(h, 'facecolor', [0.9 0.9 0.9], 'edgecolor', 'none');

% Diagonal
plot([0; x(end)], [0; random_curveSmooth(end)], '-.k');

xlabel('Runtime [s]', 'FontSize', 14)
ylabel('Relevance', 'FontSize', 14)
title(sprintf('%s, KI=%0.3f', databaseName, pop), 'Interpreter', 'none')
set(gca, 'FontSize',14)
axis([0, sum(optimal.run_time), 0, sum(optimal.is_new .* optimal.chi2)])
legend({'Perfect', 'Actual', 'Random', '95% PI', 'Diagonal'}, 'Location', 'SouthEast', 'FontSize', 14)
uistack(h,'bottom') % Move the prediction to the bottom
uistack(hob,'top') % Move the actual to the top

%% Get ki of the upper prediction interval
ki([0; cumsum(optimal.run_time)],...
             [0; cumsum(optimal.is_new .* optimal.chi2)],...
             x,...
             upperSmooth,...
             x,...
             random_curve)