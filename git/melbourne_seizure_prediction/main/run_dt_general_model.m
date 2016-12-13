close all; clear;  clc;
%%
addpath('../util');
opts = setupEnv();
opts.save_model = false;
%% model setup
model = @train_and_run_dt;
opts.min_leaf = 10;
opts.subject_index = 1;
%% data structure
data.xTrain = [];
data.yTrain = [];
data.pLimit = [1]; % this one allows to separate train data for each patients
data.xTest = [];
data.FN_test = [];
%% load data for all patients
for i = 1:3
    subjectName_train = opts.train_subjects{i};
    subjectName_test = opts.test_subjects{i};
    
    [xTrain,yTrain] = load_data(subjectName_train,opts); 
    [xTest,~,~,FN_test] = load_data(subjectName_test,opts);
    data.xTrain = [data.xTrain; xTrain];
    data.yTrain = [data.yTrain; yTrain];
    data.pLimit(i+1) = data.pLimit(i) + length(yTrain);
    data.xTest = [data.xTest; xTest];
    data.FN_test = [data.FN_test, FN_test];
    
    clear xTrain yTrain xTest FN_test;
end 
%%
opts.model_name = sprintf('DT - leaf (%d)', opts.min_leaf);
%%
disp('Evaluating model using normal cross validation.');
evaluate_model(model,data,opts);
%% patient cross validation - one patient for test, two patients for training
disp('Evaluating model using patient cross validation.');
for i = 1:3
    train_i = true(size(data.yTrain));
    train_i(data.pLimit(i):data.pLimit(i+1)-1) = false;
    test_i = ~train_i;
    [accu, sen, spe, auc, auc_channels] = get_model_perf(model,data.xTrain(train_i,:,:),data.yTrain(train_i),data.xTrain(test_i,:,:),data.yTrain(test_i),opts);
    disp(auc)
end
%% create model and submission for all patients at once
create_submission(model,data,opts)
clear data;