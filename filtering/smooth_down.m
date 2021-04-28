function [smoothed_data] = smooth_down(data, span, step_size, avg_type)
    %TODO assert dimension check
    assert(step_size < numel(data), 'Step size should be smaller than data');
    % if mod(numel(data), step_size) ~= 0
    %     warning('Since step size does not evenly go into data, the remainder not be used')
    % end
    downsampled_size = floor(numel(data) / step_size);
    smoothed_data = nan(1, downsampled_size);
    if strcmpi(avg_type, 'lagging')
        smooth_i = 1;
        for i = step_size:step_size:(numel(data) + 1)
            if i < span
                start_i = 1;
                end_i = i;
            else
                start_i = i - span + 1;
                end_i = i;
            end
            smoothed_data(smooth_i) = mean(data(start_i:end_i));
            smooth_i = smooth_i + 1;
        end
    elseif strcmpi(avg_type, 'leading')
        smooth_i = 1;
        stop_index = downsampled_size * step_size;
        for i = 1:step_size:stop_index
            if i > (numel(data) - span)
                start_i = i;
                end_i = stop_index;
            else
                start_i = i;
                end_i = i + span - 1;
            end
            smoothed_data(smooth_i) = mean(data(start_i:end_i));
            smooth_i = smooth_i + 1;
        end
    elseif strcmpi(avg_type, 'center')
        error([avg_type, ' algorithm not implemented yet']);
    else
        error([avg_type, ' not valid flag. Try lagging, leading, or center instead']);
    end
end