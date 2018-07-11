function out = demean(matrix,dim)
%DEMEAN Subtract the mean of a matrix along a specified dimension
%   Detailed explanation goes here

% Compute means along dim
matMean = mean(matrix,dim);

% Find size for repmat
repSize = size(matrix)-size(matMean);
repSize = repSize + ones(size(repSize));

% Tile mean vector
matMean = repmat(matMean,repSize);

% Subtract means
out = matrix-matMean;

end

