function [unit_struct] = get_response_units(response_matrix, unit_labels, ...
        tot_window_bins, tot_preresponse_bins, tot_response_bins)

    %% Purpose: Return struct with units sliced by response bins
    %% Input:
    % response_matrix: response matrix with dims trials x (units * total bins)
    % unit_labels: labels with order of units in response matrix
    % tot_window_bins: total bins for a given unit
    % tot_preresponse_bins: total bins from window start to response start - 1
    % tot_response_bins: total bins in response
    %% Output:
    % unit_struct: struct with the following fields
    %              unit: unit is defined by the contents of unit_labels and has the fields
    %                    relative_response: unit response matrix
    %                    psth: avg response

    %% assert unit labels and tot window bins are valid
    [~, tot_cols] = size(response_matrix);
    assert(tot_cols / (numel(unit_labels) * tot_window_bins) == 1, ...
        ['Total unit labels and bins provided do not cleanly go', ...
        'into response matrix. Verify dimensions']);

    unit_struct = struct;
    unit_index = 1;
    for unit_start_i = 1:tot_window_bins:tot_cols
        %% determine unit label
        unit = unit_labels{unit_index};
        unit_index = unit_index + 1;
        %% slice time from response matrix and store in unit_struct
        start_i = unit_start_i + tot_preresponse_bins;
        end_i = unit_start_i + tot_preresponse_bins + tot_response_bins - 1;
        unit_response = response_matrix(:, start_i:end_i);
        unit_struct.(unit).relative_response = unit_response;
        unit_struct.(unit).psth = calc_psth(unit_response);
    end
end