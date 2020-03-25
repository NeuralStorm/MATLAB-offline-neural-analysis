function [psth_path] = OAT_batch_format_psth(parent_path, dir_name, config)
    psth_start = tic;
    [psth_path, failed_path] = create_dir(parent_path, 'psth');
    [file_list] = get_file_list(parent_path, '.mat', config.ignore_sessions);

    pre_time = config.pre_time; pre_start = config.pre_start; pre_end = config.pre_end;
    post_time = config.post_time; post_start = config.post_start; post_end = config.post_end;
    bin_size = config.bin_size; ignore_sessions = config.ignore_sessions;
    tot_bins = config.tot_bins;
    wanted_events = config.wanted_events; trial_lower_bound = config.trial_lower_bound;
    trial_range = config.trial_range;

    export_params(psth_path, 'psth', failed_path, dir_name, pre_time, pre_start, ...
        pre_end, post_time, post_start, post_end, bin_size, ignore_sessions, trial_range, ...
        wanted_events, trial_lower_bound);

    fprintf('Calculating PSTH for %s \n', dir_name);
    %% Goes through all the files and creates PSTHs according to the parameters set in config
    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [parent_path, '/', file_list(file_index).name];
            [~, filename, ~] = fileparts(file);
            load(file, 'event_ts', 'labeled_data');
            %% Check parsed variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, labeled_data);
            if empty_vars
                continue
            end

            %% Format PSTH
            [psth_struct, event_ts] = OAT_format_PSTH(event_ts, labeled_data, tot_bins, wanted_events, trial_range, trial_lower_bound);
%{
            %% Add analysis window
            [baseline_window, response_window] = create_analysis_windows(labeled_data, ...
                psth_struct, pre_time, pre_start, pre_end, post_time, post_start, ...
                post_end, bin_size);
%}
            response_window = psth_struct;
            baseline_window = psth_struct;
            
            %% Saving outputs
            matfile = fullfile(psth_path, ['PSTH_format_', filename, '.mat']);
            %% Check PSTH output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, psth_struct, event_ts);
            if empty_vars
                continue
            end

            %% Save file if all variables are not empty
            save(matfile, 'psth_struct', 'event_ts', 'labeled_data', 'baseline_window', 'response_window');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished calculating PSTH for %s. It took %s \n', ...
        dir_name, num2str(toc(psth_start)));
end