function [] = plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, component_results, ...
    label_log, pow_struct, pc_log, ymax_scale)

    %TODO move to config
    sub_rows = 5;
    sub_cols = 2;
    st_type = 'std';
    window_start = -3; window_end = 2; bin_size = .05;
    baseline_start = -3; baseline_end = 0;
    response_start = 0; response_end = 2;
    transparency = .3;
    event_window = window_start:bin_size:window_end;

    freq_list = {'highfreq', 'lowfreq'};
    unique_powers = fieldnames(label_log);
    parfor pow_i = 1:length(unique_powers)
        bandname = unique_powers{pow_i};
        %% Shade different powers in plot
        if contains(bandname, '_')
            multi_powers = true;
            split_powers = strsplit(bandname, '_');
        else
            multi_powers = false;
            split_powers = {bandname};
        end

        psth_struct = pow_struct.(bandname)

        %% Add TFRs to subplot
        unique_regions = fieldnames(label_log.(bandname));
        for region_i = 1:length(unique_regions)
            region = unique_regions{region_i};
            if contains(region, '_')
                split_regions = strsplit(region, '_');
                tot_sub_regs = length(split_regions);
                multi_regs = true;
            else
                multi_regs = false;
                split_regions = {region};
                tot_sub_regs = 1;
            end

            main_plot = figure;
            %TODO add more info to title plot
            %% Text plot
            % Position: 1st row, last column
            description = [bandname, ' ', region];
            figure(main_plot);
            ax = scrollsubplot(sub_rows, sub_cols, sub_cols);
            pos=get(ax, 'Position');
            annotation('textbox', pos, 'String', description, ...
                'FitBoxToText','off');

            %% Var plot
            % Position: 2nd row, last column
            scrollsubplot(sub_rows, sub_cols, (sub_cols * 2));
            bar(component_results.(bandname).(region).component_variance, ...
                'EdgeColor', 'none');
            xlabel('PC #');
            ylabel('% Variance');
            title('Percent Variance Explained')

            % Frequency is not an issue since we plot all the frequencies
            tot_pows = length(freq_list);
            tot_tfrs = tot_pows * tot_sub_regs;
            tfr_counter = 1;
            for sub_pow_i = 1:tot_pows
                curr_freq = freq_list{sub_pow_i};
                for sub_reg_i = 1:tot_sub_regs
                    sub_reg = split_regions{sub_reg_i};
                    %% load figure
                    tfr_i = contains({tfr_file_list.name}, curr_freq) ...
                        & contains({tfr_file_list.name}, sub_reg);
                    tfr_filename = tfr_file_list(tfr_i).name;
                    tfr_file = fullfile(tfr_path, tfr_filename);
                    tfr_fig = openfig(tfr_file);
                    tfr_ax = get(gca,'Children');
                    xdata = get(tfr_ax, 'XData');
                    ydata = get(tfr_ax, 'YData');
                    zdata = get(tfr_ax, 'CData');
                    figure(main_plot);
                    hold on
                    scrollsubplot(sub_rows, sub_cols, tfr_counter);
                    contourf(xdata, ydata, zdata, 40, 'linecolor','none')
                    colorbar
                    hold off
                    tfr_counter = tfr_counter + sub_cols;
                    close(tfr_fig);
                end
            end

            %TODO extrapolate to multiple events
            event_strings = psth_struct.all_events(1,1)';
            region_neurons = pc_log.(bandname).(region).sig_channels;
            total_region_neurons = length(region_neurons);
            for event_i = 1:length(event_strings(1,:))
                event = event_strings{event_i};
                if strcmpi(event, 'event_1')
                    event_type = 'all_trials';
                elseif strcmpi(event, 'event_2')
                    event_type = 'gamble';
                elseif strcmpi(event, 'event_3')
                    event_type = 'safebet';
                else
                    error('Unexpected event: %s', event);
                end
                event_psth = psth_struct.(region).(event).psth;

                event_max = 1.1 * max(event_psth) + eps;
                if min(event_psth) >= 0
                    event_min = 0;
                else
                    event_min = 1.1 * min(event_psth);
                end

                %% Creating the PSTH graphs
                for neuron = 1:total_region_neurons
                    psth_name = region_neurons{neuron};
                    psth = psth_struct.(region).(event).(psth_name).psth;
                    if strcmpi(st_type, 'std')
                        relative_response = psth_struct.(region).(event).(psth_name).relative_response;
                        st_vec = std(relative_response);
                    elseif strcmpi(st_type, 'ste')

                    end
                    figure(main_plot);
                    scrollsubplot(sub_rows, sub_cols, tfr_counter);
                    hold on
                    [l,p] = boundedline(event_window, psth, st_vec, ...
                        'transparency', transparency);
                    %TODO do more manipulation of shading
                    ylim([event_min event_max]);
                    line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    title(psth_name);
                    hold off
                    tfr_counter = tfr_counter + sub_cols;
                end
            end


            figure(main_plot);
            filename = [bandname, '_', region, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end

        %% Add text plot

        %% Add variance plot -> Always in position 2,2


        %% Plot PSTHs

        %% Plot PCA weights

    end

end