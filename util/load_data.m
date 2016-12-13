function [X,Y,numFiles, FN, XS] = load_data(subjectName,options)
%LOAD_DATA load data for a subject
% returns [X,Y,number of files, file names, features across channels (eigenvalues of channels correlation)] 

    SIGNAL_FEATURES = {'RHO_data_eig','RHO_freq_eig', 'RHO_dyad_eig'};
    
    tic
    fprintf('Loading data for %s\n', subjectName);
    h = waitbar(0,'Loading data...');

    N_channels = options.N_channels;
    N_features = options.N_features;
    dataDir = options.dataDir;
    featureDir = options.featureDir;
    labelFile = options.labelFile;
    
    dataDir = [dataDir filesep subjectName];
    featureDir = [featureDir filesep subjectName];
    
    
    if strfind(subjectName, 'train')
        T = readtable(labelFile,'Delimiter',',');
        safe = logical(T.safe);
        T = T(safe,:);
        
        C = strsplit(subjectName, '_');
        subject_id = C{2};
        
        fileMask = [subject_id '_'];
        x = strncmp(T.image, fileMask,2);
        fileNames = T.image(x);
        numFiles = length(fileNames);
        Y = T.class(x);
    else
        fileNames = dir([featureDir filesep '*.mat']);
        fileNames = {fileNames(:).name};
        numFiles = length(fileNames);
        Y = nan(numFiles,1);
    end
    
    valid = true(numFiles,1);
    X = nan(numFiles,N_channels,N_features);
    XS = nan(numFiles,48);
    
    for l = 1:numFiles
        fileName = fileNames{l};
        filePath = fullfile(featureDir, fileName);
        
        f = load(filePath);
        features = f.features;
        
        if isempty(features) || sum(features.std_value) == 0
            fprintf('File %s has no data\n', fileName);
            valid(l) = false;
            continue; 
        end
        
        fields = fieldnames(features);
        
        feature_matrix = nan(N_channels,N_features);

        for channel = 1:N_channels
            f_vector = [];
            for k = 1:length(fields)
                if ismember(fields{k}, SIGNAL_FEATURES)
                   continue; 
                end

                value = squeeze(getfield(features, fields{k}));
                [N,M] = size(value);
                if N == 16
                    f_vector = [f_vector,squeeze(value(channel,:))];
                elseif N == 3
                    f_vector = [f_vector,squeeze(value(:,channel)')];
                elseif N == 1
                    f_vector = [f_vector,squeeze(value(channel))];
                end
            end
            feature_matrix(channel,:) = f_vector;
        end
    
    X(l,:,:) = feature_matrix;
    XS(l,:) = [features.RHO_data_eig, features.RHO_dyad_eig, features.RHO_freq_eig];
    waitbar(l / numFiles)
    end
    
    X = X(valid,:,:);
    XS = XS(valid,:);
    Y = Y(valid);
    FN = fileNames(valid);
    
    close(h)
    toc
end

