clear all; close all; clc;
%% loads pretrained models and calculates the predictor importance
addpath('../')
settings;
modelDir = opts.modelDir;
%% find the predictor importance across all decission tree models
subject_vars = zeros(3,73);
%% get the sum of predictor importance for all features across all models
for subject = 1:3
    for channel = 1:16
        model_name = sprintf('DT_%d_%d',subject,channel);
        load([modelDir filesep model_name]);
        % models were trained in 10 fold cross validation
        for ti = 1:10
            ctree = dt_model.Trained{ti};

            imp = predictorImportance(ctree);
            subject_vars(subject,:) = subject_vars(subject,:) + imp;
%%          uncomment this section to view tree as a graph (!caution! there is 160 models in the basic setup)
%             view(ctree, 'Mode', 'Graph');  
%             figure(1)
%             bar(imp)
%             pause(0.1)

        
        end
    end
end
%%
predictorNames = dt_model.PredictorNames;
number_of_best_predictors = 15;
%% Sort the predictors based on importance and display the best ones across all subjects
vars = sum(subject_vars);
[B,I] = sort(vars,'descend');
best_predictors = predictorNames(I);
fprintf('%d most important predictors across all subjects:\n', number_of_best_predictors);
fprintf('%s, ', best_predictors{1:number_of_best_predictors});
fprintf('\n\n');
%% Plot results
figure(10)
subplot(311)
bar(B(1:number_of_best_predictors)), set(gca,'XtickL',best_predictors(1:number_of_best_predictors))
title('Most important predictors across all models');
subplot(312)
bar(B), set(gca, 'XTick', 1:73, 'XtickL', best_predictors), axis tight
subplot(313)
bar(vars), set(gca, 'XTick', 1:73, 'XtickL', predictorNames), axis tight
%% Sort the predictors based on importance and display the best ones for each subject
for subject = 1:3
    vars = subject_vars(subject,:);
    [B,I] = sort(vars,'descend');
    best_predictors = predictorNames(I);
    fprintf('Subject %d - %d most important predictors:\n', subject, number_of_best_predictors);
    fprintf('%s, ', best_predictors{1:number_of_best_predictors});
    fprintf('\n\n');
    %% Plot results
    figure(subject)
    subplot(311)
    bar(B(1:number_of_best_predictors)), set(gca,'XtickL',best_predictors(1:number_of_best_predictors))
    title(sprintf('Subject %d - most important predictors', subject));
    subplot(312)
    bar(B), set(gca, 'XTick', 1:73, 'XtickL', best_predictors), axis tight
    subplot(313)
    bar(vars), set(gca, 'XTick', 1:73, 'XtickL', predictorNames), axis tight
end