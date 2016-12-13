function y = load_and_run_dt(data,opts)
%LOAD_AND_RUN_DT loads saved decission tree model and run is on data
    xTest = squeeze(data.xTest(:,opts.channel_index,:));


    model_name = sprintf('DT_%d_%d',opts.subject_index, opts.channel_index);
    model = load([opts.modelDir filesep model_name]);
    dt_model = model.dt_model;
    
    N_test = size(xTest,1);
    out = nan(10,N_test);
    
    for tree_i = 1:10
        out(tree_i,:)  = predict(dt_model.Trained{tree_i},real(xTest));
    end
    y = mean(out)';
end

