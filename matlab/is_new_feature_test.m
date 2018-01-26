% is_new_feature test

data = table();

% Trivial example
data.duplicate_group = {'null'; 'a'; 'b'; 'b'};
result = is_new_feature(data);
assert(sum(result)==3);

% Treat nulls correctly
data.duplicate_group = {'null'; 'null'; 'b'; 'b'};
result = is_new_feature(data);
assert(sum(result)==3);

% When the data are not sorted
data.duplicate_group = {'a'; 'b'; 'b'; 'a'};
result = is_new_feature(data);
assert(sum(result)==2);

% Another example
data.duplicate_group = {'null'; 'b'; 'b'; 'null'};
result = is_new_feature(data);
assert(sum(result)==3);

% A single record
data = table();
data.duplicate_group = {'a'};
result = is_new_feature(data);
assert(sum(result)==1);

% Empty table
data = table();
result = is_new_feature(data);
assert(sum(result)==0);

% Large amount of data
data = table();
data.duplicate_group = repmat({'a'; 'b'; 'c'; 'd'}, 1000, 1);
result = is_new_feature(data);
assert(sum(result)==4);

% Make sure we do not compare presence of characters but equality of
% strings
data = table();
data.duplicate_group =  {'ATT_CLASSES_count_100007A'; 'ATT_CLASSES_count_100007'};
result = is_new_feature(data);
assert(sum(result)==2);
