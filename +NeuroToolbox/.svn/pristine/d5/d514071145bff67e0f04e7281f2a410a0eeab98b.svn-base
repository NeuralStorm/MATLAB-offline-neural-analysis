function [Weighted_PEM] = apply_weights(W,PEM)
%APPLY_WEIGHTS Summary of this function goes here
%   Detailed explanation goes here

% Compute number of bins
num_bins = size(PEM,2)/size(W,2);

% Interleave the ICA weights so they can be multiplied with the PEM
W = W';
W_new = zeros(num_bins*size(W));
for i = 1:num_bins
W_new(i:num_bins:end,i:num_bins:end)=W;
end
W = W_new;

% Apply the weights to the PEM
Weighted_PEM = PEM*W;
end