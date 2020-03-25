function [r, theta, z] = MultipleHistogramCircularStatistics(Histograms,N)
%Circular Statistics (Drew & Doucet, 1991) on an 1x(N*M) array of M
%Histograms with N Bins each
%   Required input: a 1x(M*N) array of histogram bins, 
%   every N bins represents a different Histogram
%   Interpolates bins into polar coordinates with
%       the front of bin 1 being zero degrees and
%       the back of bin N being 360 degrees
%   Output:
%       r: An array of r values that represent the magnitude of the vector representing the polar average of
%           the bins for each Histogram
%       theta: an array of theta values that represent the direction of the vector representing the polar average
%           of the bins between 0 and 360 degrees of each Histogram
%       z: an array of z-scores for the r value for use in Rayleigh's test
%           Compare aginst cirtical z-scores in table B.32 from Zar 1981


NumBins = N; % The number of bins in a Histogram
k=0; % k represents the number of the Histogram currently being analized
for j=1:N:length(Histograms) % Loop through the Histograms
    Bins=Histograms(j:j+N-1); %Pull out the bins for the current Histogram
    k=k+1; % Update k for the new histogram number

    theta_i = pi/NumBins:2*pi/NumBins:2*pi; % angle assigments for the center of the bins, interpolated between 0 and 2pi

    n_sum = sum(Bins); % sum of the values in the bins

    X_i = Bins.*cos(theta_i); % Calculate the x-coordinates of vectors representing each bin in polar space
    Y_i = Bins.*sin(theta_i); % Calculate the y-coordinates of vectors representing each bin in polar space

    X = sum(X_i)/n_sum; % Calculate the x-coordinate of the vector representing the polar average of the bins
    Y = sum(Y_i)/n_sum; % Calculate the y-coordinate of the vector representing the polar average of the bins

    r(k) = (X^2+Y^2)^.5; % Calculate the magnitude of the vector representing the polar average

    theta(k) = atan2(Y,X)/pi*180; % Calculate the direction of the vector represeting the polar average
    if theta(k) < 0
        theta(k) = theta(k)+360; % Add 360 degrees if theta is negative so output is between 0 and 360
    end
    z(k)=r(k)^2*n_sum; % Calculate the z-score of r for the Rayleigh’s test
end
end
