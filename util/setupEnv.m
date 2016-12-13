function opts = setupEnv()
%SETUP ENVIRONMENT Setup the environment and options
    warning off;
    addpath('../');
    addpath('../util');
    addpath('../features');
    addpath('../model');
    addpath('../opt');
    %%
    disp('Setting random number generator seed to 1.');
    rng(1);
    %% load settings
    settings
    %% Feature and data info
    opts.varNames = {'mean_value' 'std_value' 'RHO_data 1' 'RHO_data 2' 'RHO_data 3' 'RHO_data 4' 'RHO_data 5' 'RHO_data 6' 'RHO_data 7' 'RHO_data 8' 'RHO_data 9' 'RHO_data 10' 'RHO_data 11' 'RHO_data 12' 'RHO_data 13' 'RHO_data 14' 'RHO_data 15' 'RHO_data 16' 'RHO_freq 1' 'RHO_freq 2' 'RHO_freq 3' 'RHO_freq 4' 'RHO_freq 5' 'RHO_freq 6' 'RHO_freq 7' 'RHO_freq 8' 'RHO_freq 9' 'RHO_freq10' 'RHO_freq 11' 'RHO_freq 12' 'RHO_freq 13' 'RHO_freq 14' 'RHO_freq 15' 'RHO_freq 16' 'morl_eig 1' 'morl_eig 2' 'morl_eig 3' 'morl_eig 4' 'morl_eig 5' 'morl_eig 6' 'morl_eig 7' 'morl_eig 8' 'morl_eig 9' 'morl_eig 10' 'spedge' 'spentropy' 'spentropyDyd' 'RHO_dyad 1' 'RHO_dyad 2' 'RHO_dyad 3' 'RHO_dyad 4' 'RHO_dyad 5' 'RHO_dyad 6' 'RHO_dyad 7' 'RHO_dyad 8' 'RHO_dyad 9' 'RHO_dyad 10' 'RHO_dyad 11' 'RHO_dyad 12' 'RHO_dyad 13' 'RHO_dyad 14' 'RHO_dyad 15' 'RHO_dyad 16' 'fd 1' 'fd 2' 'fd 3' 'petrosianFd' 'katzFd' 'activity' 'mobility' 'complexity' 'skew' 'kurt'};
    opts.N_channels     = 16;
    opts.N_features     = 73;
    %% Options - model
    opts.threshold      = 0.5;
end