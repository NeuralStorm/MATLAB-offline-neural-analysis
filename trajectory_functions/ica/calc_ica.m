function [labeled_ics, psth_struct, ica_results] = calc_ica(labeled_data, ...
        mnts_struct, pre_time, post_time, bin_size, tot_pcs, extended, ...
        sphering, anneal, anneal_deg, bias_switch, momentum, max_steps, stop_train, rnd_reset, verbose)
    %TODO add option to go straight from relative response to ica with no PCA middleman
    %TODO dont forget to z score raw input
    % TODO add check to make sure ica input has enough data
    psth_struct = struct;
    ica_results = struct;
    psth_struct.all_events = mnts_struct.all_events;
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    labeled_ics = struct;
    region_names = fieldnames(labeled_data);
    tot_regions = length(region_names);
    for region_index = 1:tot_regions
        region = region_names{region_index};
        % Multineuron timeseries is transposed to match expected dimensionality of runica from EEGLabs
        [tot_rows, tot_units] = size(mnts_struct.(region).mnts);
        tot_trials = tot_rows / tot_bins;

        %% Cannot do ica with less than 2 units
        if tot_units < 2
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
        [~, tot_cols] = size(weighted_mnts);

        %% Set up event struct so that analysis can go through rest of pipeline
        [ica_relative_response, ic_names] = mnts_to_psth(weighted_mnts, tot_trials, tot_cols, tot_bins, 'ic');
        repeat = [length(ic_names), 1];
        region_num = labeled_data.(region){1, 3};
        region_date = labeled_data.(region){1, 4};
        labeled_ics.(region) = [ic_names, repmat({region}, repeat), repmat({region_num}, repeat) ...
            repmat({region_date}, repeat), repmat({'IC'}, repeat)];
        psth_struct.(region) = split_relative_response(ica_relative_response, ic_names, ...
            mnts_struct.all_events, bin_size, pre_time, post_time);
        psth_struct.(region).relative_response = ica_relative_response;
        psth_struct.(region).psth = sum(ica_relative_response, 1) / tot_trials;
        psth_struct.(region).mnts = weighted_mnts;

        %% Store ICA results
        ica_results.(region).ica_weights = ica_weights;
        ica_results.(region).ica_sphere = ica_sphere;
        ica_results.(region).compvars = compvars;
        ica_results.(region).bias = bias;
        ica_results.(region).signs = signs;
        ica_results.(region).learning_rates = learning_rates;
        ica_results.(region).activations = activations;
    end
end