% Test evaluate_auc_next

%% Get metadata and data
setdbprefs('DataReturnFormat','table');
conn = database('ctu_meta','guest','relational',...
    'Vendor','MySQL', ...
    'Server','relational.fit.cvut.cz');
sql = 'SELECT t1.table_schema, t1.feature, t1.chi2, t1.chi2_prediction, t2.run_time, t2.run_time_prediction, t3.is_duplicate, t3.is_duplicate_prediction, chi2_prediction/run_time_prediction AS weight, t4.table_column_name from prediction_chi2 t1 join prediction_runtime t2 using(table_schema, feature) JOIN prediction_duplication t3 using (table_schema, feature) JOIN raw_metadata t4 using(table_schema, feature) WHERE table_schema = ''financial'' AND t1.chi2 <> 1 AND t3.is_duplicate = ''false'' ORDER BY chi2_prediction/run_time_prediction DESC';
original = fetch(conn, sql);
close(conn)

%% Test 1
meta = original(1:78, :);
table_column_names = unique(meta.table_column_name(1:78));
map = containers.Map(table_column_names, zeros(size(table_column_names)));
alpha = 0.1;

assert(map('district_A2')==0)

[nextFeature, meta, map] = evaluate_auc_next(meta, map, alpha);
assert(strcmp(nextFeature.feature, 'financial_district_A2_woe_nominalColumn_C_100815'));
assert(map('district_A2')==1)

[nextFeature, meta, map] = evaluate_auc_next(meta, map, alpha);
assert(strcmp(nextFeature.feature, 'financial_loan_duration_directField_numericalColumn_100418'));
assert(map('district_A2')==1)
assert(map('loan_duration')==1)