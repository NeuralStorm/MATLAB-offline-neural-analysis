function [net, results] = run_lds(pca_struct, event_info, tot_bins, latent_variables, cyc, tol)
    %! TODO remove the formatting from LDA function call
    lds_input = [];
    unique_features = fieldnames(pca_struct);
    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};
        mnts = pca_struct.(feature).mnts;
        lds_input = [lds_input, mnts];
    end

    results = struct;
    unique_events = unique(event_info.event_labels);
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        results.(event).relative_response = [];
    end

    trial_start = 1;
    trial_end = tot_bins;
    tot_trials = height(event_info);
    for trial_i = 1:tot_trials
        event = event_info.event_labels{trial_i};
        %% Create train and test set
        test_set = lds_input(trial_start:trial_end, :);
        train_set = lds_input;
        train_set(trial_start:trial_end, :) = [];

        trial_start = trial_start + tot_bins;
        trial_end = trial_end + tot_bins;

        %% DO LDS
        net = lds(train_set, latent_variables, tot_bins, cyc, tol);
        %TODO figure out how to store
        %% Predict left out trial
        [N, p] = size(test_set);
        N=N/tot_bins; % tot trials
        Y=reshape(test_set,N,p,tot_bins);
        [lik, Xfin, Pfin, Ptsum, YX, A1, A2, A3] = kalmansmooth(net.A, net.C, ...
            net.Q, net.R, net.x0, net.P0, Y);
        %TODO actually build up time prediction matrix
        %TODO think this Xfin currently with dims: trials x latent variables x time bins
        Xfin = squeeze(Xfin); % squeeze removes single trial dim of test set (latent variables x time)
        res = shift_row_to_col(Xfin);
        results.(event).relative_response = [results.(event).relative_response; res];
        %TODO change to function call
        % [tot_rows, tot_cols] = size(Xfin);
        % res = NaN(1, tot_rows * tot_cols);
        % start_i = 1;
        % end_i = tot_cols;
        % for row_i = 1:tot_rows
        %     res(1, start_i:end_i) = Xfin(row_i, :);
        %     start_i = start_i + tot_cols;
        %     end_i = end_i + tot_cols;
        % end
        %%
    end

    net = lds(lds_input, latent_variables, tot_bins, cyc, tol);
    net.lds_input = lds_input;
    lds_trial = lds_input(1:tot_bins,:);
    p = length(lds_trial(1,:)); % tot observable
    N=length(lds_trial(:,1));
    N=N/tot_bins; % tot trials
    Y=reshape(lds_trial,N,p,tot_bins);
    [lik, Xfin, Pfin, Ptsum, YX, A1, A2, A3] = kalmansmooth(net.A, net.C, ...
        net.Q, net.R, net.x0, net.P0, Y);
    net.lik = lik;
    net.Xfin = Xfin;
    net.Pfin = Pfin;
    net.Ptsum = Ptsum;
    net.YX = YX;
    net.A1 = A1;
    net.A2 = A2;
    net.A3 = A3;
    % size(Xfin)
    %% Plot first trial
    % figure
    % plot(lds_input(1:tot_bins, :))
end

function [res] = shift_row_to_col(data_matrix)
    [tot_rows, tot_cols] = size(data_matrix);
    res = NaN(1, tot_rows * tot_cols);
    start_i = 1;
    end_i = tot_cols;
    for row_i = 1:tot_rows
        res(1, start_i:end_i) = data_matrix(row_i, :);
        start_i = start_i + tot_cols;
        end_i = end_i + tot_cols;
    end
end