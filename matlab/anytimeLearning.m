% Evaluate quality of an anytime learning based on the integral of 
% cumsum(chi2) over time.
% 
% Input:
%   1) The database name
%   2) A boolean whether to take into account the estimate of relevance
%   3) A boolean whether to take into account the estimate of runtime
%   4) A boolean whether to take into account the estimate of duplication
% 
% Output
%   1) A table with the optimal ranking
%   2) A table with the obtained ranking
%
% Example:
%   [optimal, obtained] = anytimeLearning('financial', true, true, true)
%   pop = ki([0; cumsum(optimal.run_time)],...
%            [0; cumsum(optimal.is_new .* optimal.chi2)],...
%            [0; cumsum(obtained.run_time)],...
%            [0; cumsum(obtained.is_new .* obtained.chi2)],...
%            [0; sum(optimal.run_time)],...
%            [0; sum(optimal.is_new .* optimal.chi2)]);

function [optimal, obtained] = anytimeLearning(databaseName, useRelevance, useRuntime, useDuplication)

    % Get the data
    setdbprefs('DataReturnFormat','table');
    conn = database('ctu_meta','guest','relational',...
        'Vendor','MySQL',...
        'Server','relational.fit.cvut.cz'); 
    sql = ['select * from prediction_chi2 join prediction_runtime using(TABLE_SCHEMA, feature) join prediction_duplication using(TABLE_SCHEMA, feature) where TABLE_SCHEMA = ''', databaseName, ''''];
    input = fetch(conn, sql);
    close(conn);
    
    % Get runtime from log(runtime+1)
    transformed = table();
    transformed.run_time = 10.^input.run_time-1;
    transformed.run_time_prediction = 10.^input.run_time_prediction-1;

    transformed.is_duplicate_prediction = input.is_duplicate_prediction;
    transformed.duplicate_group = input.duplicate_group;
    transformed.chi2 = input.chi2;
    transformed.chi2_prediction = input.chi2_prediction;

    
    %%% Optimal curve %%%
    optimal = transformed;

    % Under the ideal condition, we always calculate the quickest feature 
    % from each duplicate_group
    optimal = sortrows(optimal, {'duplicate_group', 'run_time'});
    optimal.is_new = is_new_feature(optimal);

    % Ideally, we calculate the duplicate features at the end
    optimal.fitness = optimal.is_new .* optimal.chi2./optimal.run_time;
    optimal = sortrows(optimal, 'fitness', 'descend');

    
    %%% Obtained curve %%%
    obtained = transformed;
    
    % If approptiate, apply relevance and runtime estimates to estimate fitness
    obtained.fitness_prediction = rand(height(obtained), 1);
    if (useRelevance)
        obtained.fitness_prediction = obtained.chi2_prediction;
    end
    if (useRuntime)
        obtained.fitness_prediction = obtained.fitness_prediction./obtained.run_time_prediction;
    end
    
    % A roullete - penalize the potential duplicate or not?
    if (useDuplication)
        for row=1:height(obtained)
            if obtained.is_duplicate_prediction(row) >= median(obtained.is_duplicate_prediction) %rand()
                obtained.fitness_prediction(row) = obtained.fitness_prediction(row) * (1-obtained.is_duplicate_prediction(row)*2);
            end
        end
    end
    
    % We calculate features in the descending order of the estimated fitness
    obtained = sortrows(obtained, 'fitness_prediction', 'descend');

    % But in the end, we will evaluate this ordering based on the true {chi2,
    % run_time, duplication}. Hence, we have to calculate, which are the new
    % features.
    obtained.is_new = is_new_feature(obtained);
end


