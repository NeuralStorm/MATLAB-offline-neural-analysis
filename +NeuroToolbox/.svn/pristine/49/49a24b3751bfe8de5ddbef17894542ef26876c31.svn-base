function out = normalize(matrix,dim)
%NORMALIZE Normalize a matrix to unit variance along dimension dim
%   Detailed explanation goes here

% Compute std along dim
matStd = std(matrix,dim);

% Find size for repmat
repSize = size(matrix)-size(matStd);
repSize = repSize + ones(size(repSize));

% Tile mean vector
matStd = repmat(matStd,repSize);

% Normalize the 
out = matrix./matStd;


end

