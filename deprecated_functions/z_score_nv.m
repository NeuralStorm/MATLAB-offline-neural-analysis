function [z_filename] = z_score_nv(csv_path, pre_time, post_time, bin_size, epsilon, norm_var_scaling)
    %% Get csv table containing nv results
    if exist(csv_path, 'file')
        nv_table = readtable(csv_path);
    else
        error('Please run the nv calculation function first to get the normalized variance for your data set');
    end

    %% Find baseline for each animal and z score data
    unique_animals = unique(nv_table.animal);
    unique_regions = unique(nv_table.region);
    unique_days = unique(nv_table.day);
    z_score_data = [];
    combined_control_z = [];
    for animal = 1:length(unique_animals)
        current_animal = unique_animals{animal};
        animal_group = unique(nv_table.group(strcmpi(nv_table.animal, current_animal)));
        for region = 1:length(unique_regions)
            current_region = unique_regions{region};
            current_region_type = unique(nv_table.region_type(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region)));
            baseline_nv = nv_table.norm_var(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region) & nv_table.day == 0);
            baseline_pop_avg = mean(baseline_nv, 'omitnan');
            baseline_pop_std = std(baseline_nv, 'omitnan');
            baseline_fano = nv_table.fano(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region) & nv_table.day == 0);
            fano_baseline_pop_avg = mean(baseline_fano, 'omitnan');
            fano_baseline_pop_std = std(baseline_fano, 'omitnan');
            for day = 1:length(unique_days)
                current_day = unique_days(day);
                channels = nv_table.channel(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                %% Get nv and fano data for current day
                current_nv_data = nv_table.norm_var(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                current_fano = nv_table.fano(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                unit_z_nv = (current_nv_data - baseline_pop_avg) / baseline_pop_std;
                unit_z_fano = (current_fano - fano_baseline_pop_avg) / fano_baseline_pop_std;
                general_info = [{current_animal}, {animal_group}, {current_day}, ...
                    {pre_time}, {post_time}, {bin_size}, {norm_var_scaling}, {epsilon}, ...
                    {current_region}, {current_region_type}];
                general_info = repmat(general_info, [length(channels(:,1)), 1]);
                z_score_data = [z_score_data; general_info, channels, num2cell(current_nv_data), num2cell(unit_z_nv), num2cell(unit_z_fano)];
            end
        end
    end
    z_score_table = cell2table(z_score_data, 'VariableNames', {'animal', 'group', 'day', ...
        'pre_time', 'post_time', 'bin_size', 'norm_var_constant', 'epsilon', 'region', ...
        'region_type', 'channel', 'unit_nv', 'unit_z_nv', 'unit_z_fano'});
    [z_csv_path, ~, ~] = fileparts(csv_path);
    z_filename = fullfile(z_csv_path, 'pop_z.csv');
    writetable(z_score_table, z_filename, 'Delimiter', ',');
end