function [net] = run_lds(pca_struct, tot_bins, latent_variables, cyc, tol)
    lds_input = [];
    unique_features = fieldnames(pca_struct);
    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};
        weighted_mnts = pca_struct.(feature).weighted_mnts;
        lds_input = [lds_input, weighted_mnts];
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