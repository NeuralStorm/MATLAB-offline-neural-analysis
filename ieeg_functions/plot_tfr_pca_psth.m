function [] = plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, label_log, ...
    pc_log, component_results, psth_struct, bin_size, window_start, ...
    window_end, baseline_start, baseline_end, response_start, response_end, ...
    feature_filter, feature_value, sub_rows, sub_cols, use_z, st_type, ymax_scale, ...
    transparency, min_components)

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow

    event_window = window_start:bin_size:window_end;
    event_window(1) = [];

    freq_list = {'highfreq', 'lowfreq'};
    tot_tfrs = length(freq_list);

    unique_regions = fieldnames(pc_log);
    parfor feature_i = 1:length(unique_regions)
        feature = unique_regions{feature_i};
        event_type = '';
        st_vec = [];

        [color_struct, region_list] = create_color_struct(color_map, ...
            feature, label_log.(feature));
        event_strings = psth_struct.all_events(:,1)';
        region_neurons = pc_log.(feature).sig_channels;
        total_region_neurons = length(region_neurons);
        for event_i = 1:length(event_strings)
            event = event_strings{event_i};
            if strcmpi(event, 'event_1')
                event_type = 'all';
            elseif strcmpi(event, 'event_2')
                event_type = 'gamble';
            elseif strcmpi(event, 'event_3')
                event_type = 'safebet';
            else
                error('Unexpected event: %s', event);
            end
            %% Skip events without TFRs
            if isempty(tfr_file_list(contains({tfr_file_list.name}, event_type)))
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
            description = [feature, ' ' event_type, 'tot components: ', num2str(tot_components)];
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
                    tfr_i = contains({tfr_file_list.name}, curr_freq) ...
                        & contains({tfr_file_list.name}, sub_reg) ...
                        & contains({tfr_file_list.name}, event_type);
                    tfr_filename = tfr_file_list(tfr_i).name;
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
                    title([curr_freq, ' ', sub_reg, ' ', event_type])
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
            for neuron = 1:total_region_neurons
                psth_name = region_neurons{neuron};
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
                %%TODO plot avg tfr
                %TODO add events to tfr
                %TODO add switch for plotting avg tfr
                yyaxis right
                tfr_struct = component_results.(feature).tfr;
                unique_tfrs = fieldnames(tfr_struct);
                color_i = 1;
                for tfr_i = 1:numel(unique_tfrs)
                    curr_tfr = unique_tfrs{tfr_i};
                    if use_z
                        avg_tfr = tfr_struct.(curr_tfr).avg_z_tfr;
                        st_tfr = tfr_struct.(curr_tfr).([st_type, '_tfr']);
                    else
                        avg_tfr = tfr_struct.(curr_tfr).avg_tfr;
                        st_tfr = tfr_struct.(curr_tfr).([st_type, '_z_tfr']);
                    end
                    [l, ~] = boundedline(event_window, avg_tfr, st_tfr, 'cmap', color_map(color_i, :), ...
                        'transparency', transparency);
                    legend_lines = [legend_lines, l];
                    if color_i < size(color_map, 1)
                        color_i = color_i + 1;
                    else
                        color_i = 1;
                    end
                end
                lg = legend(legend_lines, [{'pc'}; unique_tfrs])
                % lg = legend(unique_tfrs);
                legend('boxoff');
                lg.Location = 'Best';
                lg.Orientation = 'Horizontal';
                title(psth_name);
                xlabel('Time (s)');
                ylabel('Avg. Pow');
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
            % region_table = label_log.(feature);
            tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
                sub_rows, sub_cols, weight_counter, plot_incrememnt);

            sub_features = strsplit(feature, '_');
            band_locs = ~ismember(sub_features, label_log.(feature).label);
            band_list = sub_features(band_locs);
            plot_power_shifts(label_log.(feature), sub_features, band_list, ...
                band_locs, tot_plots, weight_counter, plot_incrememnt, ...
                sub_rows, sub_cols);
            %TODO mark power shift lines
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(main_plot);
            filename = [feature, '_', event_type, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end