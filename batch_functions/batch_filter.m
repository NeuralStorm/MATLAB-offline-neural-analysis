function [] = batch_filter(save_path, failed_path, data_path, dir_name, ...
        config, label_table)
    %% Find files to filter
    filter_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    fprintf('Filtering analog data for %s \n', dir_name);
    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'labeled_data', 'sample_rate', 'filename_meta', 'event_samples');

            %% Select channels
            selected_data = select_data(labeled_data, label_table, ...
                filename_meta.session_num);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Filter           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~config.use_raw
                filtered_map = filter_continuous(selected_data, sample_rate, config.notch_filt, ...
                    config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                    config.sep_filt_type, config.sep_filt_freq, config.sep_filt_order);
            else
                unique_regions = fieldnames(selected_data);
                data_table = table;
                for region_i = 1:length(unique_regions)
                    region = unique_regions{region_i};
                    region_table = selected_data.(region);
                    region_table = removevars(region_table, ...
                        {'selected_channels', 'recording_session', 'date', 'recording_notes'});
                    data_table = [data_table; region_table];
                end
                data_table.Properties.VariableNames = {'sig_channels', ...
                    'user_channels', 'label', 'label_id', 'data'};
                %% unfiltered data is called filtered for convience of calling slicing function
                filtered_map = table2struct(data_table);
            end

            matfile = fullfile(save_path, ['filtered_', filename_meta.filename]);
            save(matfile, '-v7.3', 'filtered_map', 'sample_rate', ...
                'event_samples', 'filename_meta', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished filtering for %s. It took %s \n', ...
        dir_name, num2str(toc(filter_start)));
end