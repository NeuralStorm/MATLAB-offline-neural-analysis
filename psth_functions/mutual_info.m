function [prob_struct, mi_results] = mutual_info(response_window, labeled_data)

    all_events = response_window.all_events;
    event_strings = all_events(:,1)';
    total_trials = 0;
    for event = 1:length(event_strings)
        total_trials = total_trials + length(all_events{event, end});
    end

    mi_results = struct;
    prob_struct = struct;
    unique_regions = fieldnames(labeled_data);
    for region = 1:length(unique_regions)
        current_region = unique_regions{region};
        neuron_names = unique(labeled_data.(current_region)(:, 1));


        % Pre-allocate fields
        for unit = 1:length(neuron_names)
            current_unit = neuron_names{unit};
            prob_struct.(current_region).(current_unit).unique_bins = [];
            prob_struct.(current_region).(current_unit).unique_timing = [];
        end

        %% Iterate through event keys
        joint_unique_bin_combos = [];
        for event = 1:length(event_strings)
            current_event = event_strings{event};

            event_prob = length(all_events{event, end}) / total_trials;
            event_bin_counts = [];
            %% Iterate through channel keys
            for unit = 1:length(neuron_names)
                current_unit = neuron_names{unit};
                event_relative_response = response_window.(current_region).(current_event).(current_unit).relative_response;

                %% Count probability
                bin_counts = sum(event_relative_response, 2);
                event_bin_counts = [event_bin_counts, bin_counts];
                unique_bin_counts = unique(bin_counts);
                % Count occurences
                current_prob_count = tabulate(bin_counts);
                current_prob_count = current_prob_count(:, end) / 100;
                current_prob_count(current_prob_count == 0) = [];

                %% Count entropy
                count_entropy = 0;
                for prob_count_index = 1:length(current_prob_count)
                    current_prob = current_prob_count(prob_count_index);
                    count_entropy = count_entropy - current_prob * log2(current_prob);
                end

                %% Timing probability
                [unique_timings, ~, unique_timing_indices] = unique(event_relative_response, 'rows');
                current_prob_timing = tabulate(unique_timing_indices);
                current_prob_timing = current_prob_timing(:, end) / 100;
                current_prob_timing(current_prob_timing == 0) = [];

                %% Timing entropy
                timing_entropy = 0;
                for prob_timing_index = 1:length(current_prob_timing)
                    current_prob = current_prob_timing(prob_timing_index);
                    timing_entropy = timing_entropy - current_prob * log2(current_prob);
                end

                %% Stores variables for later use
                prob_struct.(current_region).([current_event, '_prob']) = event_prob;
                prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_count']) = ...
                    [unique_bin_counts, current_prob_count];
                prob_struct.(current_region).([current_unit, '_', current_event, '_probability_timing']) = ...
                    current_prob_timing;
                prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_timing']) = ...
                    [unique_timings, current_prob_timing];
                prob_struct.(current_region).(current_unit).unique_bins = ...
                    unique([prob_struct.(current_region).(current_unit).unique_bins; unique_bin_counts]);
                prob_struct.(current_region).(current_unit).unique_timing = ...
                    unique([prob_struct.(current_region).(current_unit).unique_timing; unique_timings], 'rows');

                %% Saves results
                mi_results.(current_region).(current_unit).([current_event, '_count_entropy']) = count_entropy;
                mi_results.(current_region).(current_unit).([current_event, '_timing_entropy']) = timing_entropy;
            end
            %% Joint count probability
            [unique_bin_combos, ~, unique_bin_combos_indices] = unique(event_bin_counts, 'rows');
            event_prob_count = tabulate(unique_bin_combos_indices);
            event_prob_count = event_prob_count(:, end) / 100;
            event_prob_count(event_prob_count == 0) = [];
            prob_struct.(current_region).([current_event, '_overall_probability_count']) = ...
                [unique_bin_combos, event_prob_count];
            joint_unique_bin_combos = unique([joint_unique_bin_combos; unique_bin_combos], 'rows');
        end

        combined_bin_mutual_info = 0;
        for unit = 1:length(neuron_names)
            current_unit = neuron_names{unit};
            prob_count_response = zeros(length(prob_struct.(current_region).(current_unit).unique_bins), 1);
            prob_timing_response = zeros(length(prob_struct.(current_region).(current_unit).unique_timing), 1);
            
            %% Calculate probability of bin and timing for each unit
            for event = 1:length(event_strings)
                current_event = event_strings{event};
                %% Probability Count mutual information
                current_prob_count = ...
                    prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_count']);
                %% This finds the indices of the probabilities for the unique bin combinations calculated above
                [~, unique_bin_indices, prob_count_indices] = ...
                    intersect(prob_struct.(current_region).(current_unit).unique_bins, current_prob_count(:,1));
                prob_count_response(unique_bin_indices) = prob_count_response(unique_bin_indices) + ...
                    prob_struct.(current_region).([current_event, '_prob']) * current_prob_count(prob_count_indices, end);
                
                %% Probability Timing mutual information
                current_prob_timing = ...
                    prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_timing']);
                [~, unique_timing_indices, prob_timing_indices] = ...
                    intersect(prob_struct.(current_region).(current_unit).unique_timing, ...
                    current_prob_timing(:,1:end-1), 'rows');
                prob_timing_response(unique_timing_indices) = prob_timing_response(unique_timing_indices) + ...
                    prob_struct.(current_region).([current_event, '_prob']) * current_prob_timing(prob_timing_indices, end);
            end
            
            count_mutual_info = 0;
            timing_mutual_info = 0;
            for event = 1:length(event_strings)
                current_event = event_strings{event};
                %% count mutual information
                current_prob_count = ...
                    prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_count']);
                [~, prob_count_indices, current_prob_count_indices] = ...
                    intersect(prob_struct.(current_region).(current_unit).unique_bins, current_prob_count(:,1));
                count_mutual_info = count_mutual_info + prob_struct.(current_region).([current_event, '_prob']) * ...
                    sum(current_prob_count(current_prob_count_indices, end) .* ...
                    log2(current_prob_count(current_prob_count_indices, end) ./ prob_count_response(prob_count_indices)));

                %% timing mutual information
                current_prob_timing = ...
                    prob_struct.(current_region).([current_unit, '_', current_event, '_overall_probability_timing']);
                [~, prob_timing_indices, current_prob_timing_indices] = ...
                    intersect(prob_struct.(current_region).(current_unit).unique_timing, ...
                    current_prob_timing(:,1:end-1), 'rows');
                timing_mutual_info = timing_mutual_info + prob_struct.(current_region).([current_event, '_prob']) * ...
                    sum(current_prob_timing(current_prob_timing_indices, end) .* ...
                    log2(current_prob_timing(current_prob_timing_indices, end) ./ ...
                    prob_timing_response(prob_timing_indices)));
            end
            combined_bin_mutual_info = combined_bin_mutual_info + count_mutual_info;

            %% Stores count and timing probabilities for joint probability calculation
            prob_struct.(current_region).([current_unit, '_prob_count_response']) = prob_count_response;
            prob_struct.(current_region).([current_unit, '_prob_timing_response']) = prob_timing_response;

            %% Saves the mutual info results
            mi_results.(current_region).(current_unit).count_mutual_info = count_mutual_info;
            mi_results.(current_region).(current_unit).timing_mutual_info = timing_mutual_info;
        end

        joint_probability = zeros(length(joint_unique_bin_combos), 1);
        for event = 1:length(event_strings)
            current_event = event_strings{event};
            %% Joint probability
            current_prob_combos = prob_struct.(current_region).([current_event, '_overall_probability_count']);
            [~, unique_bin_combos, combo_prob_indices] = intersect(joint_unique_bin_combos, ...
                current_prob_combos(:,1:end-1), 'rows');
            joint_probability(unique_bin_combos) = joint_probability(unique_bin_combos) + ...
                prob_struct.(current_region).([current_event, '_prob']) * current_prob_combos(combo_prob_indices, end);
        end

        joint_mutual_info = 0;
        for event = 1:length(event_strings)
            current_event = event_strings{event};
            %% Joint mutual information
            current_prob_combos = prob_struct.(current_region).([current_event, '_overall_probability_count']);
            [~, unique_bin_combos, combo_prob_indices] = intersect(joint_unique_bin_combos, ...
                current_prob_combos(:,1:end-1), 'rows');
            joint_mutual_info = joint_mutual_info + prob_struct.(current_region).([current_event, '_prob']) * ...
                sum(current_prob_combos(combo_prob_indices, end) .* ...
                log2(current_prob_combos(combo_prob_indices, end) ./ joint_probability(unique_bin_combos)));
        end

        mi_results.(current_region).joint_mutual_info = joint_mutual_info;

        %% Synergy redundancy
        synergy_redundancy = joint_mutual_info - combined_bin_mutual_info;
        mi_results.(current_region).synergy_redundancy = synergy_redundancy;
    end
end