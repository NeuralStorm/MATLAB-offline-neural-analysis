function [parsed_path] = parser(dir_path, animal_name, total_trials, total_events, trial_lower_bound, ...
                            is_non_strobed_and_strobed, event_map, ignore_sessions)
    parse_start = tic;
    %% Select Directory for debugging purposes
    % dir_path = uigetdir(pwd);

    % Creates a list of all the files in the given directory ending with
    % *.plx
    [plx_files, parsed_path, failed_path] = create_dir(dir_path, 'parsed', '.plx', ignore_sessions);

    export_params(parsed_path, 'parsed', failed_path, animal_name, total_trials, total_events, trial_lower_bound, ...
        is_non_strobed_and_strobed, event_map);

    % Runs through all of the .plx files in the selected directory
    fprintf('Parsing for %s\n', animal_name);
    for file_index = 1: length(plx_files)
        file = [dir_path, '/', plx_files(file_index).name];
        [~, file_name, ~] = fileparts(file);
        % Take the spike times and event times
        try
            try
                % tscounts and wfcounts dimension padded by extra column and row
                [tscounts, ~, evcounts, ~] = plx_info(file,1);
            catch ME
                if (strcmpi(ME.identifier,'MATLAB:TooManyOutputs'))
                    msg = ['Old version of plexon matlab sdk on path -- please remove and use the ', ...
                        'most recent version of the matlab offline sdk.'];
                    causeException = MException('MATLAB:myCode:depricatedSoftware', msg);
                    ME = addCause(ME,causeException);
                end
                rethrow(ME);
            end

            [tot_units, tot_channels] = size(tscounts);
            [~, channel_names] = plx_chan_names(file);

            subchan = {'i','a','b','c','d'};
            channel_map = [];
            for unit_i = 1:tot_units - 1 % Start at 0 for unsorted 
                for channel_i = 1:tot_channels - 1
                    if (tscounts(unit_i + 1, channel_i + 1) > 0)
                        %% get the timestamps for this channel and unit 
                        [~, channel_timestamps] = plx_ts(file, channel_i, unit_i);
                        % channel_names is a char array
                        current_channel = channel_names(channel_i, :);
                        split_channel = strsplit(current_channel, ' ');
                        current_channel = split_channel{1};
                        current_channel = deblank(current_channel);
                        current_subchan = subchan{unit_i + 1};
                        complete_channel_name = [current_channel, current_subchan];
                        channel_map = [channel_map; {complete_channel_name}, {channel_timestamps}];
                    end
                end
            end
            total_neurons = length(channel_map(:,1));

            [total_event_chan, event_channels] = plx_event_chanmap(file);
            event_ts = [];
            event_map_counter = 1;
            for channel = 1:total_event_chan
                %% strobbed channel is always 257
                current_channel = event_channels(channel);
                if current_channel == 257 && evcounts(channel) > 0
                    is_strobbed = true;
                    [total_timestamps, event_timestamps, strobed_values] = plx_event_ts(file, current_channel);
                    event_ts = [strobed_values, event_timestamps];
                elseif evcounts(channel) > trial_lower_bound
                    [total_timestamps, event_timestamps, ~] = plx_event_ts(file, current_channel);
                    total_timestamps = length(event_timestamps);
                    if is_non_strobed_and_strobed
                        currenet_event = event_map(event_map_counter);
                        event_ts = [event_ts; repmat(currenet_event, [total_timestamps, 1]), event_timestamps];
                        event_map_counter = event_map_counter + 1;
                    else
                        event_ts = [event_ts; repmat(current_channel, [total_timestamps, 1]), event_timestamps];
                    end
                end
            end

            %% Removed repeated time stamps
            [events_rows, ~] = size(event_ts);
            count = 1;
            while events_rows > (total_trials * total_events)
                i = 1;
                while i <= (length(event_ts)-1)
                    if ((event_ts(i, 2) + 2) > event_ts(i+1, 2))
                        event_ts(i + 1,:) = [];
                    end
                    i = i + 1;
                end
                [events_rows, ~] = size(event_ts);
                if count > 15
                    warning('Potential infinite loop in %s, when trying to remove duplicate events.', ...
                        'Check to make sure that the total events is greater than the standard total', ...
                        'trials * total events');
                    break;
                end
                count = count + 1;
            end

            event_ts = sortrows(event_ts, 2);
            channel_map = sortrows(channel_map, 1);

            %% Saves parsed files
            % filename = ['PARSED.', file_name, '.mat'];
            filename = [file_name, '.mat'];
            matfile = fullfile(parsed_path, filename);
            save(matfile, 'tscounts', 'evcounts', 'event_ts', 'channel_map');
        catch ME
            handle_ME(ME, failed_path, file_name);
        end
    end
    fprintf('Finished parsing for %s. It took %s\n', ...
        animal_name, num2str(toc(parse_start)));
end