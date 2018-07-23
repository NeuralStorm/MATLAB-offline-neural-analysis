function ParamData = recfield_TILT_CSR(PEHM,options)
%This is the code that Jaimie Dougherty used for her data set (CSR; shared
%with Anitha Manohar)




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
% % % %         PEHMBackground = PEHM(1:(options.pretime/options.bin),j,14);%i,6 for speed testing on 071312; 15 for SLOW 5, 10, 15 tilts.  16 for SPEED tilts; 8? so all background is from before all start?
PEHMBackground = PEHM(1:(options.pretime/options.bin),j,options.backgroundevent);        
%PEHMBackground = PEHM(1:(options.pretime/options.bin),j,options.backgroundevent);  <-- this is what was used originally ,%i,6 for speed testing on 071312; 15 for SLOW 5, 10, 15 tilts.  16 for SPEED tilts; 8? so all background is from before all start?
%         PEHMBackground = PEHM(1:(options.pretime/options.bin),j,i);%options.backgroundevent);%i,6 for speed testing on 071312; 15 for SLOW 5, 10, 15 tilts.  16 for SPEED tilts; 8? so all background is from before all start?
%         PEHMBackgroundT = PEHM(1:(.5/options.bin),j,options.backgroundevent);%%trying to fix some problems
%         PEHMBackground = PEHM(1:(options.posttime/options.bin),j,options.backgroundevent);%i,6 for speed testing on 071312; 15 for SLOW 5, 10, 15 tilts.  16 for SPEED tilts; 8? so all background is from before all start?
        

CurrMatrix = PEHM((options.pretime/options.bin)+(options.response(1)/options.bin):(options.pretime/options.bin)+(options.response(2)/options.bin),j,i);
%;  Jaimie's original above
%   
%Nate added (temporary)
% tempbinseries=-options.pretime:options.bin:options.posttime-options.bin;
% zerobin=find(tempbinseries==0);
% CurrMatrix=PEHM(zerobin:length(tempbinseries),j,i);

% % %         %%%%Jaimie messing with things 11/13/12 %%commented out 73012
% experimenting
% % %         CurrMatrixS=slideAverage(CurrMatrix,5);
% % %         PEHMBackgroundS=slideAverage(PEHMBackground,5);%%trying to fix my troubles   PEHMBackgroundT???
        
        
%%%%Jaimie experimenting 73012
        CurrMatrixS=smooth(CurrMatrix,3);%changed from 3 to 10 on 9/30/13
        PEHMBackgroundS=smooth(PEHMBackground,3);%%trying to fix my troubles   PEHMBackgroundT???
        
        

        
%         % to be removed 
%             PEHMBackground = cat(1,PEHMBackground,CurrMatrix) ;
        BackgroundAvg=mean(PEHMBackground);
        BackgroundSTD=std(PEHMBackground);
    %%again, jaimie screwing wtih stuff 112512
        BackgroundAvgS=mean(PEHMBackgroundS);
        BackgroundSTDS=std(PEHMBackgroundS);

        % define threshold based off of 99 % confidence interval
        NSTD =3;%3; % Anitha used 2.58 for 99% confidence, 3 for Foffani's Paper, higher for more stringent %%usually 3, changed by jaimie 101713 for initial posture data
%         Threshold=BackgroundAvg+NSTD*BackgroundSTD/(sqrt(length(PEHMBackground)));
        

        Threshold = BackgroundAvg + NSTD*BackgroundSTD ;
        ThresholdS = BackgroundAvgS + NSTD*BackgroundSTDS ;%%jaimie 112512
        
        
        
% % %         Threshold=ThresholdS;%%just for figures 061013
% % %         BackgroundAvg=BackgroundAvgS;
% % %         BackgroundSTD=BackgroundSTDS;
% % %         CurrMatrix=CurrMatrixS;
% % %         PEHMBackground=PEHMBackgroundS;
% % %         %end of additions for figures
        
        %%%%%% To find the response, look at the response window 
        %CurrMatrix = PEHM((options.pretime/options.bin)+(options.response(1)/options.bin):(options.pretime/options.bin)+(options.response(2)/options.bin),j,i) ;
        
        %%%changed by jaimie 112512
%         AboveThreshold = find(CurrMatrix > Threshold);
        AboveThreshold = find(CurrMatrixS > ThresholdS);
        
%         %%plot PSTH's TEMP
%         figure;bar(CurrMatrix);%%TEMP


% % % % % %%% anitha's version cenetered around the peak
% % % % %        % define the peak region around the peak response
% % % % %         PeakResponse = max(CurrMatrixS);
% % % % %         PeakResponseIndex = max(find(CurrMatrixS==PeakResponse));
% % % % %         
% % % % %         % find the limits of the response
% % % % %         % lower limit
% % % % %         if PeakResponseIndex<2
% % % % %             k = PeakResponseIndex ;
% % % % %         else
% % % % %             for k= 1:(PeakResponseIndex-1)
% % % % %                 if CurrMatrixS(PeakResponseIndex-k)>= ThresholdS
% % % % %                     % continue
% % % % %                 elseif CurrMatrixS(PeakResponseIndex-k)< ThresholdS
% % % % %                     break ;
% % % % %                 end
% % % % %                 
% % % % %             end
% % % % %         end
% % % % %         %disp(k) ;
% % % % %         Index1 = PeakResponseIndex-k+1 ;
% % % % %         % upper limit
% % % % %         if PeakResponseIndex == length(CurrMatrixS)
% % % % %             m = PeakResponseIndex ;
% % % % %         else
% % % % %             for m = (PeakResponseIndex+1):length(CurrMatrixS)
% % % % %                 if CurrMatrixS(m)>=ThresholdS
% % % % %                     %continue
% % % % %                 elseif CurrMatrixS(m)<ThresholdS
% % % % %                     break ;
% % % % %                 end
% % % % %             end
% % % % %         end
% % % % %         %disp(m) ;
% % % % %         Index2 = m-1;
% % % % %         
% % % % %         
% % % % %         %%%%%%%added in from anitha's stuff
% % % % % 
% % % % %         
% % % % %         AboveThreshold=CurrMatrix(Index1:Index2);
        
        %If no bins above threshold
        if isempty(AboveThreshold)==1 %%acdded by jD 121012 to fix when nothing exceeded threshold - not sure about it yet, may remove later
            BfrSpikesPerBin = sum(PEHMBackground)/length(PEHMBackground) ; %
            ResponseDurationSecs =0 ;
            RMSpikes = 0;%RMSpikes;%%%%0; Changes 081612 by jaimie
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
            Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD RM_BSub ResponseDurationSecs i j] ;
        else %%end of JD addition 08262011 except for final END
        
            Index1 = AboveThreshold(1) ;%%Commented out 021913 by jaimie to add only cpnsecutive bins.
        Index2 = AboveThreshold(end) ;
        
         
        %%%addition by Jaimie 02/19/13 to only consider semi-consecutive bins
        
        x=diff(AboveThreshold);
        
        %indice values of bins whose next bin is less than 5 bins away
        y=find(x<5);%5 with a 2ms bin for no gaps >10ms,  changed 093013 to 20ms for fun testing
        
        %difference between these indice values (i.e. number of bins
        %between bins with a consecutive bin less than 5)
        z=diff(y);
        
        %indice values that differ by more than one (i.e. if number of bins
        %between bins with a consecutive bin less than 5 is more than 1; i.e. non-consecutive bins; i.e. if gaps exist between bins < 5 apart)
        zz=find(z>1);
        
        %if you have at least 1 pair of consecutive bins seperated by less
        %than 5 bins
        if length(y)>=1
            
            %if there are only two of these bins
            if isempty(zz)==1
            CAboveThreshold=AboveThreshold(y(1):length(AboveThreshold));    
            
            %if there is one pair of bins that are more than 1 bin apart 
            elseif length(zz)==1
                
                %if the first element in z is greater than 1 (i.e. first
                %pair of significant bins differ by more than 1; i.e. the first, second and third bins are not within 5 bins of each other)
                if zz(1)==1
                CAboveThreshold=AboveThreshold(y(1):y(1)+1);
                end
                CAboveThreshold=AboveThreshold(y(1):y(zz)+1);
            elseif zz(1)==1
                CAboveThreshold=AboveThreshold(y(1):y(zz(1)));
            else
                zzz=zz(1);
                CAboveThreshold=AboveThreshold(y(1):y(zzz));
            end
            Index1 = CAboveThreshold(1) ;
            Index2 = CAboveThreshold(end) ;
        %%end jaimie's latest changes
            AboveThreshold=CAboveThreshold;
        else
            
        end  

        


        

        
        % Background average
        BfrSpikesPerBin = sum(PEHMBackground)/length(PEHMBackground) ; % 
        % Response Duration
        ResponseDurationSecs = (Index2-Index1)*Binsize ;%%% %#ok<NASGU> % in seconds
        % Response Magnitude
        RMSpikes = sum(CurrMatrix(Index1:Index2));  % spikes per trial
%         % Response Magnitude spikes/trial/sec
%         RMSpikes = sum(CurrMatrix(Index1:Index2))/ResponseDurationSecs;  % spikes per trial per sec
        % Response Magnitude Background subtracted
        %%%adjusted by jaimie 081612 -RM_BSub
        RM_BSub = RMSpikes - sum(PEHMBackground(Index1:Index2));%/ResponseDurationSecs;%(BfrSpikesPerBin*(Index2-Index1)/ResponseDurationSecs);
        % Peak Response
        PRSpikes =  max(CurrMatrix(Index1:Index2));% in spikes per trial in one bin
        PRIndex = find(CurrMatrix(Index1:Index2)==PRSpikes, 1, 'last' );
        % Latencies
        FBL = options.response(1)+(Index1*Binsize) ;  % in seconds from event%%changed with response 1
        LBL = options.response(1)+(Index2*Binsize) ; % in seconds from event %%changed with response 1
        PL = FBL+ PRIndex*Binsize ; % in seconds from event
  
%         H=1;%%Jaimie taking out the ttest to figure out what is so frikkin weird about the PSTHes

            if BackgroundAvg>0
%              [H,SIGNIFICANCE CI] = ttest2(PEHMBackgroundT(1:10),CurrMatrix(Index1:Index2),0.05,'left'); %%jaimie trying weird shit 021913
             [H,SIGNIFICANCE CI] =    ttest2(PEHMBackground(Index1:Index2),CurrMatrix(Index1:Index2),0.05,'left'); %jaimie 021913 equivalent windows for background and currentmatrix
             
             
             
            else
                H=1;
            end
%                             
        if H == 0  % means not significantly different

            ResponseDurationSecs =0 ;
            RMSpikes = 0;%RMSpikes;%%%%0; Changes 081612 by jaimie
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
            
        elseif length(AboveThreshold)<3%%origincally 3 changed by jaimie 101713 to work with he initial posture data
            
%             BfrSpikesPerBin = 0 ;
            ResponseDurationSecs =0 ;
            RMSpikes = 0;
            RM_BSub = 0 ;
            PRSpikes =0;
            FBL = 0 ;
            LBL = 0 ;
            PL = 0 ;
            
        end
        
%         Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD i j] ;
        Parameters(i,:) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD i j] ;
        
        
        end
% %     

   
        
    toel= find(Parameters(:,1)==0);
    Parameters(toel,:)=[];
    PRF = find(Parameters(:,1)==max(Parameters(:,1)), 1, 'last' );
    NRM=Parameters(:,1)/Parameters(PRF,1);
    [NRM,b]=sort(NRM,'descend');
    Parameters = [NRM,Parameters(b,:),b,repmat(length(b),length(b),1)];
    ParamData=[ParamData;Parameters];
    clear Parameters
    end%%added with ifempty near UpThreshold, might want to remove - JD 08262011
end

