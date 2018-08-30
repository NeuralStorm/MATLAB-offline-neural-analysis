function [rf_path] = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
        threshold_scale, sig_check, sig_bins, span, wanted_events)
    tic

    if pre_time <= 0.050
        error('Pre time can not be set to 0 for receptive field analysis. Recreate the PSTH format with a different pre time.');
    end

    psth_mat_path = [psth_path, '/*.mat'];
    psth_files = dir(psth_mat_path);

    % rf = receptive field
    rf_path = [psth_path, '/receptive_field_analysis'];
    if ~exist(rf_path, 'dir')
        mkdir(psth_path, 'receptive_field_analysis');
    end

    % Deletes the failed directory if it already exists
    failed_path = [psth_path, '/failed'];
    if exist(failed_path, 'dir') == 7
    delete([failed_path, '/*']);
    rmdir(failed_path);
    end

    %% Iterates through all psth formatted files and performs the recfield analysis
    for file = 1: length(psth_files)
        failed_rf = {};
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        fprintf('Receptive field analysis for %s on %s\n', animal_name, current_day);

        load(current_file);

        %% Create the struct fields for the receptive field results
        channel_names = neuron_map(:,1);
        for name = 1:length(channel_names)
            neuron_name = channel_names{name};
            receptive_analysis.([neuron_name, '_first_latency']) = [];
            receptive_analysis.([neuron_name, '_last_latency']) = [];
            receptive_analysis.([neuron_name, '_peak_latency']) = [];
            receptive_analysis.([neuron_name, '_peak_response']) = [];
            receptive_analysis.([neuron_name, '_response_magnitude']) = [];
            receptive_analysis.([neuron_name, '_background_rate']) = [];
            receptive_analysis.([neuron_name, '_threshold']) = [];
        end

        %% Set variables used for pre window analysis
        pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
        pre_avg_background_firing = [];
        thresholds = [];
        pre_neurons = [];
        smoothed_pre_neurons = [];
        for event = 1:length(wanted_events)
            norm_pre_window = event_struct.([event_strings{event}, '_norm_pre_time_activity']);
            norm_post_window = event_struct.([event_strings{event}, '_norm_post_time_activity']);
            for neuron = 1:total_neurons
                %% Deal with pre window first
                smoothed_pre_window = smooth(norm_pre_window(neuron, :), span);
                smoothed_avg_background = mean(smoothed_pre_window);
                smoothed_std_background = std(smoothed_pre_window);
                smoothed_threshold = smoothed_avg_background + (threshold_scale * smoothed_std_background);

                %% Post window analysis

                smoothed_response = smooth(norm_post_window(neuron, :), span);
                %% Determine if given neuron has a significant response 
                sig_response = false;
                smooth_above_threshold_indeces = find(smoothed_response > smoothed_threshold);
                smooth_above_threshold = smoothed_response(smooth_above_threshold_indeces);
                %% Determines if there was a significant response
                [consecutive, ~] = is_consecutive(smooth_above_threshold_indeces, sig_bins);
                if consecutive
                    if sig_check == 1
                        % Unpaired ttest on pre and post windows
                        reject_null = ttest2(norm_pre_window(neuron, :), norm_post_window(neuron, :));
                    elseif sig_check == 2
                        % ks test on pre and post windows
                        reject_null =  kstest2(normpre_window(neuron, :), normpost_window(neuron, :));
                    else
                        error('Invalid sig check. Valid options for sig_check are 1 or 2, please see main documentation for more details');
                    end
                    % If the null hypothesis is rejected, then there is a significant response
                    if isnan(reject_null)
                        reject_null = false;
                    end
                    if reject_null
                        sig_response = true;
                    end
                end
                %% Receptive field analysis if significant response
                % Finds first, last, and peak latency as well as the peak magnitude, response magnitude, background rate, and threshold
                if sig_response
                    response = norm_post_window(neuron, :);
                    above_threshold = response(smooth_above_threshold_indeces);
                    peak = max(above_threshold);
                    peak_index = find(peak == response);
                    background_rate = mean(norm_pre_window(neuron, :));
                    receptive_analysis.([channel_names{neuron}, '_first_latency']) = [receptive_analysis.([channel_names{neuron}, '_first_latency']); event_strings{event}, {(smooth_above_threshold_indeces(1)) * bin_size}];
                    receptive_analysis.([channel_names{neuron}, '_last_latency']) = [receptive_analysis.([channel_names{neuron}, '_last_latency']); event_strings{event}, {(smooth_above_threshold_indeces(end)) * bin_size}];
                    receptive_analysis.([channel_names{neuron}, '_background_rate']) = [receptive_analysis.([channel_names{neuron}, '_background_rate']); event_strings{event}, {background_rate}];
                    receptive_analysis.([channel_names{neuron}, '_threshold']) = [receptive_analysis.([channel_names{neuron}, '_threshold']); event_strings{event}, {smoothed_threshold}];
                    receptive_analysis.([channel_names{neuron}, '_peak_response']) = [receptive_analysis.([channel_names{neuron}, '_peak_response']); event_strings{event}, {peak - background_rate}];
                    receptive_analysis.([channel_names{neuron}, '_peak_latency']) = [receptive_analysis.([channel_names{neuron}, '_peak_latency']); event_strings{event}, {peak_index * bin_size}];
                    receptive_analysis.([channel_names{neuron}, '_response_magnitude']) = [receptive_analysis.([channel_names{neuron}, '_response_magnitude']); event_strings{event}, {sum(response(smooth_above_threshold_indeces(1):smooth_above_threshold_indeces(end)))}];
                end
            end
        end

        %% Remove empty fields
        struct_names = fieldnames(receptive_analysis);
        empty = cellfun(@(x) isempty(receptive_analysis.(x)), struct_names);
        receptive_analysis = rmfield(receptive_analysis, struct_names(empty));
        %% Saving receptive field analysis
        rf_filename = strrep(filename, 'PSTH', 'REC');
        rf_filename = strrep(rf_filename, 'format', 'FIELD');
        matfile = fullfile(rf_path, [rf_filename, '.mat']);
        save(matfile, 'receptive_analysis');
    end
end