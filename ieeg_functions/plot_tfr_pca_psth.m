function [] = plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, label_log, ...
    pc_log, component_results, psth_struct, bin_size, window_start, ...
    window_end, baseline_start, baseline_end, response_start, response_end, ...
    feature_filter, feature_value, sub_rows, sub_cols, use_z, st_type, ymax_scale, ...
    transparency, min_components, plot_avg_pow)

    %% Purpose: Create subplot with tfrs, percent variance, pc time courses, and electrode
    %           weighting to look at the entire data set for given session
    %% Input
    % save_path: path where subplots are saved
    % tfr_path: path to contour tfr plots gor given subject and recording session
    % tfr_file_list: list of .fig files at tfr_path
    %                (can be created by calling get_file_list(tfr_path, '.fig')
    % label_log: struct w/ fields for each feature set
    %            field: table with columns
    %                   'sig_channels': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'label': String: associated region or grouping of electrodes
    %                   'label_id': Int: unique id used for labels
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel
    % component_results: struct w/ fields for each feature set ran through PCA
    %                    'all_events': Nx2 cell array where N is the number of events
    %                                  Column 1: event label (ex: event_1)
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                             Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each feature
    %                                  weighted_mnts: mnts mapped into pc space with feature filter applied
    %                                  tfr: struct with fields for each power
    %                                       (Note: This was added in the batch_power_pca function and not in the calc_pca call)
    %                                       bandname: struct with fields for each event type
    %                                                 event: struct with fields with tfr & z tfr avg, std, ste
    %                                                        fieldnames: avg_tfr, avg_z_tfr, std_tfr, std_z_tfr, ste_tfr, & ste_z_tfr
    % psth_struct: struct w/ fields for each feature
    %              'all_events': Nx2 cell array where N is the number of events
    %                            Column 1: event label (ex: event_1)
    %              feature_name: struct typically based on regions and powers
    %                            relative_response: Numerical matrix with dimensions Trials x ((tot pcs or channels) * tot bins)
    %                            event: struct with fields:
    %                                   relative_response: Numerical matrix w/ dims Trials x ((tot pcs or channels) * tot bins)
    %                                   psth: Numerical matrix w/ dims 1 X ((tot pcs or channels) * tot bins)
    %                                         Mathematically: Sum of trials in relative response
    %                                   componenet: struct based on components (either pc or channel) used to create relative response
    %                                               relative_response: Numerical matrix w/ dims Trials x tot bins
    %                                               psth: Numerical matrix w/ dims 1 X tot bins
    % bin_size: size of bins
    % window_start: start time of window
    % window_end: end time of window
    % baseline_start: baseline window start
    % baseline_end: baseline window end
    % response_start: response window start
    % response_end: response window end
    % feature_filter: String with description for pcs
    %                 'all': keep all pcs after PCA
    %                 'pcs': Keep # of pcs set in feature_value
    %                 'percent_var': Use X# of PCs that meet set % in feature_value
    % feature_value: Int matched to feature_filter
    %                'all': left empty
    %                'pcs': Int for # of pcs to keep
    %                'percent_var': % of variance desired to be explained by pcs
    % sub_rows: Int: desired rows to be shown on subplot (default is typically 5)
    % sub_cols: Int: desired cols to be shown on subplot (default is typically 2)
    % use_z: Boolean
    %             1: use z_tfr for plotting
    %             0: use tfr for plotting
    % st_type: String: 'std' to use std or 'ste' to use ste for shading
    % ymax_scale: Float: how much to scale y max to give room for words
    % transparency: Float: how dark should the shading be for st_type
    % min_components: Int: min componenets needed to make subplot
    % plot_avg_pow: Boolean
    %               0: Does not plot avg power time course
    %               1: Plot avg power time course
    %% Output: There is no return. The graphs are saved directly to the path indicated by save_path

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow

    event_window = window_start:bin_size:window_end;
    event_window(1) = [];

    if use_z
        z_type = 'z_';
    else
        z_type = '';
    end

    freq_list = {'highfreq', 'lowfreq'};
    tot_tfrs = length(freq_list);

    unique_regions = fieldnames(pc_log);
    parfor feature_i = 1:length(unique_regions)
        feature = unique_regions{feature_i};
        st_vec = [];

        [color_struct, region_list] = create_color_struct(color_map, ...
            feature, label_log.(feature));
        event_strings = psth_struct.all_events(:,1)';
        region_neurons = pc_log.(feature).sig_channels;
        total_region_neurons = length(region_neurons);
        for event_i = 1:length(event_strings)
            event = event_strings{event_i};
            %% Skip events without TFRs
            if isempty(tfr_file_list(contains({tfr_file_list.name}, event)))
                continue
            end
            main_plot = figure;
            %TODO add more info to title plot
            component_var = component_results.(feature).component_variance;
            tot_components = length(component_var);
            if tot_components < min_components
                continue
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Text plot
            % Position: 1st row, last column
            description = [feature, ' ' event, 'tot components: ', num2str(tot_components)];
            description = strrep(description, '_', ' ');
            figure(main_plot);
            ax = scrollsubplot(sub_rows, sub_cols, sub_cols);
            pos=get(ax, 'Position');
            annotation('textbox', pos, 'String', description, ...
                'FitBoxToText','off');
            axis off;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Frequency is not an issue since we plot all the frequencies
            tfr_counter = 1;
            for sub_reg_i = 1:numel(region_list)
                sub_reg = region_list{sub_reg_i};
                for sub_pow_i = 1:tot_tfrs
                    curr_freq = freq_list{sub_pow_i};
                    %% load figure
                    tfr_filename = get_tfr_filename(tfr_file_list, curr_freq, sub_reg, event);
                    tfr_file = fullfile(tfr_path, tfr_filename);
                    tfr_fig = openfig(tfr_file);
                    tfr_ax = get(gca,'Children');
                    xdata = get(tfr_ax, 'XData');
                    xlabel('Time (s)');
                    ydata = get(tfr_ax, 'YData');
                    ylabel('Frequency')
                    zdata = get(tfr_ax, 'CData');
                    figure(main_plot);
                    hold on
                    scrollsubplot(sub_rows, sub_cols, tfr_counter);
                    contourf(xdata, ydata, zdata, 40, 'linecolor','none')
                    title([curr_freq, ' ', sub_reg, ' ', event])
                    ylabel('Frequency (Hz)');
                    xlabel('Time(s)');
                    % Put color bar on text plot
                    scrollsubplot(sub_rows, sub_cols, sub_cols);
                    colorbar('westoutside')
                    hold off
                    tfr_counter = tfr_counter + sub_cols;
                    close(tfr_fig);
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Var plot
            % Position: 2nd row, last column
            scrollsubplot(sub_rows, sub_cols, (tfr_counter - 1));
            bar(component_var, 'EdgeColor', 'none');
            xlabel('PC #');
            ylabel('% Variance');
            title('Percent Variance Explained')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            weight_counter = tfr_counter + 1;
            event_psth = psth_struct.(feature).(event).psth;

            event_max = 1.1 * max(event_psth) + eps;
            if min(event_psth) >= 0
                event_min = 0;
            else
                event_min = 1.1 * min(event_psth);
            end

            %% Creating the PSTH graphs
            for comp_i = 1:total_region_neurons
                psth_name = region_neurons{comp_i};
                psth = psth_struct.(feature).(event).(psth_name).psth;
                relative_response = psth_struct.(feature).(event).(psth_name).relative_response;
                if strcmpi(st_type, 'std')
                    st_vec = std(relative_response);
                elseif strcmpi(st_type, 'ste')
                    [~, tot_obs] = size(relative_response);
                    st_vec = std(relative_response) ./ sqrt(tot_obs);
                end
                figure(main_plot);
                scrollsubplot(sub_rows, sub_cols, tfr_counter);
                hold on
                yyaxis left
                [l, ~] = boundedline(event_window, psth, st_vec, ...
                    'transparency', transparency);
                legend_lines = l;
                %TODO do more manipulation of shading
                ylim([event_min event_max]);
                line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                ylabel('PC Space');

                if plot_avg_pow
                    yyaxis right
                    tfr_struct = component_results.(feature).tfr;
                    unique_tfrs = fieldnames(tfr_struct);
                    color_i = 1;
                    for tfr_i = 1:numel(unique_tfrs)
                        curr_tfr = unique_tfrs{tfr_i};
                        avg_tfr = tfr_struct.(curr_tfr).(event).(['avg_', z_type, 'tfr']);
                        st_tfr = tfr_struct.(curr_tfr).(event).([st_type, '_', z_type, 'tfr']);
                        [l, ~] = boundedline(event_window, avg_tfr, st_tfr, 'cmap', color_map(color_i, :), ...
                            'transparency', transparency);
                        legend_lines = [legend_lines, l];
                        if color_i < size(color_map, 1)
                            color_i = color_i + 1;
                        else
                            color_i = 1;
                        end
                    end
                    lg = legend(legend_lines, [{'pc'}; unique_tfrs]);
                    legend('boxoff');
                    lg.Location = 'Best';
                    lg.Orientation = 'Horizontal';
                    ylabel('Avg. Pow');
                end
                title(psth_name);
                xlabel('Time (s)');
                xlim([round(window_start) round(window_end)]);
                hold off
                tfr_counter = tfr_counter + sub_cols;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Plot PCA weights
            plot_incrememnt = sub_cols;
            pca_weights = component_results.(feature).coeff;
            [~, tot_components] = size(pca_weights);
            if strcmpi(feature_filter, 'pcs') && feature_value < tot_components
                %% Grabs desired number of principal components weights
                pca_weights = pca_weights(:, 1:feature_value);
            end
            tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
                sub_rows, sub_cols, weight_counter, plot_incrememnt);

            sub_features = strsplit(feature, '_');
            band_locs = ~ismember(sub_features, label_log.(feature).label);
            band_list = sub_features(band_locs);
            plot_power_shifts(label_log.(feature), sub_features, band_list, ...
                band_locs, tot_plots, weight_counter, plot_incrememnt, ...
                sub_rows, sub_cols);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(main_plot);
            filename = [feature, '_', event, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end

function [tfr_filename] = get_tfr_filename(tfr_file_list, curr_freq, sub_reg, event)
    tfr_i = contains({tfr_file_list.name}, curr_freq) ...
        & contains({tfr_file_list.name}, sub_reg) ...
        & contains({tfr_file_list.name}, event);
    tfr_filename = tfr_file_list(tfr_i).name;
end