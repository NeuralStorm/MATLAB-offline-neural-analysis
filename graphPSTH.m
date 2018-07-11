function [ graph1,graph2,graph3,graph4 ] = graphPSTH( neuronnum,reltotalspikes, edge )
%graphPSTH Graph the PSTH from totalrelspikes of a single neuron for a
%single event(tilt)

%figure will be the graph of PSTH
%stim corresponds to event # example: 1,2,3,4 for events(1,3,4,6)
%neuron corresponds to neuron # example 1- 32
neuronnum=neuronnum;
first = edge(1)
last = edge(end)
xedge=linspace(first,last,6);

for row=1:4
    if row==1
        stim=1;
        length=100;
    elseif row==2
        stim=3;
        length=100;
    elseif row==3
        stim=4;
        length=100;%*** change to 100 for future
    else
        stim=6;
        length=100;
    end
    
    
    if stim==1
        graphme=reltotalspikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
        graph1=graphme;
    elseif stim==3
        graphme=reltotalspikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
        graph2=graphme;
    elseif stim==4
        graphme=reltotalspikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
        graph2=graphme;
    else
        graphme=reltotalspikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
        graph2=graphme;
    end
    f= figure;
    graphme=sum(graphme);
    bar(graphme);
    text=['Histogram of Neuron ',num2str(neuronnum),' for event ',num2str(stim)];
    title(text);
    xlabel('Time(seconds)');
    ylabel('Count');
    xlim([0 401]);
    xticklabels(xedge);
end
end