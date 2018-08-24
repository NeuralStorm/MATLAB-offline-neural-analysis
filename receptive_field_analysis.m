function [] = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
        threshold_scale, sig_check, sig_bins, moving_coeff, amplitude_coeff, span, wanted_events)
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
        end

        %% Set variables used for pre window analysis
        pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
        pre_avg_background_firing = [];
        thresholds = [];
        pre_neurons = [];
        smoothed_pre_neurons = [];
        %% Pre time PSTH calculation
        for i = 1: numel(event_struct.pre_time_activity)
            % If the index is at the end of a neuron x bin subsection the the matrix
            % it takes a slice of the array that contains that neuron and computes various info
            if mod(i, pre_time_bins) == 0
                % Creates PSTH for the current neuron only
                neuron = event_struct.pre_time_activity((i - pre_time_bins + 1 ): i);
                pre_neurons = [pre_neurons; {neuron}];
                %TODO call smooth or filter?
                smoothed_neuron = smooth(neuron, span);
                smoothed_pre_neurons = [smoothed_pre_neurons, {smoothed_neuron}];
                smoothed_avg_background = mean(smoothed_neuron);
                pre_avg_background_firing = [pre_avg_background_firing; smoothed_avg_background];
                smoothed_std_background = std(smoothed_neuron);
                smoothed_threshold = smoothed_avg_background + (threshold_scale * smoothed_std_background);
                thresholds = [thresholds; smoothed_threshold];
            end
        end

        post_neurons = [];
        %% Post time analysis
        post_time_bins = (length([0:bin_size:post_time])) - 1;
        first_latency = {};
        last_latency = {};
        background_rate = {};
        peak_response = {};
        response_magnitude = {};
        peak_latency = {};
        % Creates sorted event labels
        sorted_events = sort(events(:,1));
        for i = 1: numel(event_struct.post_time_activity)
            if i == 1
                event_label = sorted_events(1);
            end
            %% Find the receptive field variables if significant response
            if mod(i, post_time_bins) == 0
                % Grabs PSTH of the current neuron only
                neuron = event_struct.post_time_activity((i - post_time_bins + 1 ): i);
                post_neurons = [post_neurons; {neuron}];
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
                above_threshold_indeces = find(smoothed_neuron > thresholds(length(post_neurons)));
                above_threshold = smoothed_neuron(above_threshold_indeces);
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
                    if is_consecutive(above_threshold_indeces, sig_bins)
                        sig_response = true;
                    end
                % TODO verify if t test and ks test should use smoothed or non smoothed
                elseif sig_check == 4
                    %TODO verify that ttest should use consecutive bins
                    reject_null = ttest2(smoothed_neuron, smoothed_pre_neurons{length(post_neurons)});
                    if isnan(reject_null)
                        reject_null = false;
                    end
                    if reject_null && is_consecutive(above_threshold_indeces, sig_bins)
                        sig_response = true;
                    end
                elseif sig_check == 5
                    %TODO verify that ks test should use consecutive bins
                    reject_null =  kstest2(smoothed_neuron, smoothed_pre_neurons{length(post_neurons)});
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
                        event_index = i / (total_neurons * post_time_bins);
                        event_label = sorted_events(event_index);
                    end
                    neuron_name = channel_names{neuron_index};
                    [max_peak, max_index] = max(above_threshold);
                    % if event_label
                    first_latency = [first_latency; {neuron_name}, {event_label}, {(above_threshold_indeces(1) * bin_size)}];
                    last_latency =  [last_latency; {neuron_name}, {event_label}, {(above_threshold_indeces(end) * bin_size)}];
                    background_rate = [background_rate; {neuron_name}, {event_label}, {pre_avg_background_firing(length(post_neurons))}];
                    peak_response = [peak_response; {neuron_name}, {event_label}, {pre_avg_background_firing(length(post_neurons))}];
                    response_magnitude = [response_magnitude; {neuron_name}, {event_label}, {max_peak}];
                    peak_latency = [peak_latency; {neuron_name}, {event_label}, {(above_threshold_indeces(max_index) * bin_size)}];
                end
            end
        end % End of post bin analysis

        for j = 1:total_neurons
            neuron_first_latency = first_latency(strcmp(first_latency(:,1), channel_names{j}), :);
            neuron_last_latency = last_latency(strcmp(last_latency(:,1), channel_names{j}), :);
            neuron_background_rate = background_rate(strcmp(background_rate(:,1), channel_names{j}), :);
            neuron_peak_response = peak_response(strcmp(peak_response(:,1), channel_names{j}), :);
            neuron_response_magnitude = response_magnitude(strcmp(response_magnitude(:,1), channel_names{j}), :);
            neuron_peak_latency = peak_latency(strcmp(peak_latency(:,1), channel_names{j}), :);
            for event = 1:length(wanted_events)
                % calculate mean example: mean(cell2mat(receptive_analysis.sig001a_first_latency{1,2}))
                receptive_analysis.([channel_names{j}, '_first_latency']) = [receptive_analysis.([channel_names{j}, '_first_latency']); event_strings{event}, {neuron_first_latency(cell2mat(neuron_first_latency(:,2)) == wanted_events(event), 3)}];
                receptive_analysis.([channel_names{j}, '_last_latency']) = [receptive_analysis.([channel_names{j}, '_last_latency']); event_strings{event}, {neuron_last_latency(cell2mat(neuron_last_latency(:,2)) == wanted_events(event), 3)}];
                receptive_analysis.([channel_names{j}, '_background_rate']) = [receptive_analysis.([channel_names{j}, '_background_rate']); event_strings{event}, {neuron_background_rate(cell2mat(neuron_background_rate(:,2)) == wanted_events(event), 3)}];
                receptive_analysis.([channel_names{j}, '_peak_response']) = [receptive_analysis.([channel_names{j}, '_peak_response']); event_strings{event}, {neuron_peak_response(cell2mat(neuron_peak_response(:,2)) == wanted_events(event), 3)}];
                receptive_analysis.([channel_names{j}, '_response_magnitude']) = [receptive_analysis.([channel_names{j}, '_response_magnitude']); event_strings{event}, {neuron_response_magnitude(cell2mat(neuron_response_magnitude(:,2)) == wanted_events(event), 3)}];
                receptive_analysis.([channel_names{j}, '_peak_latency']) = [receptive_analysis.([channel_names{j}, '_peak_latency']); event_strings{event}, {neuron_peak_latency(cell2mat(neuron_peak_latency(:,2)) == wanted_events(event), 3)}];
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
        save(matfile, 'thresholds', 'neuron', 'receptive_analysis', 'above_threshold', 'smoothed_neuron', 'first_latency');
    end
end