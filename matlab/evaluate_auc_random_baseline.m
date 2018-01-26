% Parametrized evaluation of the anytime algorithm based on the AUC.
% Inputs: 
%   databaseName: name of the database
%   terminationThreshold: at what loss to terminate the search
%   alpha: penalization size for using the same attribute once again

function [classificationError, features] = evaluate_auc_random_baseline(databaseName, terminationThreshold)

% Get metadata and data
setdbprefs('DataReturnFormat','table');
conn = database('ctu_meta','guest','relational',...
    'Vendor','MySQL', ...
    'Server','relational.fit.cvut.cz');

sql = strcat('SELECT t1.table_schema, t1.feature, t1.chi2, t1.chi2_prediction, t2.run_time, t2.run_time_prediction, t3.is_duplicate, t3.is_duplicate_prediction, chi2_prediction/run_time_prediction AS weight, t4.table_column_name from prediction_chi2 t1 join prediction_runtime t2 using(table_schema, feature) JOIN prediction_duplication t3 using (table_schema, feature) JOIN raw_metadata t4 using(table_schema, feature) WHERE table_schema = "', databaseName, '" AND t1.chi2 < 0.98 AND t3.is_duplicate = ''false'' ORDER BY chi2_prediction/run_time_prediction DESC');
meta = fetch(conn, sql);
if isempty(meta) 
    error(['meta is empty: ' sql]);
end

sql = strcat('select * from ms_', databaseName, ' where propagated_target is not null');
data = fetch(conn, sql);
if isempty(data) 
    error(['data is empty: ' sql]);
end

close(conn)



% Remove schema prefix
meta.feature = strrep(meta.feature, strcat(databaseName, '_'), ''); 
meta.penalization = nan(height(meta), 1);
meta.fitness_prediction = nan(height(meta), 1);

% Counter for the attribute usage
table_column_names = unique(meta.table_column_name);
nameMap = containers.Map(table_column_names, zeros(size(table_column_names)));

% Loop
y = data.propagated_target;
loops = height(meta);
classificationError = nan(loops,1);

% Sort in random order
meta = meta(randperm(height(meta)),:);

for i=1:loops
    features = meta.feature(1:i);
       
    % Dummy encoding, all columns are predictors 
    x = classreg.regr.modelutils.designmatrix(data(:, features), 'PredictorVars', 1:i); 

    % Remove constant columns
%     x = x(:,any(diff(x,1)));
    
    % Remove almost constant columns
%     x = remove_almost_constant(x, y,3, 3);
    
    % Remove almost null columns
%     x = remove_almost_null(x);
    
    % Train a model
    model = fitctree(x, y, 'CrossVal', 'on');
    classificationError(i) = kfoldLoss(model, 'LossFun', 'ClassifErr');
    
    % Progress
    display([i features(i) classificationError(i)])
    
    % Stop once we approach optimum (for debuging and shorter runtime)
    if classificationError(i) < terminationThreshold
        break;
    end
end
end