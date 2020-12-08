function [event_matrix] = get_event_response(response_matrix, event_indices)
    %% Purpose: Return response matrix with only event trials
    %% Input:
    % response_matrix: response matrix with dims trials x (units * total bins)
    % event_indices: boolean or index array indicating trials (rows) desired
    %% Output:
    % event_matrix: same as response_matrix but only has trials from event

    event_matrix = response_matrix(event_indices, :);
end