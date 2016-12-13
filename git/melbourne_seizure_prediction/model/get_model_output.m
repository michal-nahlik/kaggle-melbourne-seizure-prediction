function [y,out] = get_model_output(model,data,opts)
%GET_MODEL_OUTPUT gets output for the model based on channel model outputs
%   Detailed explanation goes here
    N_channels = opts.N_channels;
    out = zeros(N_channels,size(data.xTest,1));
    %% create model for each channel and get the output
    for i = 1:N_channels
        channel_opts = opts;
        channel_opts.channel_index = i;
        out(i,:) = model(data,channel_opts);
    end
    %% final output is mean prediction across all channels
    out(isnan(out)) = 0;
    y = mean(out)';
end