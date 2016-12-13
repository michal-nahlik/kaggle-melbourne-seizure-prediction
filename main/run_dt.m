close all; clear;  clc;
%%
addpath('../util');
opts = setupEnv();
%% model with specific parameters for every subject
model = @train_and_run_dt;
opts.min_parents = [10,5,5];
opts.min_leafs = [5,5,5];
%% create model and submission for each subject
for i = 1:3
    subjectName_train = opts.train_subjects{i};
    subjectName_test = opts.test_subjects{i};
    %% load data
    [data.xTrain,data.yTrain,~,data.FN_train] = load_data(subjectName_train,opts); 
    [data.xTest,~,~,data.FN_test] = load_data(subjectName_test,opts);
    %% prepare options for a subject
    opts_subject = opts;
    opts_subject.subject_index = i;
    opts_subject.min_leaf = opts.min_leafs(i);
    opts_subject.min_parent = opts.min_parents(i);
    opts.model_name = sprintf('DT - leaf (%d), parent(%d)', opts_subject.min_leaf, opts_subject.min_parent);
    %% cross validate model and make a submission
    fprintf('Evaluating model for patient %d.\n',i);
    evaluate_model(model,data,opts_subject);
    %% create submission
    create_submission(model,data,opts_subject)
    clear data;
end