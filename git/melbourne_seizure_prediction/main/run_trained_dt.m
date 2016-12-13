close all; clear;  clc;
%%
addpath('../util');
opts = setupEnv();
%%
model = @load_and_run_dt;
%%
for i = 1:3
    subjectName_test = opts.test_subjects{i};
    %% load data
    [data.xTest,~,~,data.FN_test] = load_data(subjectName_test,opts);
    %% prepare options for a subject
    opts_subject = opts;
    opts_subject.subject_index = i;
    %% create submission
    create_submission(model,data,opts_subject)
    clear data;
end