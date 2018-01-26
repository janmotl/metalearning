% RQ: Do we have to calculate other features but the landmarking?
% Data: see RQ_doWeNeedComplexFeatures.xslx
% Conclusion: meta-learning does not work well on CORA and WebKP database because
% there is not a single landmarking feature.

% Setting
databaseNames = {'Accidents', 'AustralianFootball', 'Basketball_men', 'Biodegradability', 'Carcinogenesis', 'ccs', 'Chess', 'CORA', 'financial', 'Hepatitis_std', 'Mondial', 'mutagenesis', 'nations', 'PremierLeague', 'PTE', 'Student_loan', 'VisualGenome', 'Walmart', 'WebKP', 'world'};
databaseNames = {'world'};



% Logger
logger = [];

% Loop
for i=1:length(databaseNames)
    databaseName = databaseNames{i};

    % Get metadata and data
    setdbprefs('DataReturnFormat','table');
    conn = database('ctu_meta','guest','relational',...
        'Vendor','MySQL', ...
        'Server','relational.fit.cvut.cz');

    sql = strcat('SELECT t1.table_schema, t1.feature, t1.chi2, t1.chi2_prediction, t2.run_time, t2.run_time_prediction, t3.is_duplicate, t3.is_duplicate_prediction, chi2_prediction/run_time_prediction AS weight, t4.table_column_name from prediction_chi2 t1 join prediction_runtime t2 using(table_schema, feature) JOIN prediction_duplication t3 using (table_schema, feature) JOIN raw_metadata t4 using(table_schema, feature), (select max(chi2) as chi2_max from prediction_chi2 where table_schema = "', databaseName, '") tmax WHERE table_schema = "', databaseName, '" AND t1.chi2 < 0.98*tmax.chi2_max AND t3.is_duplicate = ''false'' and pattern_name in ("Aggregate", "Aggregate WOE", "Count", "Direct field", "Time aggregate", "Time since", "WOE") ORDER BY chi2_prediction/run_time_prediction DESC');
    metaSimple = fetch(conn, sql);
    if isempty(metaSimple) 
        error(['meta is empty: ' sql]);
    end

    sql = strcat('SELECT t1.table_schema, t1.feature, t1.chi2, t1.chi2_prediction, t2.run_time, t2.run_time_prediction, t3.is_duplicate, t3.is_duplicate_prediction, chi2_prediction/run_time_prediction AS weight, t4.table_column_name from prediction_chi2 t1 join prediction_runtime t2 using(table_schema, feature) JOIN prediction_duplication t3 using (table_schema, feature) JOIN raw_metadata t4 using(table_schema, feature), (select max(chi2) as chi2_max from prediction_chi2 where table_schema = "', databaseName, '") tmax WHERE table_schema = "', databaseName, '" AND t1.chi2 < 0.98*tmax.chi2_max AND t3.is_duplicate = ''false'' ORDER BY chi2_prediction/run_time_prediction DESC');
    metaAll = fetch(conn, sql);
    if isempty(metaAll) 
        error(['meta is empty: ' sql]);
    end

    sql = strcat('select * from ms_', databaseName, ' where propagated_target is not null');
    data = fetch(conn, sql);
    if isempty(data) 
        error(['data is empty: ' sql]);
    end

    close(conn)

    %% Define target 
    y = data.propagated_target;

    %% Get list of simple features

    % Remove schema prefix
    metaSimple.feature = strrep(metaSimple.feature, strcat(databaseName, '_'), '');

    featureIndexesSimple = [];
    for feature = metaSimple.feature'
        new = find(strcmp(data.Properties.VariableNames, feature));
        featureIndexesSimple = [featureIndexesSimple; new];
    end

    %% Get accuracy on simple features

    % Dummy encoding, all columns are predictors 
    x = classreg.regr.modelutils.designmatrix(data(:, featureIndexesSimple), 'PredictorVars', 1:length(featureIndexesSimple)); 

    % Train a model
    model = fitctree(x, y, 'CrossVal', 'on');
    classificationErrorSimple = kfoldLoss(model, 'LossFun', 'ClassifErr');

    %% Get list of all features

    % Remove schema prefix
    metaAll.feature = strrep(metaAll.feature, strcat(databaseName, '_'), '');

    featureIndexesAll = [];
    for feature = metaAll.feature'
        new = find(strcmp(data.Properties.VariableNames, feature));
        featureIndexesAll = [featureIndexesAll; new];
    end

    %% Get accuracy on all features    

    % Dummy encoding, all columns are predictors 
    x = classreg.regr.modelutils.designmatrix(data(:, featureIndexesAll), 'PredictorVars', 1:length(featureIndexesAll)); 

    % Train a model
    model = fitctree(x, y, 'CrossVal', 'on');
    classificationErrorAll = kfoldLoss(model, 'LossFun', 'ClassifErr');
    
    %% Log it
    logger = [logger; [classificationErrorAll, classificationErrorSimple]]
end
   
% Display the result
table(databaseNames, logger)
