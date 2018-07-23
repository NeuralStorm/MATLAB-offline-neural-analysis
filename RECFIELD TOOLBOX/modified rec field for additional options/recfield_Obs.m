function ParamData = recfield_Obs(PEHM,options)

% Binsize, PEHM
% clear all ;
ParamData=[];
Binsize = options.bin ;

% for each neuron
for j = 1:size(PEHM,2)
% for j = 5
    % for each event
    for i = options.CurrentEvents

        [PeriEventMatrixSmoothed]=smoothperieventmatrix((PEHM(:,:,i))');
%         %%temp
        PeriEventMatrixSmoothed = PeriEventMatrixSmoothed' ;
%         CurrMatrix = PeriEventMatrixSmoothed((options.pretime/options.bin)+1:end,j);
                
        BackgroundSmoothed = smoothperieventmatrix((PEHM(:,:,15))');%%15 for control steps, 11 fpr steps 3/1
        BackgroundSmoothed = BackgroundSmoothed';
        PEHMBackground = BackgroundSmoothed(:,j);
        
        CurrMatrix = PeriEventMatrixSmoothed(:,j);
        OrigMatrix = PEHM(:,j,i);
        
        
        
        
        
        % to calculate the background average, we use the pre window of
        % to find the threshold.
%         PEHMBackground = PEHM(:,j,15);%i,8? so all background is from before all start?
%         CurrMatrix = PEHM(:,j,i) ;

%         % to be removed 
%             PEHMBackground = cat(1,PEHMBackground,CurrMatrix) ;
        BackgroundAvg=mean(PEHMBackground);
        BackgroundSTD=std(PEHMBackground);
        % define threshold based off of 99 % confidence interval
        NSTD =2.58;%5;%2.58; % Anitha used 2.58 for 99% confidence, 3 for Foffani's Paper, higher for more stringent
        Threshold=BackgroundAvg+NSTD*BackgroundSTD;%/(sqrt(length(PEHMBackground)));%%%ADJUSTED 03/30/12
%         Threshold = BackgroundAvg + NSTD*BackgroundSTD ;
        % To find the response, look at the response window 
%         CurrMatrix = PEHM(:,j,i) ;
     


        PeakResponse = max(CurrMatrix);
        PeakResponseIndex = max(find(CurrMatrix==PeakResponse));
        
        % find the limits of the response
        % lower limit
% %         if PeakResponseIndex<2  %%original
        if PeakResponseIndex<3  %%temporary - jaimie 2/28/12
            k = PeakResponseIndex ;
        else
            for k= 1:(PeakResponseIndex-1)  %%changed from (PeakResponseIndex-1) jaimie 22812
                if CurrMatrix(PeakResponseIndex-k)>= Threshold
                    % continue
                elseif CurrMatrix(PeakResponseIndex-k)< Threshold
                    break  %original
                    
%                     %%jaimie additions
%                     if CurrMatrix(PeakResponseIndex-k-1)>= Threshold %
%                     elseif CurrMatrix(PeakResponseIndex-k-1)< Threshold%
%                         break ;  %
%                     end %%end to jaimie additions pre
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
                    %continue  %%original
                elseif CurrMatrix(m)<Threshold  %%original
                    break ;  %%original
                end %%original
                
%                                     %%jaimie additions
%                     if CurrMatrix(m+1)>= Threshold %
%                     elseif CurrMatrix(m+1)< Threshold%
%                         break ;  %
%                     end
%                 end%%end to jaimie additions pre
                            
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
        FBL = (Index1*Binsize) ;  % in seconds from event
        LBL = (Index2*Binsize) ; % in seconds from event
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
        
%         Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD i j] ;  %original
               Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD RM_BSub ResponseDurationSecs i j] ;
        
        end
    
    toel= find(Parameters(:,1)==0);
    Parameters(toel,:)=[];
    PRF = find(Parameters(:,1)==max(Parameters(:,1)), 1, 'last' );
    NRM=Parameters(:,1)/Parameters(PRF,1);
    [NRM,b]=sort(NRM,'descend');
    Parameters = [NRM,Parameters(b,:),b,repmat(length(b),length(b),1)];
    ParamData=[ParamData;Parameters];
    clear Parameters
    end%%added with ifempty near UpThreshold, might5 want to remove - JD 08262011
   
    
end
% 
% %%temp
R=2wa;