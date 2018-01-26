% evaluate auc controller - Is it useful to support diversity of features
% during feature selection?

clc
databaseName = 'financial';
[classificationErrorBlind, featuresBlind] = evaluate_auc_parametrized(databaseName, 0.02, 0);
[classificationError, features] = evaluate_auc_parametrized(databaseName, 0.02, 1);

% Plot
clf
plot(classificationErrorBlind, 'b.-')
hold on
plot(classificationError, 'r.-')
legend('blind', 'penalized')
xlabel('count of features')
ylabel('misclassification error')

% Export
[trapz(classificationErrorBlind), trapz(classificationError)]

%% Add random baseline
logger = nan(40, length(classificationError));

for repeat=2:20
    [classificationErrorRandom, featuresRandom] = evaluate_auc_random_baseline(databaseName, 0.02);
    logger(repeat, :) = classificationErrorRandom';
end

% Plot
clf
plot(classificationErrorBlind, 'b.-')
hold on
plot(classificationError, 'r.-')
plot(nanmean(logger), 'k.-')
legend('anytime', 'anytime penalized', 'random', 'random expected')
xlabel('count of features')
ylabel('misclassification error')
title(databaseName)

% Fit 
ft = fittype( 'exp2' ); % I don't know why but a sum of 2 exponentials looks reasonably. Power2 has overly odd confidence intervals. 2 Gausians work as well.
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [0.12 -0.22 0.87 -0.0003]; % Remarkably generalize across databases

% Fit model to data.
[fitresult, gof] = fit( (1:size(logger,2))', nanmean(logger)', ft, opts );

% Plot fit with data.
h = plot(fitresult, 'g.');

% Export
[trapz(classificationErrorRandom), trapz(classificationErrorBlind), trapz(classificationError)]


%% Normalization
% Calculate shared maximum
maximum = max(class)

nblind = (classificationErrorBlind-min(classificationErrorBlind))/(max(classificationErrorBlind)-min(classificationErrorBlind));

clf
plot(0:1/328:1, nblind, 'b.-')
hold on
plot(0:1/328:1, classificationError, 'r.-')
plot(nanmean(logger), 'k.-')
legend('anytime', 'anytime penalized', 'random', 'random expected')
xlabel('count of features')
ylabel('misclassification error')
title(databaseName)