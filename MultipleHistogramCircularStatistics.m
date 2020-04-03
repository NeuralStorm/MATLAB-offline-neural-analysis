function [r, theta, s, z, p] = MultipleHistogramCircularStatistics(Histograms,num_bins)
%Circular Statistics (Drew & Doucet, 1991) on an Tx(N*B) 
%       matrix where each row is an array of N Histograms with B (num_bins) Bins each
%   Required input: 
%       Histograms: a Tx(N*B) matrix where every B (num_bins) bins of each 
%           row represents a different Histogram
%   Interpolates bins into polar coordinates with
%       the front of bin 1 being zero degrees and
%       the back of bin B being 360 degrees
%   Output:
%       r: a TxN matrix of r values that represent the magnitude of the vector representing the polar average of
%           the bins for each Histogram
%       theta: a TxN matrix of theta values that represent the direction of the vector representing the polar average
%           of the bins between 0 and 360 degrees of each Histogram
%       s: a TxN matrix of angular deviations
%       z: a TxN matrix of z-scores
%       p: a TxN matrix of the probably that the histogram is unmodulated


    for row=1:size(Histograms,1)
        histogram_number=0; % number of the Histogram currently being analized
        for starting_bin=1:num_bins:size(Histograms,2) % Loop through the Histograms
            bins=Histograms(row,starting_bin:starting_bin+num_bins-1); %Pull out the bins for the current Histogram
            histogram_number=histogram_number+1; % Update for the new histogram number

            theta_i = pi/num_bins:2*pi/num_bins:2*pi; % angle assigments for the center of the bins, interpolated between 0 and 2pi

            n_sum = sum(bins); % sum of the values in the bins

            X_i = bins.*cos(theta_i); % Calculate the x-coordinates of vectors representing each bin in polar space
            Y_i = bins.*sin(theta_i); % Calculate the y-coordinates of vectors representing each bin in polar space

            X = sum(X_i)/n_sum; % Calculate the x-coordinate of the vector representing the polar average of the bins
            Y = sum(Y_i)/n_sum; % Calculate the y-coordinate of the vector representing the polar average of the bins

            r(row,histogram_number) = (X^2+Y^2)^.5; % Calculate the magnitude of the vector representing the polar average

            theta(row,histogram_number) = atan2(Y,X)/pi*180; % Calculate the direction of the vector represeting the polar average
            if theta(row,histogram_number) < 0
                theta(row,histogram_number) = theta(row,histogram_number)+360; % Add 360 degrees if theta is negative so output is between 0 and 360
            end
            Z=r(row,histogram_number)^2*n_sum; % Calculate the z-score of r for the Rayleigh’s test
            z(row,histogram_number)=Z;
            s(row,histogram_number)=(-2*log(r(row,histogram_number)))^.5; % calculate the angular deviation
            %calcualte the probably that the histogram is unmodulated
            p(row,histogram_number) = exp(-Z) * (1 + (2*Z - Z^2) / (4*num_bins) - (24*Z - 132*Z^2 + 76*Z^3 - 9*Z^4) / (288*num_bins^2));
        end
    end
end
