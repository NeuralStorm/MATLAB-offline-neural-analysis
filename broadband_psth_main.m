%%%%%%%%%%%%%%% ISSUES %%%%%%%%%%%%%%%%%%%%%%%%%
% -low_high_file is not able to handle the file structure of the data -
% using bandpass filtering now
% - Recording session are pulled from the filename and it
% seems like label_neuons cannot handle a recording session of 0 - I
% changed recroding session 0-1 to 1 in the file names but not within the
% mat files
% - Should change sep_parser to a more generalized name
% - PSTH plots are being overwritted with every file
%%%%%%%%%%%%%%% PROGRESS %%%%%%%%%%%%%%%%%%%%%%%
% 

function [] = broadband_psth_main()
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = [original_path, '/', animal_name];
        config = import_config(animal_path, 'psth');
        if isempty(config.trial_range)
            config.trial_range = [];
        else
            config.trial_range = str2num(config.trial_range);
        end

        export_params(animal_path, 'main', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if config.parse_files
                 parsed_path = sep_parser(animal_name, animal_path, config);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Find Spikes & Event Time Stamps  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
              if config.find_spikes
                  spikes_path = batch_find_spikes(animal_name, parsed_path, config);                  
              else
                  spikes_path = [parsed_path, '/spikes'];
              end
              
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                batch_label(animal_path, animal_name, spikes_path);
            end  
              

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% The following code is copied from psth_main.m%%
            %   all parsed_path(s) changed to spikes_path    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_psth
                psth_path = batch_format_psth(spikes_path, animal_name, config);
            else
                psth_path = [spikes_path, '/psth'];
            end

            if config.update_psth_windows
                failed_path = [psth_path, '/failed_', 'window_slice'];
                if exist(failed_path, 'dir') == 7
                    delete([failed_path, '/*']);
                    rmdir(failed_path);
                end
                file_list = get_file_list(psth_path, '.mat', config.ignore_sessions);
                for file_index = 1:length(file_list)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(psth_path, file_list(file_index).name);
                        [~, filename, ~] = fileparts(file);

                        %% Load needed variables from psth and does the receptive field analysis
                        load(file, 'labeled_data', 'psth_struct');
                        %% Check psth variables to make sure they are not empty
                        empty_vars = check_variables(file, labeled_data, psth_struct);
                        if empty_vars
                            continue
                        end

                        %% Add analysis window
                        [baseline_window, response_window] = create_analysis_windows(labeled_data, psth_struct, ...
                            config.pre_time, config.pre_start, config.pre_end, config.post_time, ...
                            config.post_start, config.post_end, config.bin_size);

                        %% Saving outputs
                        matfile = fullfile(psth_path, [filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, psth_struct, labeled_data);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'baseline_window', 'response_window', '-append');
                        export_params(psth_path, 'format_psth', spikes_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'PSTH', 'format', config);
            else
                rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'psth_graphs', '.mat', 'PSTH', 'format', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, config.ignore_sessions);
            end
        end
            
            

    end
    toc(start_time);
end

