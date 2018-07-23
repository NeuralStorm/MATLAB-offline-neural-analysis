function ParamData = recfield_TILT(PEHM,options)

% Binsize, PEHM
% clear all ;
ParamData=[];
Binsize = options.bin ;

% for each neuron
for j = 1:size(PEHM,2)
    % for each event
    for i = options.CurrentEvents

        % to calculate the background average, we use the pre window of
        % to find the threshold.
        PEHMBackground = PEHM(1:(options.pretime/options.bin),j,i);
        CurrMatrix = PEHM((options.pretime/options.bin)+(options.response(1)/options.bin):(options.pretime/options.bin)+(options.response(2)/options.bin),j,i) ;

%         % to be removed 
%             PEHMBackground = cat(1,PEHMBackground,CurrMatrix) ;
        BackgroundAvg=mean(PEHMBackground);
        BackgroundSTD=std(PEHMBackground);
        % define threshold based off of 99 % confidence interval
        NSTD = 3 ; % Anitha used 2.58 for 99% confidence, 3 for Foffani's Paper, higher for more stringent
        Threshold=BackgroundAvg+NSTD*BackgroundSTD/(sqrt(length(PEHMBackground)));
        
        % To find the response, look at the response window 
        CurrMatrix = PEHM((options.pretime/options.bin)+(options.response(1)/options.bin):(options.pretime/options.bin)+(options.response(2)/options.bin),j,i) ;
        AboveThreshold = find(CurrMatrix > Threshold);
        Index1 = AboveThreshold(1) ;
        Index2 = AboveThreshold(end) ;
        
         
        % Background average
        BfrSpikesPerBin = sum(PEHMBackground)/length(PEHMBackground) ; % spikes/trial/bin
        % Response Duration
        ResponseDurationSecs = (Index2-Index1)*Binsize ; %#ok<NASGU> % in seconds
        % Response Magnitude
        RMSpikes = sum(CurrMatrix(Index1:Index2));  % spikes per trial
        % Response Magnitude Background subtracted
        RM_BSub = RMSpikes - (BfrSpikesPerBin*(Index2-Index1));
        % Peak Response
        PRSpikes =  max(CurrMatrix(Index1:Index2));% in spikes per trial in one bin
        PRIndex = find(CurrMatrix(Index1:Index2)==PRSpikes, 1, 'last' );
        % Latencies
        FBL = (Index1*Binsize) ;  % in seconds from event
        LBL = (Index2*Binsize) ; % in seconds from event
        PL = FBL+ PRIndex*Binsize ; % in seconds from event
            if BackgroundAvg>0
             [H,SIGNIFICANCE CI] = ttest2(PEHMBackground(Index1:Index2),CurrMatrix(Index1:Index2),0.05,'left');    
            else
                H=1;
            end
%                             
        if H == 0  % means not significantly different

            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
        elseif isnan(H)
            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
        end
            
        % if there are less than 3 significant bins ( over 99% CI ) , not a
        % significant response
        
        if isempty(Index1:Index2)
            %disp('empty response');
%             BfrSpikesPerBin = 0 ;
            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
            
        elseif length(AboveThreshold)<3
            
%             BfrSpikesPerBin = 0 ;
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
    toel= find(Parameters(:,1)==0);
    Parameters(toel,:)=[];
    PRF = find(Parameters(:,1)==max(Parameters(:,1)), 1, 'last' );
    NRM=Parameters(:,1)/Parameters(PRF,1);
    [NRM,b]=sort(NRM,'descend');
    Parameters = [NRM,Parameters(b,:),b,repmat(length(b),length(b),1)];
    ParamData=[ParamData;Parameters];
    clear Parameters
end

