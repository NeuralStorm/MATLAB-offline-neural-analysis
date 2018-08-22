function [] = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
        threshold_scale, sig_check, sig_bins, moving_coeff, amplitude_coeff)
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
        % disp(channel_names);
        for name = 1:length(channel_names)
            neuron_name = channel_names{name};
            receptive_analysis.([neuron_name, '_first_latency']) = [];
            receptive_analysis.([neuron_name, '_last_latency']) = [];
            receptive_analysis.([neuron_name, '_peak_latency']) = [];
            receptive_analysis.([neuron_name, '_peak_response']) = [];
            receptive_analysis.([neuron_name, '_response_magnitude']) = [];
            receptive_analysis.([neuron_name, '_background_rate']) = [];
            receptive_analysis.([neuron_name, '_neuron_info']) = [];
        end
        %% Calculates background firing rate before event
        pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
        pre_avg_background_firing = [];
        pre_thresholds = [];
        pre_neurons = [];
        %% Pre time PSTH calculation
        for i = 1: numel(event_struct.pre_time_activity)
            % If the index is at the end of a neuron x bin subsection the the matrix
            % it takes a slice of the array that contains that neuron and computes various info
            if mod(i, pre_time_bins) == 0
                % Creates PSTH for the current neuron only
                neuron = event_struct.pre_time_activity((i - pre_time_bins + 1 ): i);
                pre_neurons = [pre_neurons; {neuron}];
                avg_firing_rate = mean(neuron)/pre_time;
                pre_avg_background_firing = [pre_avg_background_firing; avg_firing_rate];
                %TODO call smooth or filter?
                smoothed_neuron = smooth(neuron, span);
                %% Set threshold
                avg_threshold = avg_firing_rate + (threshold_scale * (std(neuron) / pre_time));
                pre_thresholds = [pre_thresholds; avg_threshold];
            end
        end

        %% Post time analysis
        post_time_bins = (length([0:bin_size:post_time])) - 1;
        post_avg_background_firing = [];
        significant = [];
        for i = 1: numel(event_struct.post_time_activity)
            %% Find the receptive field variables if significant response
            if mod(i, post_time_bins) == 0
                % Grabs PSTH of the current neuron only
                neuron = event_struct.post_time_activity((i - post_time_bins + 1 ): i);
                neuron_firing_rate = arrayfun(@(x) (x/bin_size), neuron);
                avg_firing_rate = mean(neuron)/post_time;
                post_avg_background_firing = [post_avg_background_firing; avg_firing_rate];
                % Smooths the psth for the given neuron
                %TODO call smooth or filter?
                % smoothed_neuron = filter(moving_coeff, amplitude_coeff, neuron);
                smoothed_neuron = smooth(neuron, span);
                % Grabs the first non zero elements of a response only
                initial_response = [];
                for j = 1:length(smoothed_neuron)
                    if smoothed_neuron(j) ~= 0
                        initial_response = [initial_response; smoothed_neuron(j)];
                    elseif ~isempty(initial_response) && smoothed_neuron(j) == 0
                        break;
                    end
                end
                %% Determine if given neuron has a significant response 
                sig_response = false;
                above_threshold_indeces = find(neuron_firing_rate > pre_thresholds(length(post_avg_background_firing)));
                above_threshold = neuron(above_threshold_indeces);
                if sig_check == 1
                    %% checks if the average firing rate is greater than the pre_time average firing rate
                    if length(above_threshold) > 0
                        sig_response = true;
                    end
                elseif sig_check == 2
                    %% checks to see if at least x bins are above threshold
                    if length(above_threshold) >= sig_bins
                        sig_response = true;
                    end
                elseif sig_check == 3
                    %% checks to see if at least x consecutive bins are above threshold
                    consecutive_bins = 0;
                    if length(above_threshold_indeces) >= sig_bins
                        for bin = 1:(length(above_threshold) - 1)
                            if above_threshold_indeces(bin + 1) - above_threshold_indeces(bin) == 1
                                consecutive_bins = consecutive_bins + 1;
                                if consecutive_bins >= sig_bins
                                    sig_response = true;
                                    break;
                                end
                            else
                                consecutive_bins = 0;
                            end
                        end
                    end
                elseif sig_check == 4
                    %TODO verify that ttest was also supposed to have at least some activity above threshold
                    reject_null = ttest2(neuron, pre_neurons{length(post_avg_background_firing)});
                    if isnan(reject_null)
                        reject_null = false;
                    end
                    if reject_null && (length(above_threshold) >= sig_bins)
                        sig_response = true;
                    end
                elseif sig_check == 5
                    %TODO verify that ks test was also supposed to have at least some activity above threshold
                    reject_null =  kstest2(neuron, pre_neurons{length(post_avg_background_firing)});
                    if isnan(reject_null)
                        reject_null = false;
                    end
                    if reject_null && length(above_threshold) >= sig_bins
                        sig_response = true;
                    end
                else
                    error('Invalid sig check. Valid options for sig_check are 1 - 5, please see main documentation for more details');
                end
                %% Calculate variables if sig response
                if sig_response
                    neuron_index = mod((i/post_time_bins), total_neurons);
                    if neuron_index == 0
                        neuron_index = total_neurons;
                    end
                    neuron_name = channel_names{neuron_index};
                    [max_peak, max_index] = max(above_threshold);
                    receptive_analysis.([neuron_name, '_first_latency']) = [receptive_analysis.([neuron_name, '_first_latency']); (above_threshold_indeces(1) * bin_size)];
                    receptive_analysis.([neuron_name, '_last_latency']) = [receptive_analysis.([neuron_name, '_last_latency']); (above_threshold_indeces(end) * bin_size)];
                    receptive_analysis.([neuron_name, '_background_rate']) = [receptive_analysis.([neuron_name, '_background_rate']); pre_avg_background_firing(length(post_avg_background_firing))];
                    receptive_analysis.([neuron_name, '_peak_response']) = [receptive_analysis.([neuron_name, '_peak_response']); max_peak];
                    receptive_analysis.([neuron_name, '_response_magnitude']) = [receptive_analysis.([neuron_name, '_response_magnitude']); sum(above_threshold)];
                    receptive_analysis.([neuron_name, '_peak_latency']) = [receptive_analysis.([neuron_name, '_peak_latency']); (above_threshold_indeces(max_index) * bin_size)]; 
                    receptive_analysis.([neuron_name, '_neuron_info']) = [receptive_analysis.([neuron_name, '_neuron_info']); [neuron; neuron_firing_rate]];
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
        save(matfile, 'pre_avg_background_firing', 'pre_thresholds', 'post_avg_background_firing', 'neuron', 'neuron_firing_rate', 'receptive_analysis', 'above_threshold', 'smoothed_neuron');
    end
end