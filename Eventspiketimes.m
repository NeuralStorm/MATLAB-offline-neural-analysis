 function [ relspikes ] = Eventspiketimes( event, newspikes, edge )
%Eventspiketimes-
%   event-list of timestamps for one event type
%   newspikes- rows are units(neurons) x columns are timestamps
%   Converts the spikes into binned spike times in which each set of 100 columns
%   is 1 neuron, and each row is a trial.
dimensions=size(newspikes);
edges = edge;
edge(1)=(edge(1)-0.0005);
edge(length(edge))=edge(length(edge))+0.0005;
for i=1:dimensions(1) %32 neurons-
    for j=1:length(event) %100 trials (*one had 99, but will fix in future)
        neuronbins=zeros(1,length(edge)-1);
        begin = event(j)-edges(1);
        endin = event(j)+edges(end);
        neuron=[]; %This is the neuron response to a single event
        for k=1:dimensions(2)% 113295 max number of spikes per neuron
            if newspikes(i,k)>= begin &&newspikes(i,k)<=endin
                neuron=[neuron,(newspikes(i,k)-event(j))]; %Normalize the spikes times around event times (-200 ms to 200 ms) per event per neuron
            end
        end
        bins = discretize(neuron,edge);
        if length(bins)>0
            for L=1:length(bins)
                neuronbins(1,bins(L))=1;
            end
        end
        dims = size(neuronbins);
        relspikes(j,((1:dims(2))+((i-1)*length(neuronbins))))=[neuronbins(1,1:dims(2))];
    end
end

