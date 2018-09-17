function [rf_path] = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
        threshold_scale, sig_check, sig_bins, span, wanted_events)
    tic
    %TODO add error catching

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

        region_names = fieldnames(labeled_neurons);
        for region = 1:length(region_names)
            current_region = region_names{region};
            region_neurons = [labeled_neurons.(current_region)(:,1), labeled_neurons.(current_region)(:,end)];
            %% Creates dynamic field for struct
            for neuron = 1:length(region_neurons)
                neuron_name = region_neurons{neuron};
                receptive_analysis.([current_region]).([neuron_name, '_first_latency']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_last_latency']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_duration']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_peak_latency']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_peak_response']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_response_magnitude']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_corrected_peak_response']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_corrected_response_magnitude']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_normalized_response_magnitude']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_principal_event']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_background_rate']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_background_std']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_threshold']) = [];
                receptive_analysis.([current_region]).([neuron_name, '_total_significant_events']) = [];
            end

            %% Set variables used for pre window analysis
            pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
            pre_avg_background_firing = [];
            thresholds = [];
            pre_neurons = [];
            smoothed_pre_neurons = [];

            for event = 1:length(wanted_events)
                current_event = event_strings{event};
                norm_pre_window = event_struct.([current_event, '_norm_pre_time_activity']);
                norm_post_window = event_struct.([current_event, '_norm_post_time_activity']);
                for neuron = 1:length(region_neurons)
                    neuron_name = region_neurons{neuron};
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
                            reject_null =  kstest2(norm_pre_window(neuron, :), norm_post_window(neuron, :));
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
                        %% Finds results of the receptive field analysis
                        response = norm_post_window(neuron, :);
                        above_threshold = response(smooth_above_threshold_indeces);
                        peak = max(above_threshold);
                        peak_index = find(peak == response);
                        background_rate = mean(norm_pre_window(neuron, :));
                        response_magnitude = sum(response(smooth_above_threshold_indeces(1):smooth_above_threshold_indeces(end)));
                        first_latency = (smooth_above_threshold_indeces(1)) * bin_size;
                        last_latency = (smooth_above_threshold_indeces(end)) * bin_size;

                        %% Stores information from significant neuron in a struct
                        receptive_analysis.([current_region]).([neuron_name, '_first_latency']) = [receptive_analysis.([current_region]).([neuron_name, '_first_latency']); current_event, {first_latency}];
                        receptive_analysis.([current_region]).([neuron_name, '_last_latency']) = [receptive_analysis.([current_region]).([neuron_name, '_last_latency']); current_event, {last_latency}];
                        receptive_analysis.([current_region]).([neuron_name, '_duration']) = [receptive_analysis.([current_region]).([neuron_name, '_duration']); current_event, {last_latency - first_latency}];
                        receptive_analysis.([current_region]).([neuron_name, '_background_rate']) = [receptive_analysis.([current_region]).([neuron_name, '_background_rate']); current_event, {background_rate}];
                        receptive_analysis.([current_region]).([neuron_name, '_background_std']) = [receptive_analysis.([current_region]).([neuron_name, '_background_std']); current_event, {std(norm_pre_window(neuron,:))}];
                        receptive_analysis.([current_region]).([neuron_name, '_threshold']) = [receptive_analysis.([current_region]).([neuron_name, '_threshold']); current_event, {smoothed_threshold}];
                        receptive_analysis.([current_region]).([neuron_name, '_peak_response']) = [receptive_analysis.([current_region]).([neuron_name, '_peak_response']); current_event, {peak}];
                        receptive_analysis.([current_region]).([neuron_name, '_corrected_peak_response']) = [receptive_analysis.([current_region]).([neuron_name, '_corrected_peak_response']); current_event, {peak - background_rate}];
                        receptive_analysis.([current_region]).([neuron_name, '_peak_latency']) = [receptive_analysis.([current_region]).([neuron_name, '_peak_latency']); current_event, {peak_index * bin_size}];
                        receptive_analysis.([current_region]).([neuron_name, '_response_magnitude']) = [receptive_analysis.([current_region]).([neuron_name, '_response_magnitude']); current_event, {response_magnitude}];
                        receptive_analysis.([current_region]).([neuron_name, '_corrected_response_magnitude']) = [receptive_analysis.([current_region]).([neuron_name, '_corrected_response_magnitude']); current_event, {response_magnitude - background_rate}];
                    end
                end
            end
            
            %% Normalize response magnitude and find primary event for each neuron
            % Normalizes response magnitude on response magnitude, not response magnitude - background rate
            struct_names = fieldnames(receptive_analysis.([current_region]));
            for field = 1:length(struct_names)
                field_name = strsplit(struct_names{field}, '_');
                neuron_name = field_name{1};
                if contains(struct_names{field}, [neuron_name, '_response_magnitude']) && ~isempty(receptive_analysis.([current_region]).(struct_names{field}))
                    % seperated_file_name = strsplit(file_name, '.');
                    magnitude = getfield(receptive_analysis.([current_region]), struct_names{field});
                    receptive_analysis.([current_region]).([neuron_name, '_total_significant_events']) = length(magnitude(:,1));
                    [max_magnitude, max_magnitude_index] = max([magnitude{:,2}]);
                    norm_magnitude = num2cell([[magnitude{:,2}] ./ max_magnitude]');
                    receptive_analysis.([current_region]).([neuron_name, '_normalized_response_magnitude']) = horzcat(magnitude(:,1), norm_magnitude);
                    receptive_analysis.([current_region]).([neuron_name, '_principal_event']) = magnitude(max_magnitude_index, 1);
                end
            end
            %% Remove empty fields
            empty = cellfun(@(x) isempty(receptive_analysis.([current_region]).(x)), struct_names);
            receptive_analysis.([current_region]) = rmfield(receptive_analysis.([current_region]), struct_names(empty));
        end


        %% Saving receptive field analysis
        rf_filename = strrep(filename, 'PSTH', 'REC');
        rf_filename = strrep(rf_filename, 'format', 'FIELD');
        matfile = fullfile(rf_path, [rf_filename, '.mat']);
        save(matfile, 'receptive_analysis', 'labeled_neurons');
    end
end