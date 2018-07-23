function ParamData = recfield_Press(PEHM,options)

% Binsize, PEHM
% clear all ;
ParamData=[];
Binsize = options.bin ;

% for each neuron
for j = 1:size(PEHM,2)
    % for each event
    for i = 1:size(PEHM,3)
        % smooth the peri event matrix
        [PeriEventMatrixSmoothed]=smoothperieventmatrix((PEHM(:,:,i))');
        PeriEventMatrixSmoothed = PeriEventMatrixSmoothed' ;
        switch i 
            case 1
              CurrMatrix = PeriEventMatrixSmoothed(301:end,j);
              OrigMatrix = PEHM(301:end,j,i);
            case 2 
              CurrMatrix = PeriEventMatrixSmoothed(151:450,j);
              OrigMatrix = PEHM(151:450,j,i);  
            case 3 
              CurrMatrix = PeriEventMatrixSmoothed(151:450,j);
              OrigMatrix = PEHM(151:450,j,i);
            case 4 
              CurrMatrix = PeriEventMatrixSmoothed(1:300,j);
              OrigMatrix = PEHM(1:300,j,i);  
        end
        
        % to calculate the background average, we use the pre window of
        % to find the threshold.
        PEHMBackground = PEHM(1:(options.pretime/options.bin),j,1);
        BackgroundAvg=mean(PEHMBackground);
        BackgroundSTD=std(PEHMBackground);
        % define threshold based off of 99 % confidence interval
        Threshold=BackgroundAvg+2.58*BackgroundSTD/(sqrt(length(PEHMBackground)));
% Threshold = BackgroundAvg + 3*BackgroundSTD ;
        
        % define the peak region around the peak response
        PeakResponse = max(CurrMatrix);
        PeakResponseIndex = max(find(CurrMatrix==PeakResponse));
        
        % find the limits of the response
        % lower limit
        if PeakResponseIndex<2
            k = PeakResponseIndex ;
        else
            for k= 1:(PeakResponseIndex-1)
                if CurrMatrix(PeakResponseIndex-k)>= Threshold
                    % continue
                elseif CurrMatrix(PeakResponseIndex-k)< Threshold
                    break ;
                end
                
            end
        end
        %disp(k) ;
        Index1 = PeakResponseIndex-k+1 ;
        % upper limit
        if PeakResponseIndex == length(CurrMatrix)
            m = PeakResponseIndex ;
        else
            for m = (PeakResponseIndex+1):length(CurrMatrix)
                if CurrMatrix(m)>=Threshold
                    %continue
                elseif CurrMatrix(m)<Threshold
                    break ;
                end
            end
        end
        %disp(m) ;
        Index2 = m-1;
        
        
        % Background average
        BfrSpikesPerBin = sum(PEHMBackground)/length(PEHMBackground) ; % spikes/trial/bin
        % Response Duration
        ResponseDurationSecs = (Index2-Index1)*Binsize ; %#ok<NASGU> % in seconds
        % Response Magnitude
        RMSpikes = sum(OrigMatrix(Index1:Index2));  % spikes per trial
        % Response Magnitude Background subtracted
        RM_BSub = RMSpikes - (BfrSpikesPerBin*(Index2-Index1));
        % Peak Response
        PRSpikes =  max(OrigMatrix(Index1:Index2));% in spikes per trial in one bin
        PRIndex = find(OrigMatrix(Index1:Index2)==PRSpikes, 1, 'last' );
        % Latencies
        switch i
            case 1
                offset = 0 ;
            case 2 
                offset = 150 ;
            case 3 
                offset = 150 ;
            case 4 
                offset = 300 ;
        end
        FBL = ((Index1-offset)*Binsize) ;  % in seconds from event
        LBL = ((Index2-offset)*Binsize) ; % in seconds from event
        PL = FBL+ PRIndex*Binsize ; % in seconds from event
        
        
        % if there are less than 3 significant bins ( over 99% CI ) , not a
        % significant response
        
        if isempty(Index1:Index2)
            %disp('empty response');
            BfrSpikesPerBin = 0 ;
            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
            
        elseif length(Index1:Index2)<3
            
            BfrSpikesPerBin = 0 ;
            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
            
        end
        
        Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD i j] ;
    end
%     Parameters(3,:) = [] ;
    toel= find(Parameters(:,1)==0);
    Parameters(toel,:)=[];
    MaxResponse = find(Parameters(:,1)==max(Parameters(:,1)), 1, 'last');
    PRF = Parameters(find(Parameters(:,1)==max(Parameters(:,1)), 1, 'last'),8);
    NRM=Parameters(:,1)/Parameters(MaxResponse,1);
    [NRM,b]=sort(NRM,'descend');
    Parameters = [NRM,Parameters(b,:),repmat(PRF,length(b),1),repmat(length(b),length(b),1)];
    ParamData=[ParamData;Parameters];
    clear Parameters
end

