function features = calculate_features(f, options)
%CALCULATE_FEATURES Calculates features for given data structure
    dataStruct = f.dataStruct;
    data = dataStruct.data;
    fs = dataStruct.iEEGsamplingRate;
    features = feature_extractor(data,fs, options);
end

