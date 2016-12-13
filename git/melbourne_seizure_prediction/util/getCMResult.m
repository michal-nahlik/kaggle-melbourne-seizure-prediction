function [accu, sen, spe] = getCMResult(target, output)
%GETCMRESULT Get confusion matrix result
%   returns accuracy, sensitivity and specificity
    TP = sum(target + output == 2);
    TN = sum(target + output == 0);
    FP = sum(target - output < 0);
    FN = sum(target - output > 0);
    accu = (TP + TN) / (TP + TN + FP + FN);
    sen = TP / (TP+FN);
    spe = TN / (TN + FP);

end

