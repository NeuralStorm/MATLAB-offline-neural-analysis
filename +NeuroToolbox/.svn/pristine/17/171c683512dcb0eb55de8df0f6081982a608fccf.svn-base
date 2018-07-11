function out = smooth(matrix,samples,dim)
%SMOOTH smooth a matrix along dimension dim
%   Detailed explanation goes here

% Add error checking here, default samples to 5

% Design the discrete filter transfer function coefficients... B is
% numerator, A is denominator.
B = ones(samples,1)/samples;
A = 1;

% filtfilt() operates along first non-singleton dimension, so swap dimensions,
% filter, then swap back.
order = 1:numel(size(matrix));
order(order==dim) = 1; % Move dimension dim to dimension 1
order(1) = dim; % and move dimension 1 to dimension dim
matrix = permute(matrix,order);
matrix = filtfilt(B,A,matrix);
out = permute(matrix,order); % Move the dimensions back to where they started

end

