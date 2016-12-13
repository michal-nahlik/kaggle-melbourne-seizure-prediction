function [accuracy, sensitivity, specificity, AUC, AUC_channels] = get_model_perf(model,xTrain,yTrain,xTest,yTest,opts)
%MODEL_PERF Calculates model performance (AUC, AUC for channels, confussion matrix)

    N_channels = opts.N_channels;
    threshold = opts.threshold;
    %% get the model output
    data = struct('xTrain', xTrain, 'yTrain', yTrain, 'xTest', xTest);
    [y, out] = get_model_output(model,data,opts);
    %% score the model output
    AUC_channels = nan(N_channels,1);
    
    target = yTest > threshold;
    output = y > threshold;
    %% auc for individual channels
    for i = 1:N_channels
       [~,~,~,AUC_channels(i)] = perfcurve(double(target),out(i,:),1);
    end
    %% auc and confusion matrix for the total output
    [X,Y,T,AUC] = perfcurve(double(target),y,1);
    [accuracy, sensitivity, specificity] = getCMResult(output, target);
    %% plot the results
    figure(10)
    subplot(211)
    bar(target*2, 'g'), axis tight, hold on
    bar(output), axis tight
    hold off
    legend('target', 'output')
    subplot(212)
    bar(target*2, 'g'), axis tight, hold on
    bar(y), axis tight
    plot(ones(size(y)) * threshold, 'r')
    legend('target','y', 'threshold')
    hold off
    
    figure(100)
    subplot(211)
    plot(X,Y), hold on
    plot(X,T, 'r'),hold off
    legend('ROC', 'Threshold')
    xlabel('False positive rate'), ylabel('True positive rate')
    title(['ROC - AUC: ', num2str(AUC)])
    subplot(212)
    bar([accuracy, sensitivity, specificity]), ylim([0 1])
    title('Accuracy - Sensitivity - Specificity')
    
end