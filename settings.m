%% Data paths
opts.dataDir            = 'h:\Data\MelbourneU Seizure Prediction\data';
opts.featureDir         = 'c:\Temp\kaggle\Melbourne\features';
opts.modelDir           = 'c:\Temp\kaggle\Melbourne\models';

opts.labelFile          = 'c:\Temp\kaggle\Melbourne\train_and_test_data_labels_safe.csv';
opts.submissionFile     = 'c:\Temp\kaggle\Melbourne\submission\sample_submission.csv';
%% Train and test folders
opts.subjectNames       = {'train_1','train_2','train_3','test_1_new','test_2_new','test_3_new'};
opts.train_subjects     = opts.subjectNames(1:3);
opts.test_subjects      = opts.subjectNames(4:6);
%% Cross validation settings
opts.cv_k               = 4;        % number of folds
%% Options for generating features and models
opts.ignore_dropouts    = true;
opts.save_model         = false;