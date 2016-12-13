%% Get started
close all; clear;  clc;

addpath('../')
% Customize the paths in settings where you store your data
settings;

if ~exist(opts.featureDir,'dir')
    mkdir(opts.featureDir)
end

% Subject names (based on folders)
dataFolders = {'train_1','test_1','test_1_new','train_2','test_2','test_2_new','train_3','test_3','test_3_new'};

generate_features(dataFolders,opts);