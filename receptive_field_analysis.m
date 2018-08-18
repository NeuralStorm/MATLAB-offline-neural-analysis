function [] = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, threshold_type, threshold_scale)
    tic

    if pre_time <= 0.050
        error('Pre time can not be set to 0 for receptive field analysis. Recreate the PSTH format with a different pre time.');
    end

    if strcmpi(threshold_type, 'ci')
        switch threshold_scale
            case 1
                threshold_scale = 1.645; % 90% confidence
            case 2
                threshold_scale = 1.96; % 95% confidence
            case 3
                threshold_scale = 2.576; % 99% confidence
            otherwise
                error('Unsuported confidence interval, try 1 for 90%, 2 for 95%, or 3 for 99%');
        end
    elseif ~strcmpi(threshold_type, 'std')
        error('Undefined threshold type. Try std for standard deviation or ci for confidence interval');
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
        fprintf('Bootstrapping PSTH for %s on %s\n', animal_name, current_day);

        load(current_file);

        %% Calculates background firing rate before event
        % TODO save each background rate seperately or create a matrix with firing rate?
        % TODO or create a struct for each variable and save each neuron seperately?
        pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
        background_firing = [];
        avg_background_firing = [];
        thresholds = [];
        %% Goes through every index in the pre_time activity PSTH matrix
        for i = 1: numel(event_struct.pre_time_activity)
            % If the index is at the end of a neuron x bin subsection the the matrix
            % it takes a slice of the array that contains that neuron and computes various info
            if mod(i, pre_time_bins) == 0
                % TODO should the scale be in seconds or milliseconds?
                neuron = event_struct.pre_time_activity((i - pre_time_bins + 1 ): i);
                avg_firing_rate = mean(neuron)/pre_time;
                avg_background_firing = [avg_background_firing; avg_firing_rate];
                %% Set threshold
                avg_threshold = avg_firing_rate + (threshold_scale * (std(neuron) / pre_time));
                thresholds = [thresholds; avg_threshold];
            end
        end

        % TODO verify indexing will work with nonsymmetrical windows (ie pre = 100ms post = 200ms)
        post_time_bins = (length([-abs(post_time): bin_size: 0])) - 1;
        for i = 1: numel(event_struct.post_time_activity)
            if mod(i, post_time_bins) == 0
                %% Determine if given neuron has a significant response
            end
        end

        %% Saving receptive field analysis
        rf_filename = strrep(filename, 'PSTH', 'REC');
        rf_filename = strrep(filename, 'format', 'FIELD');
        matfile = fullfile(rf_path, [rf_filename, '.mat']);
        save(matfile, 'avg_background_firing', 'thresholds');
    end
end