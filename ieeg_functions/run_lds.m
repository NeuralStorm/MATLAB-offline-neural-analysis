function [net] = run_lds(pca_struct, pc_log, latent_variables, cyc, tol)
    %TODO unhard code
    tot_bins = 101;
    unique_powers = fieldnames(pc_log);
    lds_input = [];
    for bandname_i = 1:numel(unique_powers)
        bandname = unique_powers{bandname_i};
        unique_regions = fieldnames(pc_log.(bandname));
        for region_i = 1:numel(unique_regions)
            region = unique_regions{region_i};
            weighted_mnts = pca_struct.(bandname).(region).weighted_mnts;
            lds_input = [lds_input, weighted_mnts];
        end
    end

    net = lds(lds_input(102:end, :), latent_variables, tot_bins, cyc, tol);
    net.lds_input = lds_input;
    lds_trial = lds_input(1:101,:);
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