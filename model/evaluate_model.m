function [AUC, AUC_channels] = evaluate_model(model,data,opts)
%EVALUATE_MODEL Summary of this function goes here
%   Detailed explanation goes here
    tic
    %% information
    subjectName = opts.subjectNames{opts.subject_index};
    subjectName_title = strrep(subjectName, '_', ' ');
    if isfield(opts, 'model_name')
        modelName = opts.model_name;
        subjectName_title = [subjectName_title ' - ' modelName];
        disp(modelName);
    end
    %% cross validation
    [accu, sen, spe, AUC, AUC_channels] = crossval_model(model,data,opts);
    %% output
    figure(5)
    subplot(511), bar(accu), axis tight, ylim([0 1]), title({subjectName_title;'Accuracy'})
    subplot(512), bar(sen), axis tight, ylim([0 1]), title('Sensitivity')
    subplot(513), bar(spe), axis tight, ylim([0 1]), title('Specificity')
    subplot(514), bar(AUC), axis tight, ylim([0 1]), title('AUC')
    subplot(515), bar(mean(AUC_channels)), axis tight, ylim([0 1]), title('AUC -  channels')
    timestamp = datestr(now, 'mmddHHMMSS');
%     saveas(gcf,['../images/', subjectName_title, '-', timestamp],'png');
%     saveas(gcf,['../images/', subjectName_title, '-', timestamp],'fig');

    fprintf('------------------------\n');
    fprintf('Model accuracy: %.4f\n', mean(accu));
    fprintf('Model sensitivity: %.4f\n', mean(sen));
    fprintf('Model specificity: %.4f\n', mean(spe));
    fprintf('AUC: %.4f\n', mean(AUC));
    toc
    fprintf('\n');
end

