classdef wiener_filter
    %WIENER_FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
		spikes;
		signal;
        
        FIR_window;
		bin_size;
		ignore;

		spike_counts;
		coefficients;
        
    end
    
    methods
        
        function obj = wiener_filter(spikes,signal,varargin)
            % class constructor method
            
            % Parse spikes
            [spikes,~] = NeuroToolbox.parse_spike_ref(spikes,0);
            
            % Error check signal
            if ~isa(signal,'timeseries');
                % Throw an error
                return;
            end
            
            % Parse arguments
            validOptions = {'FIR_window','bin_size','ignore'};
            validOptionClasses = {'numeric','numeric','cellstr'};
            validOptionAttributes = {{'real','integer','numel',2,'nondecreasing'},{'positive','real','scalar'},{}};
            defaultOptionValues = {[-10,0],0.1,{}};
            [err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
            if err
                id = ['NeuroToolbox:wiener_filter:InvalidOptions',num2str(err)];
                msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.wiener_filter'''];
                exception = MException(id,msg);
                throw(exception);
            end
            
            % Assign property values
            obj.spikes = spikes;
            obj.signal = signal;
            obj.FIR_window = FIR_window;
            obj.bin_size = bin_size;
            obj.ignore = ignore;
            
            % Interpolate NaNs in signal
            obj.signal = obj.signal.resample(obj.signal.Time);
            
            % Trim leading and trailing NaNs
            obj.signal = obj.signal.resample(obj.signal.time(~isnan(sum(obj.signal.Data(:,1),2))));
            
            % Create MNTS
            [PEM,bin_edges,~,unit_key,~,~] = NeuroToolbox.PSTHToolbox.PSTH.make_PEM(obj.spikes,...
                {'dummy',0},'bin_size',obj.bin_size,'PEM_window',...
                [min(obj.signal.Time) max(obj.signal.Time)],'ignore',obj.ignore);
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
            
            % Line up signal samples with PEM
            signal_resamp = obj.signal.resample(bin_edges(1:end-1));
            
            % Compute filter coefficients as the solution to the equation
            % Y = X*A
            Y = signal_resamp.Data;
            A = (X'*X)\(X'*Y);
            
            obj.coefficients = A;
        end
        
        sigs = filter(obj,spikes)
        
    end
    
end

