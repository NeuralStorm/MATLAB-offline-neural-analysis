function sigs = filter(obj,spikes)
%FILTER Apply the Wiener filter to the input data
%   Detailed explanation goes here

% Parse spikes and match unit names to coefficients
[spikes,~] = NeuroToolbox.parse_spike_ref(spikes,0,'match_units',obj.spikes);

% Find first and last spike times
maxT = max(cellfun(@max,spikes(:,2)));
minT = min(cellfun(@min,spikes(:,2)));

% Create MNTS
[PEM,bin_edges,~,unit_key,~,~] = NeuroToolbox.PSTHToolbox.PSTH.make_PEM(spikes,...
    {'dummy',0},'bin_size',obj.bin_size,'PEM_window',...
    [minT maxT],'ignore',obj.ignore);
MNTS = NeuroToolbox.PSTHToolbox.PSTH.PEM_to_MNTS(PEM,unit_key);

% Initialize data vector
num_lags = obj.FIR_window(end)-obj.FIR_window(1) + 1;
X = zeros(size(MNTS,1),1+num_lags*size(MNTS,2));

% Insert lags
for i = 1:num_lags
    lag = obj.FIR_window(1) + i-1;
    
    % Shift the data and remove looped values (replace with
    % boundary values)
    %(i.e. lagging [3 4 5 6 7] by 2 produces [3 3 3 4 5]
    % instead of [6 7 3 4 5])
    lagged_MNTS = circshift(MNTS,lag,1);
    if lag>0
        lagged_MNTS(1:lag,:) = repmat(lagged_MNTS(lag+1,:),abs(lag)-1,1);
    elseif lag<0
        lagged_MNTS(end+lag:end,:) = repmat(lagged_MNTS(end+lag-1,:),abs(lag)+1,1);
    end
    
    % Insert into appropriate columns
    X(:,1+i:num_lags:end) = lagged_MNTS;
end

% Prepend ones to account for y-intercept
X(:,1) = ones(size(X(:,1)));

% Apply filter coefficients
% Y = X*A
Y=X*obj.coefficients;

% Return a timeseries object
sigs = timeseries(Y,bin_edges(1:end-1));

end