 function [ relspikes ] = Eventspiketimes(event, spikes, total_bins, pre_time, post_time)
%Eventspiketimes-
%   event-list of timestamps for one event type
%   spikes- rows are units(neurons) x columns are timestamps
%   Converts the spikes into binned spike times in which each set of 100 columns
%   is 1 neuron, and each row is a trial.
dimensions=size(spikes);

for i = 1:dimensions(1) %32 neurons-
    for j = 1:length(event)
        neuronbins = zeros(1, total_bins);
        begin = event(j) - abs(pre_time);
        endin = event(j) + abs(post_time);
        neuron = []; %This is the neuron response to a single event
        for k = 1:dimensions(2) % 113295 max number of spikes per neuron
            if spikes(i,k) >= begin && spikes(i,k) <= endin
                neuron = [neuron,(spikes(i,k) - event(j))]; %Normalize the spikes times around event times (-200 ms to 200 ms) per event per neuron
            end
        end
        bins = discretize(neuron, total_bins, 'IncludedEdge','right');
        if length(bins) > 0
            for L = 1:length(bins)
                neuronbins(1, bins(L)) = 1;
            end
        end
        dims = size(neuronbins);
        relspikes(j, ((1:dims(2)) + ((i-1) * length(neuronbins)))) = ...
            [neuronbins(1, 1:dims(2))];
    end
end

