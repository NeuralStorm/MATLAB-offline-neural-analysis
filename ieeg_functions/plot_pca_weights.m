function [] = plot_pca_weights(save_path, component_results, label_log, feature_filter, ...
        feature_value, ymax_scale, sub_rows, sub_cols, session_num)
    %TODO rename to plot_power_features()

    %% Purpose: Create subplot of electrode weights across components
    %% Input
    % save_path: path where subplots are saved
    % component_results: struct w/ fields for each feature set ran through PCA
    %                    'all_events': Nx2 cell array where N is the number of events
    %                                  Column 1: event label (ex: event_1)
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                         Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each feature
    %                                  weighted_mnts: mnts mapped into pc space with feature filter applied
    %                                  tfr: struct with fields for each power
    %                                       (Note: This was added in the batch_power_pca function and not in the calc_pca call)
    %                                       bandname: struct with fields for each event type
    %                                                 event: struct with fields with tfr & z tfr avg, std, ste
    %                                                        fieldnames: avg_tfr, avg_z_tfr, std_tfr, std_z_tfr, ste_tfr, & ste_z_tfr
    % label_log: struct w/ fields for each feature set
    %            field: table with columns
    %                   'sig_channels': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'label': String: associated region or grouping of electrodes
    %                   'label_id': Int: unique id used for labels
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel
    % feature_filter: String with description for pcs
    %                 'all': keep all pcs after PCA
    %                 'pcs': Keep # of pcs set in feature_value
    %                 'percent_var': Use X# of PCs that meet set % in feature_value
    % feature_value: Int matched to feature_filter
    %                'all': left empty
    %                'pcs': Int for # of pcs to keep
    %                'percent_var': % of variance desired to be explained by pcs
    % ymax_scale: Float: how much to scale y max to give room for words
    % sub_rows: Int: desired rows to be shown on subplot
    % sub_cols: Int: desired cols to be shown on subplot
    % session_num: Int with session num for file
    %% Output: There is no return. The graphs are saved directly to the path indicated by save_path

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
    plot_start = 2;
    plot_increment = 1;

    unique_features = fieldnames(component_results);
    unique_features = unique_features(~ismember(unique_features, 'all_events'));

    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};

        %% Establish rows & cols for scrollsubplot, create figure, and title
        pca_weights = component_results.(feature).coeff;
        [~, tot_components] = size(pca_weights);
        if strcmpi(feature_filter, 'pcs') && feature_value < tot_components
            %% Grabs desired number of principal components weights
            tot_components = feature_value;
        end
        %% Determine if there are too many rows/cols and reduces to make subplot bigger
        if (sub_cols * sub_rows) > tot_components
            plot_cols = round(tot_components / 2) + 1;
            plot_rows = tot_components - plot_cols;
            if plot_rows < 1
                plot_rows = 1;
            end
        else
            plot_rows = sub_rows;
            plot_cols = (sub_cols + 1);
        end
        %% Create figure
        figure('visible', 'off')
        title_txt = strrep(feature, '_', ' ');
        sgtitle(title_txt);

        %% Plot PC variance
        scrollsubplot(plot_rows, plot_cols, 1);
        bar(component_results.(feature).component_variance, ...
            'EdgeColor', 'none');
        xlabel('PC #');
        ylabel('% Variance');
        title('Percent Variance Explained')

        %% Find powers feature
        sub_features = strsplit(feature, '_');
        band_locs = ~ismember(sub_features, label_log.(feature).label);
        band_list = sub_features(band_locs);

        %% Create color struct for each unique region in feature
        [color_struct, ~] = create_color_struct(color_map, ...
            feature, label_log.(feature));

        %% Plot out weights for each pc
        tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
            plot_rows, plot_cols, plot_start, plot_increment);

        %% Add vertical lines denoting shift in power
        plot_power_shifts(label_log.(feature), sub_features, band_list, ...
            band_locs, tot_plots, plot_start, plot_increment, ...
            plot_rows, plot_cols);

        %% save subplot
        filename = ['test_', num2str(session_num), '_', feature, '.fig'];
        set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
        savefig(gcf, fullfile(save_path, filename));
        close all
    end
end