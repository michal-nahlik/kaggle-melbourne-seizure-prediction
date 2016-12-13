close all; clear;  clc;
%%
addpath('../util');
opts = setupEnv();
%% model
model = @train_and_run_dt;
%%
results = [];
algs = {'Exact','PullLeft','PCA','OVAbyClass'};
%% find the best combination of setup (min_leaf, min_parent, max_cat, algorithm) for
%% each subject
for i = 1:3
    subjectName_train = opts.train_subjects{i};
    subjectName_test = opts.test_subjects{i};
    
    opts_subject = opts;
    opts_subject.subject_index = i;
    
    [data.xTrain,data.yTrain,~,data.FN_train] = load_data(subjectName_train,opts); 

    fprintf('Evaluating model for patient %d.\n',i);
    for p = [1,5,10,15,25]
        for l = [1,5,10,15,25]
            for c = [1,5,10,15,25]
                for a = 1:4
                    opts_subject.min_leaf = l;
                    opts_subject.min_parent = p;
                    opts_subject.max_cat = c;
                    opts_subject.algorithm = algs{a};
                    
                    opts_subject.model_name = sprintf('DT - leaf (%d), parent(%d), category(%d), algorithm(%s)', l, p, c, algs{a});
                    %%
                    AUC = evaluate_model(model,data,opts_subject);

                    results = [results; [i,p,l,c,a,mean(AUC)]];
                end
            end
        end
    end
end
%%
disp('Best results:');
for i = 1:3
    subj_ind = results(:,1) == i;
    subj_res = results(subj_ind,:);
    
    [AUC,I] = max(subj_res(:, end));
    p = subj_res(I,2);
    l = subj_res(I,3);
    c = subj_res(I,4);
    a = subj_res(I,5);
    
    fprintf('Subject %d - %.4f AUC - DT - leaf (%d), parent(%d), category(%d), algorithm(%s)\n', i, AUC, l, p, c, algs{a});
end