function create_submission(model,data,opts)
%CREATE_SUBMISSION Create and write submission using given model and data.
% data has to contain xTrain, yTrain, xTest and file names for test
    fprintf('Creating model for patient %d and generating output.\n',opts.subject_index);
    tic
    y = get_model_output(model,data,opts);
    toc
    write_submission(y,data.FN_test,opts.submissionFile);
end

