% KI Index - "the percent of perfect"
%
% Reference: Cumulative Gains Model Quality Metric (Brandenburger, 2009)
% 
% Example:
%   perfect_y = [0 0.4 0.7 0.9 0.95 1];
%   perfect_x = [0 0.2 0.4 0.6 0.8 1];
% 
%   actual_y = [0 0.3 0.55 0.75 0.875 1];
%   actual_x = [0 0.2 0.4 0.6 0.8 1];
% 
%   diagonal_y = [0 1];
%   diagonal_x = [0 1];
%
%   ki(perfect_x, perfect_y, actual_x, actual_y, diagonal_x, diagonal_y)
% 
%   %% Plot
%   clf
%   plot(perfect_x, perfect_y);
%   hold on
%   plot(actual_x, actual_y);
%   plot(diagonal_x, diagonal_y);
%   legend('perfect', 'actual', 'diagonal')

function result=ki(perfect_x, perfect_y, actual_x, actual_y, diagonal_x, diagonal_y)
    nominator = trapz(actual_x, actual_y) - trapz(diagonal_x, diagonal_y);
    denominator = trapz(perfect_x, perfect_y) - trapz(diagonal_x, diagonal_y);

    result = nominator/denominator;
end



