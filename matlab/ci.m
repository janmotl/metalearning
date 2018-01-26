% Estimate the random curve and it's empirical 95% prediction interval.
% The input table has to contain {chi2, run_time, duplicate_group}.
%
% Example:
%   [median, lower, upper, x] = ci(obtained, 10);
%   clf
%   h = ciplot(lower, upper, x);
%   set(h, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none');
%   hold on
%   plot(x, median, 'r');
%   plot([0; x(end)], [0; median(end)], 'k');
  
function [median, lower, upper, x] = ci(obtained, repeats)
    % Initialization
    relevance = nan(repeats, height(obtained)+1); % We add 0 to the beginning
    
    % Loop
    for i=1:repeats        
        % Generate random order of execution
        obtained.fitness_prediction = randperm(height(obtained))';  

        % We calculate features in the descending order of the estimated fitness
        obtained = sortrows(obtained, 'fitness_prediction', 'descend');

        % But in the end, we will evaluate this ordering based on the true {chi2,
        % run_time, duplication}. Hence, we have to calculate, which are the new
        % features.
        obtained.is_new = is_new_feature(obtained);
        
        % Store the actual fitness of this ordering
        relevance(i,:) = [0; cumsum(obtained.is_new .* obtained.chi2)]';
    end

    % Calculate the statistics
    median = prctile(relevance, 50);
    lower = prctile(relevance, 5);
    upper = prctile(relevance, 95);
    
    % Calculate x axis (we approximate the reality with equal spaced events)
    sumx = sum(obtained.run_time);
    x = 0:sumx/height(obtained):sumx;
end