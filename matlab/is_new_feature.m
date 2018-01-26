% Decide whether a feature is new feature or a duplicate to some previously
% calculated feature. The decision is based on the order of rows in the 
% table and duplicate_group attribute.


function result=is_new_feature(input)
    % The first row is always new
    result = ones(height(input), 1);
    
    % Create an empty set of already observed duplicate_groups
    previously_observed = [];

    for row=1:height(input)
        % Features without any duplicate are always new.
        if strcmp(input.duplicate_group{row}, 'null')
            continue;
        end
        
        % If the current duplicate_group was already observed,
        % it is not a new feature.
        if ismember(input.duplicate_group{row}, previously_observed)
            result(row)=0;
        else
            previously_observed = [previously_observed, input.duplicate_group(row)];
        end
    end
end