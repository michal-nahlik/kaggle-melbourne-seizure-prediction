function [A, SE, SP, AUC, AUC_channels] = crossval_model(model,data,opts)
%CROSSVAL_MODEL Cross validate model on given data

    cv_k = opts.cv_k;
    % Prepare matrices for results
    A = nan(cv_k,1); 
    SE = nan(cv_k,1); 
    SP = nan(cv_k,1);
    AUC = nan(cv_k,1);
    AUC_channels = nan(cv_k,opts.N_channels);
    % create cross validation object
    cv = cvpartition(data.yTrain,'KFold',cv_k);

    for i = 1:cv.NumTestSets
        % split data into train and test partition
        train_idx = cv.training(i);
        test_idx = cv.test(i);
        
        xTrain = data.xTrain(train_idx,:,:);
        xTest = data.xTrain(test_idx,:,:);
        yTrain = data.yTrain(train_idx);
        yTest = data.yTrain(test_idx);
        clear train_idx test_idx FN_train;
        % shuffle data
        train_shuffle = randperm(length(yTrain));
        test_shuffle = randperm(length(yTest));
        
        xTrain = xTrain(train_shuffle,:,:);
        xTest = xTest(test_shuffle,:,:);
        yTrain = yTrain(train_shuffle);
        yTest = yTest(test_shuffle);
        clear train_shuffle test_shuffle;
        % evaluate model performance 
        [accu, sen, spe, auc, auc_channels] = get_model_perf(model,xTrain,yTrain,xTest,yTest,opts);
        clear xTrain yTrain xTest yTest fnTest;
        
        A(i) = accu;
        SE(i) = sen;
        SP(i) = spe;
        AUC(i) = auc;
        AUC_channels(i,:) = auc_channels;
    end
end

