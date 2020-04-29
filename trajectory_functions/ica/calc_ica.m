function [ica_results, labeled_ics, ic_log] = calc_ica(label_log, mnts_struct, ...
        tot_pcs, extended, sphering, anneal, anneal_deg, bias_switch, ...
        momentum, max_steps, stop_train, rnd_reset, verbose)
    %TODO add option to go straight from relative response to ica with no PCA middleman
    %TODO dont forget to z score raw input
    % TODO add check to make sure ica input has enough data
    ica_results = struct;
    ica_results.all_events = mnts_struct.all_events;
    labeled_ics = struct;
    region_names = fieldnames(label_log);
    tot_regions = length(region_names);
    ic_log = struct;
    for region_index = 1:tot_regions
        region = region_names{region_index};
        % Multineuron timeseries is transposed to match expected dimensionality of runica from EEGLabs
        [~, tot_units] = size(mnts_struct.(region).z_mnts);

        %% Cannot do ica with less than 2 units
        if tot_units < 2
            warning('Region: %s does not have enough features to do ICA', region);
            continue
        end

        ica_input = mnts_struct.(region).z_mnts';
        [tot_channels, ~] = size(ica_input);
        if tot_pcs > (tot_channels - 1)
            %% Check set pcs is valid
            % Max allowed pcs is tot_channels - 1
            pcs = tot_channels - 1;
        else
            pcs = tot_pcs;
        end

        if strcmpi(stop_train, 'default') && tot_channels < 33
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
        weighted_mnts = ica_input' * coeff;

        %% Set up event struct so that analysis can go through rest of pipeline
        [~, tot_components] = size(weighted_mnts);
        ic_names = cell(tot_components, 1);
        for component_i = 1:tot_components
            ic_names{component_i} = ['ic_', num2str(component_i)];
        end
        region_table = label_log.(region)(1:tot_components, :);
        region_table.sig_channels = ic_names; region_table.user_channels = ic_names;
        region_table.channel_data = num2cell(weighted_mnts, 1)';
        labeled_ics.(region) = region_table;

        ic_log.(region) = removevars(labeled_ics.(region), 'channel_data');

        %% Store ICA results
        ica_results.(region).ica_weights = ica_weights;
        ica_results.(region).ica_sphere = ica_sphere;
        ica_results.(region).component_variance = compvars;
        ica_results.(region).bias = bias;
        ica_results.(region).signs = signs;
        ica_results.(region).learning_rates = learning_rates;
        ica_results.(region).activations = activations;
        ica_results.(region).weighted_mnts = weighted_mnts;
    end
end