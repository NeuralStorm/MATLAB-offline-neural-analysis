function [ica_results, ic_log] = calc_ica(chan_group_log, mnts_struct, ...
        apply_z_score, tot_pcs, extended, sphering, anneal, anneal_deg, ...
        bias_switch, momentum, max_steps, stop_train, rnd_reset, verbose)
    %TODO add option to go straight from relative response to ica with no PCA middleman
    % TODO add check to make sure ica input has enough data
    ica_results = struct;
    labeled_ics = struct;
    ic_log = table();
    unique_ch_groups = unique(chan_group_log.chan_group);
    for ch_group_i = 1:numel(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        % Multineuron timeseries is transposed to match expected dimensionality of runica from EEGLabs
        tot_chans = size(mnts_struct.(ch_group).mnts, 2);

        %% Cannot do ica with less than 2 units
        if tot_chans < 2
            warning('chan_group: %s does not have enough features to do ICA', ch_group);
            continue
        end

        ica_input = mnts_struct.(ch_group).mnts;
        if apply_z_score
            ica_input = zscore(ica_input)';
        end
        if tot_pcs > (tot_chans - 1)
            %% Check set pcs is valid
            % Max allowed pcs is tot_chans - 1
            pcs = tot_chans - 1;
        else
            pcs = tot_pcs;
        end

        if strcmpi(stop_train, 'default') && tot_chans < 33
            stop_train = .000001;
        else
            stop_train = .0000001;
        end

        if strcmpi(anneal, 'default') && extended == 0
            anneal = 0.90;
        elseif strcmpi(anneal, 'default') && extended ~= 0
            anneal = 0.98;
        end

        %TODO make issue for pca in runica for EEGlab
        if pcs == 0
            [ica_weights, ica_sphere, compvars, bias, signs, learning_rates, activations] = ...
                runica(ica_input, 'extended', extended, 'sphering', sphering, ...
                'anneal', anneal, 'annealdeg', anneal_deg, 'bias', bias_switch, 'momentum', momentum, ...
                'maxsteps', max_steps, 'stop', stop_train, 'rndreset', rnd_reset, 'verbose', verbose);
        else
            [ica_weights, ica_sphere, compvars, bias, signs, learning_rates, activations] = ...
                runica(ica_input, 'pca', pcs, 'extended', extended, 'sphering', sphering, ...
                'anneal', anneal, 'annealdeg', anneal_deg, 'bias', bias_switch, 'momentum', momentum, ...
                'maxsteps', max_steps, 'stop', stop_train, 'rndreset', rnd_reset, 'verbose', verbose);
        end
        coeff = (ica_weights * ica_sphere)'; % Double transpose should properly line up data?
        mnts = ica_input' * coeff;

        %% Set up event struct so that analysis can go through rest of pipeline
        [~, tot_components] = size(mnts);
        ic_names = cell(tot_components, 1);
        for component_i = 1:tot_components
            ic_names{component_i} = [ch_group, '_ic_', num2str(component_i)];
        end
        ch_group_list = chan_group_log(1:tot_components, :);
        ch_group_list.channel = ic_names; ch_group_list.user_channels = ic_names;
        ch_group_list.channel_data = num2cell(mnts, 1)';
        labeled_ics.(ch_group) = ch_group_list;

        ic_log = [ic_log; ch_group_list];

        %% Store ICA results
        ica_results.(ch_group).ica_weights = ica_weights;
        ica_results.(ch_group).ica_sphere = ica_sphere;
        ica_results.(ch_group).component_variance = compvars;
        ica_results.(ch_group).bias = bias;
        ica_results.(ch_group).signs = signs;
        ica_results.(ch_group).learning_rates = learning_rates;
        ica_results.(ch_group).activations = activations;
        ica_results.(ch_group).mnts = mnts;
        ica_results.(ch_group).chan_order = ic_names;
        ica_results.(ch_group).orig_chan_order = mnts_struct.(ch_group).orig_chan_order;
    end
end