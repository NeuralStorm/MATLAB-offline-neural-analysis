function [] = plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, label_log, mnts_struct, band_shifts,...
    component_results, psth_struct, event_info, bin_size, window_start, ...
    window_end, baseline_start, baseline_end, response_start, response_end, ...
    feature_filter, feature_value, sub_rows, sub_cols, st_type, ymax_scale, ...
    transparency, font_size, min_chans, plot_avg_pow, plot_shift_labels)
    %TODO figure(title, 'title string') something like that

    %% Purpose: Create subplot with tfrs, percent variance, pc time courses, and electrode
    %           weighting to look at the entire data set for given session
    %% Input
    % save_path: path where subplots are saved
    % tfr_path: path to contour tfr plots gor given subject and recording session
    % tfr_file_list: list of .fig files at tfr_path
    %                (can be created by calling get_file_list(tfr_path, '.fig')
    % label_log: table with columns
    %                   'sig_channels': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'label': String: associated region or grouping of electrodes
    %                   'label_id': Int: unique id used for labels
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel
    % component_results: struct w/ fields for each region set ran through PCA
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                             Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each region
    %                                  mnts: mnts mapped into pc space with region filter applied
    % psth_struct: struct w/ fields for each region
    %              region: structwith fields:
    %                          relative_response: Numerical matrix with dimensions Trials x ((tot pcs or channels) * tot bins)
    %                          label_order: order of pcs
    %                          chan_order: order of channels
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
    % min_chans: Int: min componenets needed to make subplot
    % plot_avg_pow: Boolean
    %               0: Does not plot avg power time course
    %               1: Plot avg power time course
    %% Output: There is no return. The graphs are saved directly to the path indicated by save_path

    tot_window_bins = get_tot_bins(window_start, window_end, bin_size);

    color_map = [0 0 0 % black
                256 0 0 % red
                0 0 256 % blue
                0 255 0 % green
                102 0 204 % magenta
                255 128 0] ./ 256; % yellow

    event_window = window_start:bin_size:window_end;
    event_window(1) = [];
    if ~isempty(tfr_file_list(contains({tfr_file_list.name}, 'all')))
        %% Adds "all" event label if tfr exists for all events
        event_labels = repmat({'all'}, [height(event_info), 1]);
        event_ts = NaN(height(event_info), 1);
        event_indices = [1:1:height(event_info)]';
        all_table = table(event_labels, event_ts, event_indices);
        event_info = [all_table; event_info];
    end

    unique_events = unique(event_info.event_labels);
    unique_regions = fieldnames(psth_struct);

    parfor reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        st_vec = [];

        region_log = label_log(strcmpi(label_log.label, region), :);
        [color_struct, region_list] = create_color_struct(color_map, ...
            region, region_log);
        chan_order = psth_struct.(region).label_order;
        tot_reg_chans = numel(chan_order);
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            %% Skip events without TFRs
            if isempty(tfr_file_list(contains({tfr_file_list.name}, event)))
                continue
            end
            main_plot = figure;
            set(gca,'DefaultTextFontSize', 1)
            %TODO add more info to title plot
            component_var = component_results.(region).component_variance;
            tot_chans = length(component_var);
            if tot_chans < min_chans
                continue
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Text plot
            % Position: 1st row, last column
            description = [region, ' event: ' event, ' tot components: ', num2str(tot_chans)];
            description = strrep(description, '_', ' ');
            figure(main_plot);
            ax = scrollsubplot(sub_rows, sub_cols, 1);
            pos=get(ax, 'Position');
            annotation('textbox', pos, 'String', description, ...
                'FitBoxToText','off');
            axis off;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Frequency is not an issue since we plot all the frequencies
            tfr_counter = 3;
            for sub_reg_i = 1:numel(region_list)
                sub_reg = region_list{sub_reg_i};
                if contains(sub_reg, '_')
                    split_reg = strsplit(sub_reg, '_');
                    sub_reg = split_reg{end};
                end
                %% load figure
                tfr_filename = get_tfr_filename(tfr_file_list, sub_reg, event);
                if isempty(tfr_filename)
                    close all
                    continue
                end
                tfr_file = fullfile(tfr_path, tfr_filename);
                tfr_fig = openfig(tfr_file);
                tfr_ax = get(gca,'Children');
                xdata = get(tfr_ax, 'XData');
                xlabel('Time (s)', 'FontSize', font_size);
                ydata = get(tfr_ax, 'YData');
                ylabel('Frequency', 'FontSize', font_size)
                zdata = get(tfr_ax, 'CData');
                figure(main_plot);
                hold on
                scrollsubplot(sub_rows, sub_cols, tfr_counter);
                contourf(xdata, ydata, zdata, 40, 'linecolor','none')
                %% Fix labels for logspace
                tot_ticks = numel(get(gca,'YTickLabel')) + 1; % +1 to make additional tick label
                frex = logspace(log10(1),log10(200),tot_ticks); % 1 and 200 is range of frequency
                set(gca,'YTickLabel',round(frex(2:end))); % 2:end because 1 is actually the bottom, not the first tick mark
                xlim([window_start, window_end])
                title([sub_reg, ' event: ', event], 'FontSize', font_size)
                ylabel('Frequency (Hz)', 'FontSize', font_size);
                xlabel('Time(s)', 'FontSize', font_size);
                % Put color bar on text plot
                scrollsubplot(sub_rows, sub_cols, 1);
                hold on
                colorbar('south')
                hold off
                tfr_counter = tfr_counter + sub_cols;
                close(tfr_fig);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Var plot
            % Position: 2nd row, last column
            scrollsubplot(sub_rows, sub_cols, (tfr_counter - 1));
            bar(component_var, 'EdgeColor', 'none');
            % xlabel('PC #', 'FontSize', font_size);
            ylabel('% Variance', 'FontSize', font_size);
            title('Percent Variance Explained', 'FontSize', font_size)
            %% Plot cumulative sum over % variance barplot
            % hold on
            % yyaxis right
            % plot(cumsum(component_var));
            % hold off
            %% Plot cumulative sum above variance plot
            scrollsubplot(sub_rows, sub_cols, sub_cols);
            ylabel('Cumsum % Var', 'FontSize', font_size)
            yyaxis right
            plot(cumsum(component_var));
            % title('Cumulative Sum', 'FontSize', font_size)
            set(gca,'XAxisLocation','top');
            xlabel('PC #', 'FontSize', font_size);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            weight_counter = tfr_counter + 1;
            %% Get event response and separate into units
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event));
            event_matrix = get_event_response(psth_struct.(region).relative_response, event_indices);
            event_psth = calc_psth(event_matrix);
            unit_struct = slice_unit_response(event_matrix, psth_struct.(region).label_order, tot_window_bins);

            %% Set event min and max for plotting
            event_max = 1.1 * max(event_psth) + eps;
            if min(event_psth) >= 0
                event_min = 0;
            else
                event_min = 1.1 * min(event_psth);
            end

            %% Creating the PSTH graphs
            for chan_i = 1:tot_reg_chans
                psth_name = chan_order{chan_i};
                psth = unit_struct.(psth_name).psth;
                relative_response = unit_struct.(psth_name).relative_response;
                if strcmpi(st_type, 'std')
                    st_vec = std(relative_response);
                elseif strcmpi(st_type, 'ste')
                    [~, tot_obs] = size(relative_response);
                    st_vec = std(relative_response) ./ sqrt(tot_obs);
                end
                figure(main_plot);
                scrollsubplot(sub_rows, sub_cols, tfr_counter);
                hold on
                [l, ~] = boundedline(event_window, psth, st_vec, ...
                    'transparency', transparency);
                legend_lines = l;
                %TODO do more manipulation of shading
                ylim([event_min event_max]);
                line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                ylabel('PC Space', 'FontSize', font_size);

                if plot_avg_pow
                    yyaxis right
                    [tfr, st_tfr] = calc_tfr(mnts_struct.(region).mnts, event_indices, st_type, tot_window_bins);
                    [l, ~] = boundedline(event_window, tfr, st_tfr, 'transparency', transparency);
                    legend_lines = [legend_lines, l];
                    lg = legend(legend_lines, ["pc", "avg power"]);
                    legend('boxoff');
                    lg.Location = 'Best';
                    lg.Orientation = 'Horizontal';
                    ylabel('Avg. Pow', 'FontSize', font_size);
                end
                title(strrep(psth_name, '_', ' '), 'FontSize', font_size);
                xlabel('Time (s)', 'FontSize', font_size);
                xlim([round(window_start) round(window_end)]);
                hold off
                tfr_counter = tfr_counter + sub_cols;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Plot PCA weights
            plot_incrememnt = sub_cols;
            pca_weights = component_results.(region).coeff;
            [~, tot_chans] = size(pca_weights);
            if strcmpi(feature_filter, 'pcs') && feature_value < tot_chans
                %% Grabs desired number of principal components weights
                pca_weights = pca_weights(:, 1:feature_value);
            end
            tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
                sub_rows, sub_cols, weight_counter, plot_incrememnt, font_size);

            plot_power_shifts(band_shifts.(region), plot_shift_labels, ...
                weight_counter, plot_incrememnt, tot_plots, sub_rows, sub_cols, font_size);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(main_plot);
            try
                filename = [region, '_', event, '.png'];
                saveas(gcf, fullfile(save_path, filename));
            end
            filename = [region, '_', event, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end

function [tfr_filename] = get_tfr_filename(tfr_file_list, sub_reg, event)
    tfr_i = contains({tfr_file_list.name}, sub_reg) ...
        & contains({tfr_file_list.name}, event);
    tfr_filename = tfr_file_list(tfr_i).name;
end

function [tfr, st_tfr] = calc_tfr(mnts, event_indices, st_type, tot_bins)
    [tot_obs, tot_chans] = size(mnts);
    tot_trials = tot_obs / tot_bins;
    rr = mnts_to_psth(mnts, tot_trials, tot_chans, tot_bins);
    rr = rr(event_indices, :);
    stacked_rr = [];
    s = 1;
    e = tot_bins;
    for i = 1:tot_chans
        stacked_rr = [stacked_rr; rr(:, s:e)];
        s = s + tot_bins;
        e = e + tot_bins;
    end
    tfr = calc_psth(stacked_rr);
    st_tfr = std(stacked_rr, 0, 1);
    if strcmpi(st_type, 'ste')
        st_tfr = st_tfr ./ sqrt(tot_trials);
    end
end