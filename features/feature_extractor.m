function features = feature_extractor(data, fs, opts)
%FEATURE_EXTRACTOR Calculates features from data, sampling frequency is requited
%   No preprocessing, features are calculated from the whole data sample
%   Features: mean value, std, correlation between channels in time and
%   frequency domain and it's eigenvalues, spectral edge, spectral entropy,
%   fractal dimensions (Brownian, Petrosian, Katz), Hjorth parameters,
%   skewness, kurtosis, eigenvalues of 10 scales wavelet transformation
%   using Morlet wave
    
%% ignoring dropouts and concatenating the healthy signal
%% dropout is detected by signal power and mean across channels
    if opts.ignore_dropouts
        signal_power = sum(abs(data),2);
        signal_mean = mean(abs(data),2);
        signal_power_dropout = signal_power == 0;
        signal_mean_dropout = signal_mean == 0;
        dropout = signal_power_dropout .* signal_mean_dropout;
        data = data(~dropout,:);

        if isempty(data)
            features = [];
           return  
        end
    end

    [nt,nc] = size(data);
    subsampLen = nt;    % subsample lenght is equal to data length
    numSamps = floor(nt / subsampLen);      % Num of samples
    sampStart = 1:subsampLen:numSamps*subsampLen + numSamps;
    
    %%
    for l=1:numSamps
        sampleData = data(sampStart(l):sampStart(l+1)-1,:);
        meanValue = mean(sampleData);
        stdValue = std(sampleData);
        %% Compute Shannon's entropy, spectral edge and correlation matrix
        % Find the power spectrum at each frequency bands
        Y = abs(fft(sampleData));               % take FFT of each channel
        Y = bsxfun(@rdivide,Y,sum(Y));          % normalize each channel
        lvl = [0.1 4 8 14 32 70 180];           % frequency levels in Hz
        lseg = round(subsampLen/fs*lvl)+1;      % segments corresponding to frequency bands

        dspect = zeros(length(lvl)-1,nc);
        for n=1:length(lvl) -1
            dspect(n,:) = 2*sum(Y(lseg(n):lseg(n+1),:));
        end
        %% Find the Shannon's entropy
        spentropy = -sum((dspect) .* log(dspect));
        %% Find the spectral edge frequency
        sfreq = fs;
        tfreq = 40;
        ppow = 0.5;

        topfreq = round(subsampLen/sfreq*tfreq);
        A = cumsum(Y(1:topfreq,:));
        B = bsxfun(@minus,A,max(A)*ppow);
        [~,spedge] = min(abs(B));
        spedge = (spedge-1)/(topfreq-1)*tfreq;
        %% Calculate correlation matrix and its eigenvalues (b/w channels) for signal and frequencies
        %% Calculate maximum cross correlation -0.5+0.5 seconds
        RHO_data = nan(nc);
        RHO_freq = nan(nc);
        morl_eig = nan(nc,10);
        
        max_lag = fs * 0.5; % maximum lag is +-0.5 seconds
        for i = 1:nc 
            for j = 1:nc
                 [temp,~] = xcorr(sampleData(i,:) -meanValue(i), sampleData(j,:) - meanValue(j), max_lag,'coeff');
                 [~,I] = max(abs(temp));
                 RHO_data(i,j) = temp(I);
                 temp = corrcoef(Y(i,:), Y(j,:));
                 RHO_freq(i,j) = temp(1,2);
            end
            
            coefs = cwt(sampleData(i,:),1:10,'morl');
            morl_eig(i,:) = svd(coefs);
        end
        
        temp = RHO_data;
        temp(isnan(temp)) = 0;
        temp(isinf(temp)) = 0;
        RHO_data_eig = eig(temp);
        
        temp = RHO_freq;
        temp(isnan(temp)) = 0;
        temp(isinf(temp)) = 0;
        RHO_freq_eig = eig(temp);
        %% Dyadic analysis
        % Find number of dyadic levels
        ldat = floor(subsampLen/2);
        no_levels = floor(log2(ldat));

        %% Find the power spectrum at each dyadic level
        dspect = zeros(no_levels,nc);
        for n=no_levels:-1:1
            dspect(n,:) = 2*sum(Y(floor(ldat/2)+1:ldat,:));
            ldat = floor(ldat/2);
        end
        %% Find the Shannon's entropy
        spentropyDyd = -sum(dspect.*log(dspect));
        %% Find correlation between channels power spectrums at each dyadic level
        RHO_dyad = corrcoef(dspect);
        
        temp = RHO_dyad;
        temp(isnan(temp)) = 0;
        RHO_dyad_eig = eig(temp);
        %% Fractal dimensions
        %% Brownian
        fd = zeros(3,nc);
        for n=1:nc
            fd(:,n) = wfbmesti(sampleData(:,n));
        end
        %% Petrosian
        D = diff(sampleData);
        N_delta= sum(diff(D) > 0); 
        petrosianFd = log10(subsampLen)./(log10(subsampLen)+log10(subsampLen/subsampLen+0.4*N_delta));
        %% Katz
        L = nan(nc,1);
        for i = 1:nc
            L(i) = max(abs(sampleData(:,i) - sampleData(1,i)));
        end
        katzFd = log(L)./log(subsampLen);
        %% Hjorth parameters
        % Activity
        activity = var(sampleData);
        % Mobility
        mobility = std(diff(sampleData))./std(sampleData);
        % Complexity
        complexity = std(diff(diff(sampleData)))./std(diff(sampleData))./mobility;
        %% Statistical properties
        % Skewness
        skew = skewness(sampleData);
        % Kurtosis
        kurt = kurtosis(sampleData);
        %% Compile all the features
        features.mean_value(l,:) = meanValue;
        features.std_value(l,:) = stdValue;
        features.RHO_data(l,:,:) = RHO_data;
        features.RHO_freq(l,:,:) = RHO_freq;
        features.RHO_data_eig(l,:) = RHO_data_eig;
        features.RHO_freq_eig(l,:) = RHO_freq_eig;
        features.morl_eig(l,:,:) = morl_eig;
        features.spedge(l,:) = spedge;
        features.spentropy(l,:) = spentropy;
        features.spentropyDyd(l,:) = spentropyDyd;
        features.RHO_dyad(l,:,:) = RHO_dyad;
        features.RHO_dyad_eig(l,:) = RHO_dyad_eig;
        features.fd(l,:,:) = fd;
        features.petrosianFd(l,:) = petrosianFd;
        features.katzFd(l,:) = katzFd;
        features.activity(l,:) = activity;
        features.mobility(l,:) = mobility;
        features.complexity(l,:) = complexity;
        features.skew(l,:) = skew;
        features.kurt(l,:) = kurt;
    end
end

