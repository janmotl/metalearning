% Fit beta cdf to the data. If the data are not in 0..1 range, they are
% automatically scaled into 0..1 range with min-max normalization, the
% cdf is fitted, and scaled back into the original range.
% 
% Example:
%     [random_curve, lower, upper, x] = ci(obtained, 100); 
% 
%     upperSmooth = cdfBetaSmoothing(x, upper);
%     lowerSmooth = cdfBetaSmoothing(x, lower);
%     random_curveSmooth = cdfBetaSmoothing(x, random_curve);


function ySmoothed=cdfBetaSmoothing(x,y)

% Normalization
xNorm = (x-min(x))/(max(x)-min(x));
yNorm = (y-min(y))/(max(y)-min(y));

% Fit a model to the data.
func = @(fit,xdata)betacdf(xdata,fit(1),fit(2));
param = lsqcurvefit(func,[0.9 1.1],xNorm,yNorm);

% Smooth the data
ySmoothed = betacdf(xNorm, param(1), param(2)) * (max(y)-min(y)) + min(y);
