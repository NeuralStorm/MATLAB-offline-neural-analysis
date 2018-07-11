function [ normcount ] = normcount( count, edge )
%NormCount Normalize the summed spikes by neuron
%   
dim = length(count)/(length(edge)-1);
normcount=[];
for i=1:dim
    avg = count((1:(length(edge)-1))+(i-1)*(length(edge)-1));
    avgmean= mean(avg);
    avgstd = std(avg);
    if avgstd>0
        nomcount = ((avg-avgmean)/avgstd);
    else
        nomcount = zeros(1,(length(edge)-1));
    end
    normcount=[normcount,nomcount];
end



