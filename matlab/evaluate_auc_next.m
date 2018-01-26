% Subroutine for evaluate_auc - returns the next best feature
function [nextFeature, meta, map] = evaluate_auc_next(meta, map, alpha)
    % Regular ranking 
    meta.fitness_prediction = meta.chi2_prediction./meta.run_time_prediction;% rand(height(meta),1);%  %  ; %1./meta.run_time_prediction; %  % meta.chi2_prediction ./ meta.run_time_prediction;
    
    % Duplication penalization (Note: we use a fixed threshold to avoid drifting)
    for row=1:height(meta)
        if meta.is_duplicate_prediction(row) >= 0.5
            meta.fitness_prediction(row) = meta.fitness_prediction(row) * (1-meta.is_duplicate_prediction(row));
        end
    end

    % Redundancy penalization
    for i=1:height(meta)
        meta.penalization(i) = alpha * map(meta.table_column_name{i});
    end
    meta.fitness_prediction = meta.fitness_prediction - meta.penalization;
    
    % Sort based on the fitness
    meta = sortrows(meta, 'fitness_prediction', 'descend');
    
    % Return the best feature
    nextFeature = meta(1,:);
    
    % Remove the best feature from the pool
    meta(1,:) = [];
    
    % Increment the counter
    map(nextFeature.table_column_name{:}) = map(nextFeature.table_column_name{:}) + 1;
end