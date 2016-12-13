function write_submission(y,file_names,submissionFile)
%WRITE_SUBMISSION Write probability (y) to each file name in submission file
    fprintf('Saving the result to the submission file.\n');

    tb              = readtable(submissionFile,'Delimiter','comma');
    file            = tb.File;
    [~,ind]         = intersect(file,file_names);
    tb.Class(ind)   = y;
    writetable(tb,submissionFile,'Delimiter','comma');
end

