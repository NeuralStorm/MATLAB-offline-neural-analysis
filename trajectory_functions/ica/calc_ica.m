function [ica_results, labeled_ics, ic_log] = calc_ica(label_log, mnts_struct, ...
        tot_pcs, extended, sphering, anneal, anneal_deg, bias_switch, ...
        momentum, max_steps, stop_train, rnd_reset, verbose)
    %TODO add option to go straight from relative response to ica with no PCA middleman
    %TODO dont forget to z score raw input
    % TODO add check to make sure ica input has enough data
    ica_results = struct;
    labeled_ics = struct;
    ic_log = table();
    unique_regions = unique(label_log.chan_group);
    for reg_i = 1:numel(unique_regions)
        region = unique_regions{reg_i};
        % Multineuron timeseries is transposed to match expected dimensionality of runica from EEGLabs
        tot_chans = size(mnts_struct.(region).mnts, 2);

        %% Cannot do ica with less than 2 units
        if tot_chans < 2
            warning('Region: %s does not have enough features to do ICA', region);
            continue
        end

        ica_input = mnts_struct.(region).mnts';
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
            ic_names{component_i} = [region, '_ic_', num2str(component_i)];
        end
        region_table = label_log(1:tot_components, :);
        region_table.channel = ic_names; region_table.user_channels = ic_names;
        region_table.channel_data = num2cell(mnts, 1)';
        labeled_ics.(region) = region_table;

        ic_log = [ic_log; region_table];

        %% Store ICA results
        ica_results.(region).ica_weights = ica_weights;
        ica_results.(region).ica_sphere = ica_sphere;
        ica_results.(region).component_variance = compvars;
        ica_results.(region).bias = bias;
        ica_results.(region).signs = signs;
        ica_results.(region).learning_rates = learning_rates;
        ica_results.(region).activations = activations;
        ica_results.(region).mnts = mnts;
        ica_results.(region).chan_order = ic_names;
        ica_results.(region).orig_chan_order = mnts_struct.(region).orig_chan_order;
    end
end