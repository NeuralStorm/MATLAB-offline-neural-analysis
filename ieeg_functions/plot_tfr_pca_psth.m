function [] = plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, component_results, ...
    label_log, psth_struct, pc_log, ymax_scale)

    freq_list = {'highfreq', 'lowfreq'};
    unique_powers = fieldnames(label_log);
    for pow_i = 1:length(unique_powers)
        curr_pow = unique_powers{pow_i};
        %% Shade different powers in plot
        if contains(curr_pow, '_')
            multi_powers = true;
            split_powers = strsplit(curr_pow, '_');
        else
            multi_powers = false;
            split_powers = {curr_pow};
        end
        unique_regions = fieldnames(label_log.(curr_pow));
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

            %TODO move out of here so that region tfr plot isnt made n times (where n = # of powers)
            tfr_sub_fig = figure;
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
                    % ax = gca;
                    tfr_ax = get(gca,'Children');
                    xdata = get(tfr_ax, 'XData');
                    ydata = get(tfr_ax, 'YData');
                    zdata = get(tfr_ax, 'CData');
                    figure(tfr_sub_fig);
                    hold on
                    scrollsubplot(2, 1 , tfr_counter);
                    contourf(xdata, ydata, zdata, 40, 'linecolor','none')
                    colorbar
                    hold off
                    tfr_counter = tfr_counter + 1;
                end
            end




            pca_weights = component_results.(curr_pow).(region).coeff;
            y_max = max(max(pca_weights)) + (ymax_scale * max(max(pca_weights)));
            y_min = min(min(pca_weights));
            if max(max(pca_weights)) == y_min
                y_min = -y_min;
            end
        end
    end

end