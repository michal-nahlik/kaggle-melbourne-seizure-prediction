function generate_features(subjectNames,options)
%GENERATE_FEATURES Calculates and saves features for all "safe" trainig files and all test files

    labelFile = options.labelFile;
    dataDir = options.dataDir;
    featureDir = options.featureDir;
    
    T = readtable(labelFile,'Delimiter',',');
    safe = logical(T.safe);
    T = T(safe,:);
    
    for i = 1:length(subjectNames)
        % Specify patient to look at
        subjectName = subjectNames{i};
        C = strsplit(subjectName, '_');
        subject_id = C{2};

        fprintf('Starting feature extraction for %s:\n', subjectName);

        % Read and count number of files associated with this segment type
        sourceDir = [dataDir filesep subjectName];
        files = dir([sourceDir filesep '*.mat']);
        fileNames = {files(:).name};
        
        if isempty(strfind(subjectNames{i}, '_new'))
            fileMask = [subject_id '_'];
            x = strncmp(T.image, fileMask,2);
            saveFiles = T.image(x);
            fileNames = intersect(fileNames, saveFiles);  
            disp('Looking for safe files'); 
        end
        
        numFiles = length(fileNames);
        
        filePaths = fullfile(dataDir, subjectName, fileNames);
        savePath = fullfile(featureDir, subjectName);
        
        if ~isdir(savePath)
            mkdir(savePath);
        end

        p = gcp('nocreate');
        if isempty(p)
            p = parpool('local',2);
        end
        
        disp('Start feature calculation on local workers...')
        parfor k = 1:numFiles
            % Load and display the file being read.
            fileName = fileNames{k};
            if exist([savePath filesep fileName],  'file') == 0
                fileName = strrep(fileNames{k},'.mat','');
                filePath = filePaths{k};
                f = load(filePath);
                disp(filePath);
                % Calculate features
                features = calculate_features(f);
                % Store features to featureDir
                parsave([savePath filesep fileName],'features', features);
            else
               fprintf('Features for file %s - %s already exists.\n', subjectName,fileName);
            end
        end
        disp(['Done. Saved all features to ' savePath])
    end
    
    delete(p);
end

function parsave(filepath, varStr, var)
    evalc([varStr '=' 'var']);
    save(filepath, varStr);
end