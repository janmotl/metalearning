% Evaluation of the anytime algorithm based on the AUC.


%% Get metadata and data
setdbprefs('DataReturnFormat','table');
conn = database('ctu_meta','guest','relational',...
    'Vendor','MySQL', ...
    'Server','relational.fit.cvut.cz');
sql = 'SELECT t1.table_schema, t1.feature, t1.chi2, t1.chi2_prediction, t2.run_time, t2.run_time_prediction, t3.is_duplicate, t3.is_duplicate_prediction, chi2_prediction/run_time_prediction AS weight, t4.table_column_name from prediction_chi2 t1 join prediction_runtime t2 using(table_schema, feature) JOIN prediction_duplication t3 using (table_schema, feature) JOIN raw_metadata t4 using(table_schema, feature) WHERE table_schema = ''financial'' AND t1.chi2 <> 1 AND t3.is_duplicate = ''false'' ORDER BY chi2_prediction/run_time_prediction DESC';
meta = fetch(conn, sql);
sql = 'select * from ms_financial';
data = fetch(conn, sql);
close(conn)

%% Meta 
meta.feature = strrep(meta.feature, 'financial_', ''); % Remove schema prefix
meta.penalization = nan(height(meta), 1);
meta.fitness_prediction = nan(height(meta), 1);
bkp = meta;

%% Loop
y = data.propagated_target;
% loops = height(meta);
loops = 2;
alpha = 1;
classificationError = nan(loops,1);
features = {};
meta = bkp;

table_column_names = unique(meta.table_column_name);
nameMap = containers.Map(table_column_names, zeros(size(table_column_names)));

for i=1:loops
%     features = meta.feature(1:i); % Old blind approach
    [nextFeature, meta, nameMap] = evaluate_auc_next(meta, nameMap, alpha);
    features(i) = nextFeature.feature;
    
    % Dummy encoding, all columns are predictors 
    [x,~,~,~,colnames] = classreg.regr.modelutils.designmatrix(data(:, features), 'PredictorVars', 1:i); 
    tree = fitctree(x, y, 'MinLeafSize', 3);
    classificationError(i) = cvloss(tree);
    
    [i features(i) classificationError(i) nextFeature.fitness_prediction]
    if classificationError(i)<0.2
        break;
    end
    
%     view(tree,'Mode','graph')
end

%% Plot 
% 1: district_A2
% 2: loan_duration
% 10: order_account_to_aggregate_stddev_samp
% 78th feature 'trans_amount_aggregate_stddev_samp_100004' is important!
clf
plot(classificationError, 'b.-')
hold on
plot(meta.chi2, 'r.-')
plot(meta.run_time, 'k.-')

legend('classification error', 'chi2', 'runtime')
xlabel('count of features')
ylabel('classification error')
title('effect of anytime propositionalization on accuracy')
% 
% %% Diversity plot
% [v, cnt] = unique(meta.table_column_name(1:78));
% 
% barh(cnt)
% set(gca, 'yTick', 1:length(v))
% set(gca, 'yTickLabel', strrep(v, '_', '.'))


