% RQ: How many features (in percentage of all features) do we have to 
% calculate to get misclassification equal to misclassification on the 
% whole tree?
% Data: see RQ_howManyFeatures.xslx

% Setting
databaseNames = {'Accidents', 'AustralianFootball', 'Basketball_men', 'Biodegradability', 'Carcinogenesis', 'ccs', 'Chess', 'CORA', 'financial', 'Hepatitis_std', 'Mondial', 'mutagenesis', 'nations', 'PremierLeague', 'PTE', 'Student_loan', 'VisualGenome', 'Walmart', 'WebKP', 'world'};
databaseNames = {'Accidents', 'Biodegradability', 'financial', 'Hepatitis_std', 'mutagenesis', 'Student_loan'};

% Logger
logger = [];

% Loop
for i=1:length(databaseNames)
    databaseName = databaseNames{i};
    [classificationError, features] = evaluate_auc_parametrized(databaseName, 0.02, 0);
    optimumPercentage = 100*find(classificationError<=classificationError(end), 1 ) / length(classificationError);
    
    % Log it
    logger = [logger; optimumPercentage];
    
    % Plot
    clf
    plot(classificationError)
    xlabel('Count of features')
    ylabel('Misclassification error')
    title(sprintf('%s Optimum reached at %.1f%%', databaseName, optimumPercentage))
    
    % Export
    set(gcf, 'PaperPosition', [0 0.05 5 3]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    set(gcf, 'PaperSize', [5 3.05]); %Keep the same paper size
    saveas(gcf, ['performance_profile_', databaseName, '.pdf'], 'pdf')
end

table(databaseNames(1:length(logger))', logger)