function [ParamData] = recfield_TILT_RAVI(PEHM,options,filename)
%% Setup 
% subplot Increment Pre-allocation
inc=1;
figNum=1;

% pull out relevant filename elements
splitFilpth=strsplit(filename,'\');
filnm=splitFilpth(end);
subplotTitle=filnm{1}(1:end-6);


% user-specified parameters (move out of function later)
binMin=5;  %minimum number of consecutive bins that must be above threshold
nueronsPerPage=5; %for subplotting only
adjcntBinMin=10; %foremly 5;  %minimum number bins between adjacent bins (defines bin cluster edges)
binClusterNum=2; %number of bin clusters to look for
NSTD =1.65; %number of standard deviations above threshold
%Note: 90%CI=1.65; 95%CI=1.96, 98%CI=2.33, 99%CI=2.58

% variable definitions
if  options.plot
    figHandle=figure;    %YOU NEED THIS FOR FIGURE PLOTTING!!
end

ParamData=[];
Binsize = options.bin;
bins=(-options.pretime:options.bin:options.posttime-options.bin); %note: this is the way the original PEHM was built
eventBin=find(bins==0);
numSubplotCells=size(options.CurrentEvents,2)*nueronsPerPage;
cellIndx=reshape([1:numSubplotCells],nueronsPerPage,[])';
cellIndx=cellIndx(:);

%% Main Code
for neuron = 1:size(PEHM,2)
    for event = 1:size(options.CurrentEvents,2)
        
        
        responsiveNeuron={false};
        
        PEHMBackground = PEHM(1:eventBin-1,...
            neuron,event);  %note: options.response feature removed; also CSR code used -200 to -100ms as backgrnd
        CurrMatrix = PEHM(eventBin:end...
            ,neuron,event);
        
        CurrMatrixS=smooth(CurrMatrix,3);   %moving average with a span of 3
        PEHMBackgroundS=smooth(PEHMBackground,3);
        
        BackgroundAvg=mean(PEHMBackground);
        BackgroundSTD=std(PEHMBackground);
        
        BackgroundAvgS=mean(PEHMBackgroundS);
        BackgroundSTDS=std(PEHMBackgroundS);
        
        
        
        Threshold = BackgroundAvg + NSTD*BackgroundSTD;
        ThresholdS = BackgroundAvgS + NSTD*BackgroundSTDS;
        
        aboveThreshBins = find(CurrMatrixS > ThresholdS);
        
        % initialize dependent variables
        BfrSpikesPerBin = sum(PEHMBackground)/length(PEHMBackground); %
        RMSpikes = 0;
        PRSpikes =0;
        FBL = 0;
        LBL = 0;
        PL = 0;
        Index1=0;
        Index2=0;
        H=0;
        cluster=1;
        clusterNum{event}=1;

        %% Increased Firing Rate Measures
        
        % if no bins above threshold  (or min not satisfied)  set everything to "0"
        if isempty(aboveThreshBins)==1 || nnz(aboveThreshBins)<binMin
            
            Parameters(event,:,cluster) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD event neuron 1] ;
        else
            
            Parameters(event,:,1) = [RMSpikes PRSpikes FBL LBL PL BfrSpikesPerBin BackgroundSTD event neuron 1] ;
            
            
            % identify bin clusters
            if length(aboveThreshBins)>2
                clusters=[];
                binClusterEdges=[];
                clusterRow=1;
                firstEdge=1;
                binClusterEdges=find(diff(aboveThreshBins)>adjcntBinMin);
                binClusterEdges=[0;binClusterEdges;length(aboveThreshBins)];
                
                for cluster=1:length(binClusterEdges)-1
                    clusters{cluster}=aboveThreshBins((binClusterEdges(cluster)+1):binClusterEdges(cluster+1));
                end
                
                clusterLength=cellfun(@length,clusters);
                [value,clusterNum{event}]=find(clusterLength>=binMin,binClusterNum);  %must have at least binMin to be a cluster
                
                
                
                % clusterNum is a cell input
                % if bin cluster >= bin min
                if ~isempty(clusterNum{event})==1
                    
                    clear aboveThreshBins Index1 Index2 BfrSpikesPerBin RMSpikes PRIndex FBL LBL PL Duration
                    
                    % finds measures for each cluster 
                    [RMSpikes,PRSpikes,FBL,LBL,PL,Index1,Index2,responsiveNeuron]=cellfun(@(x) measures(x,clusters,CurrMatrix,Binsize,PEHMBackground),...
                        num2cell(clusterNum{event}),'UniformOutput',false);
                    
                    % flag whether neuron is responsive or not
                    % responsiveNeuron=responsiveNeuron{1};
                    
                    BfrSpikesPerBin=sum(PEHMBackground)/length(PEHMBackground);
                    
                    % converts parameters into concatenated cell matrix
                    parametersCell=cellfun(@(x) parameters(x, RMSpikes,...
                        PRSpikes, FBL, LBL, PL, BfrSpikesPerBin, BackgroundSTD,...
                        event, neuron), num2cell(1:length(clusterNum{event})),'UniformOutput',false);
                    
                    % converts parameters cell into an event x measure x
                    % cluster matrix
                    for cluster=1:size(parametersCell,2)
                        Parameters(event,:,cluster)=cell2mat(parametersCell{cluster});
                    end
                    
                    % responsiveNeuron=1;
                    
                else
                    cluster=1;
                    clusterNum{event}=1;
                end
                
            end
            
        end
        
        %% Decrease in Firing Rate Measures
        
        
        
        
        
        %% Plotting 
        if  options.plot
        % figure plotting
        [inc, figHandle,figNum]=cellfun(@(x) PSTHplot(x,responsiveNeuron,options,nueronsPerPage,cellIndx,inc,Index1,Index2,...
            bins,PEHM,neuron, event,CurrMatrixS,ThresholdS,FBL,LBL,PL,PRSpikes,numSubplotCells,subplotTitle,figNum,...
            figHandle,length(clusterNum{event})),...
            num2cell(1:length(clusterNum{event})),'UniformOutput',false);
        inc=inc{end};
        figHandle=figHandle{end};
        figNum=figNum{end};
        
        end
        
    end
  
    
    
    Parameters=cellfun(@(x) normalizeMeasures(x,Parameters),...
        num2cell(1:size(Parameters,3))...
        ,'UniformOutput',false);
    
    tempParameters=[];
    for cluster=1:size(Parameters,2)
        newParameters=Parameters{1,cluster};
        tempParameters=[tempParameters;newParameters];
    end
    
    
  
    % find greatest response magnitude across events (includes all clusters)
    maxRMlogical=tempParameters(:,2)==max(tempParameters(:,2));
    
    % append logical array to tempParameters
    tempParameters=[tempParameters,maxRMlogical];  %parametes for a single neuron across event types
    

    % define columns 
    origNormRespCol=1;
    eventCol=9;  % column with event numbers
    maxRespClusterCol=14; % column with maximually responsive clusters
    normRespCol=15; % column with new normalized responses
    TFSCol=16; % number of tilts neuron respon to col
    princTiltCol=17;  % tilt type neuron most resp to col (i.e. principle tilt)
    diffTypeLabelCol=18; % column describes if differnece with 0 or not
    
    PR_BSCol=19;
    RM_BSCol=20;

    RM_Col=2;
    PR_Col=3;
    BGN_Col=7;
    FBL_Col=4;
    LBL_Col=5;
    
    
    % extract responsive event types 
    evnts=unique(tempParameters(:,eventCol));
    
    if isempty(evnts)
        clear Parameters
        continue
    end
    
    % create matrix corresponding to rows of event types 
    eventLog=tempParameters(:,eventCol)==evnts';
    
  
    for evnt=1:length(evnts)
        % find column that corresponds to event
        evn=find(evnts==evnts(evnt));
        
        % find maximally responsive clusters
        withinEventMaxInd(evnt)=find(tempParameters(:,2)==max(tempParameters(eventLog(:,evn),2)),1,'last');
    end
    
   
    
    % flag maximally responsive clusters with "1"
    tempParameters(withinEventMaxInd,maxRespClusterCol)=1;
    
    % highest response when using maximally responsive cluster only per event  
    [maxResp_1clusteronly,princTilt]=max(tempParameters(withinEventMaxInd,2));
    
    % normalized response when using maximally responsive cluster only per
    % event
    tempParameters(:,normRespCol)=tempParameters(:,2)/maxResp_1clusteronly;
    
    % number events the neuron is responsive to
    tempParameters(:,TFSCol)=repmat(length(evnts),size(tempParameters,1),1);
    
    
    tempParameters(:,princTiltCol)=repmat(princTilt,size(tempParameters,1),1);
    
   
    
    % response magnitude (background subtractred)
    tempParameters(:,RM_BSCol)=tempParameters(:,RM_Col)-[(tempParameters(:,BGN_Col)).*...
        (1/options.bin).*(tempParameters(:,LBL_Col)-tempParameters(:,FBL_Col))]; %RMSpikes-[(BfrSpikesPerBin)(1/binsize)(LBL-FBL)]
    
    % peak response (background subtracted)
    tempParameters(:,PR_BSCol)=tempParameters(:,PR_Col)-tempParameters(:,BGN_Col); %PRSpikes-BfrSpikesPerBin
  
    
    
    if isfield(options,'eventComparisons') && tempParameters(1,1)~=0
        
        % extract event comparisons 
         eventComparisons=options.eventComparisons;
        
        
         for comparison=1:size(eventComparisons,2)
             
             
             % find indices where comparison events exist in
             % "tempParameters" (only across one cluster) 
             [~,comprInd]=ismember(eventComparisons{comparison},tempParameters(withinEventMaxInd,eventCol));
             
             % create row of "0's" if such a row does not already exit
             if sum(sum(tempParameters,2)==0)==0
                 
                 %size(tempParameters(withinEventMaxInd),1)<numel(comprInd)
                 %                  tempParameters=[tempParameters(withinEventMaxInd,:);zeros(numel(comprInd)-...
                 %                      size(tempParameters(withinEventMaxInd,:),1),size(tempParameters(withinEventMaxInd,:),2))];
                 
                 % add a row of zeros 
                 tempParameters=[tempParameters;zeros(1,size(tempParameters,2))];
             end
             
             % label for difference type 
             diffTypeLabel=sum(0==comprInd,2)>0; %"1" means a value was mising for that difference
             
             % if "0" in comprInd (i.e. neuron not responsive for 1 or more
             % tilts) replacing missing indice with missing indice
            %comprInd(comprInd==0)=eventComparisons{comparison}(~comprInd);
            
            % replacing missing comparison indices with an indice
            % corresponding to row of zeros 
             comprInd(comprInd==0)=find(sum(tempParameters,2)==0,1,'first');
             
           
             
             comparisonDiffinds=[2:8,normRespCol,PR_BSCol,RM_BSCol];
             % take differences of specified comparisons [col(2)-col(1)]
             comparisonDiffs=diff(tempParameters(comprInd',...
                 comparisonDiffinds));
             comparisonDiffs=comparisonDiffs([1,end],:);
             
             % extract event columns
             compareCol1=num2str(eventComparisons{comparison}(:,1));
             compareCol2=num2str(eventComparisons{comparison}(:,2));
             
             % add event comparisons labels
             comparisonDiffs=[comparisonDiffs,str2num(strcat(compareCol2,compareCol1))];
             comparisonDiffinds=[comparisonDiffinds,eventCol];
             
             % append to tempParameters
             tempAppend=repmat(tempParameters(1,:),size(comparisonDiffs,1),1);%nan(size(comparisonDiffs,1),size(tempParameters,2));
%              tempAppend(:,2:size(comparisonDiffs,2))=comparisonDiffs(:,[1:end-2,end]);
%              tempAppend(:,normRespCol)=comparisonDiffs(:,end-1);
             
             
             tempAppend(:,comparisonDiffinds)=comparisonDiffs;
             
             % replace normResp cols with "0"
             tempAppend(:,[origNormRespCol,normRespCol])=zeros(size(tempAppend,1),2);
             
             
             
             % append to tempParameters
             tempParameters=[tempParameters;tempAppend];
             
             % add diffType Label
             tempParameters(end-(size(diffTypeLabel,1)-1):end,...
                 diffTypeLabelCol)=diffTypeLabel;
             
         end
    end
         
    % remove row of parameters if response magnitude = 0
    tempParameters(tempParameters(:,2)==0,:)=[];
    
    % concatenate into matrix representing responses across neurons
    ParamData=[ParamData;tempParameters];
    clear Parameters
    
end


%% Saving 
% YOU NEED THIS FOR FIGURE PLOTTING!!!!!
% save figure
if sum(strcmpi(fieldnames(options),'saveFigFldr'))>0 && options.plot  %if save folder exists
    currentFolder=pwd;
    cd(options.saveFigFldr)
    
   
    if isfield(options,'trials')
        
        % extract trials
        trials=options.trials{:};
        
        % save
        savefig(figHandle,[subplotTitle,'_',options.regionname,...
            '_','trials(',num2str(trials(1)),'-',num2str(trials(end)),').fig'],...
            'compact');
        
    end
    
    cd(currentFolder);
    close all
end
end


%% In-house Functions

% calculates Recfield Measures
function [RMSpikes,PRSpikes,FBL,LBL,PL,Index1,Index2,responsiveNeuron]=measures(clusterNum,clusters,CurrMatrix,Binsize,PEHMBackground)

% pre-allocate responsive neuron flag
responsiveNeuron=false;

% locate above threshold bins
aboveThreshBins=clusters{clusterNum};
Index1=aboveThreshBins(1);
Index2=aboveThreshBins(end);

% response magnitude
RMSpikes = sum(CurrMatrix(Index1:Index2));  % # of spikes per trial (within response window)

% peak response
PRSpikes =  max(CurrMatrix(Index1:Index2));% in spikes per trial in one bin
PRIndex = find(CurrMatrix(Index1:Index2)==PRSpikes, 1, 'last' );

% latencies
FBL = (Index1-1)*Binsize;  % in seconds from event%%changed with response 1  Don't understand the need for offset here
LBL = (Index2-1)*Binsize; % in seconds from event %%changed with response 1
PL = FBL+ (PRIndex-1)*Binsize ; % in seconds from event


% ttest for significance
significant = ttest2(PEHMBackground(Index1:Index2),CurrMatrix(Index1:Index2),0.001,'left');

backgroundFiringRate=sum(PEHMBackground)/length(PEHMBackground);

% identify false positives
if RMSpikes<.002 || LBL==0 || PL==0 || backgroundFiringRate<0.01
    false_positive=true;
else
    false_positive=false;
end

% determine if response significant
if significant && ~false_positive
    
    % set responsive flag to true if significant
    responsiveNeuron=true;
else
    % set responsive flag to false if not significant
    responsiveNeuron=false;
    
    % set all dependent variables to 0
    RMSpikes=0;
    PRSpikes=0;
    FBL=0;
    LBL=0;
    PL=0;
end

end

% allows for iteration between parameters for each cluster
function [Parameters]=parameters(clusterInd, RMSpikes, PRSpikes,...
    FBL, LBL, PL, BfrSpikesPerBin, BackgroundSTD, event, neuron)

Parameters= [RMSpikes(clusterInd) PRSpikes(clusterInd) FBL(clusterInd) LBL(clusterInd) PL(clusterInd) BfrSpikesPerBin BackgroundSTD event neuron clusterInd] ;

end





%% Generates Plots
function [inc, figHandle,figNum]=PSTHplot(clusterInd,responsiveNeuron,options,nueronsPerPage,cellIndx,inc,Index1,Index2,...
    bins,PEHM,neuron, event,CurrMatrixS,ThresholdS,FBL,LBL,PL,PRSpikes,numSubplotCells,subplotTitle,figNum,figHandle,maxClusters)

figure(figHandle(figNum))
if responsiveNeuron{clusterInd}==1 %H==1 && RMSpikes>0
    
    clusterColors=['r','b','g'];
    
    % options.anchan has all the info you need for plotting
    subplot(size(options.CurrentEvents,2),nueronsPerPage,cellIndx(inc))
    
    % bins used
    selectedBins=[Index1{clusterInd}:Index2{clusterInd}]+options.pretime/options.bin;
    
    if clusterInd==1
        % raw PEHM
        PEHMarray=PEHM(:,neuron, event);
        bar(bins',PEHMarray,'k','BarWidth',1);
        axis ([min(bins) max(bins)+.002 0 max(PEHMarray)+ std(PEHMarray)]);
        
        % response magnitude
        hold on
        bar(bins(selectedBins),CurrMatrixS(Index1{clusterInd}:Index2{clusterInd}),'g',...
            'BarWidth',1);
        
        % threshold
        hold on
        plot([bins(1),bins(end)],[ThresholdS,ThresholdS],'g-');
    end
    
    
    
    % FBL
    hold on
    plot([FBL{clusterInd}, FBL{clusterInd}],[0,PRSpikes{clusterInd}],clusterColors(clusterInd))
    
    % LBL
    hold on
    plot([LBL{clusterInd}, LBL{clusterInd}],[0,PRSpikes{clusterInd}],clusterColors(clusterInd))
    
    % PL
    hold on
    plot(PL{clusterInd},PRSpikes{clusterInd},[clusterColors(clusterInd),'o'])
    
    IndicesData{neuron, event}=[Index1{clusterInd},Index2{clusterInd}];
    ThresholdSData{neuron, event}=ThresholdS;
    
    
    % inserting cellname
    title(['sig',sprintf('%03.0f',options.anchan(neuron,1)),...
        char(options.anchan(neuron,2)+96)]);
    
    
    % subplot cell incrementer
    inc=inc+1;
    
    % if subplots full make a new figure
    if inc>numSubplotCells && clusterInd==maxClusters
        %rem((neuron*event)/numCells,1)==0
        suptitle(subplotTitle)
        figNum=figNum+1;
        %close;
        figHandle(figNum)=figure;
        
        inc=1;
        
        
        
        % if subplot not full but this is the last iteration add a
        % title
    elseif neuron == size(PEHM,2) && event==size(options.CurrentEvents,2) %and on last event
        suptitle(subplotTitle)
        
    end
else
    subplot(size(options.CurrentEvents,2),nueronsPerPage,cellIndx(inc))
    PEHMarray=PEHM(:,neuron, event);
    bar(bins',PEHMarray,'k','BarWidth',1);
    
    if max(PEHMarray)==0
        UL=1;
    else
        UL=max(PEHMarray);
    end
    
    axis ([min(bins) max(bins)+.002 0 UL + std(PEHMarray)])
    
    title(['sig',sprintf('%03.0f',options.anchan(neuron,1)),...
        char(options.anchan(neuron,2)+96)]);
    
    inc=inc+1;
    
    if inc>numSubplotCells && clusterInd==maxClusters
        
        suptitle(subplotTitle)
        figNum=figNum+1;
        %close;
        figHandle(figNum)=figure;
        
        inc=1;
        
        %if subplot not full but this is the last iteration add a
        %title
    elseif neuron == size(PEHM,2) && event==size(options.CurrentEvents,2)
        suptitle(subplotTitle)
    end
    
end

end

function [Parameters]=normalizeMeasures(clusterInd,Parameters)

% convert parameters array to cell
parametersCell=num2cell(Parameters,[1 2]);


% remove non-responsive tilts
toel= find(Parameters(:,1,clusterInd)==0);
parametersCell{1,1,clusterInd}(toel,:)=[];


% normalize to when neuron most responsive (across tilts)
RM=parametersCell{1,1,clusterInd}(:,1);

PRF=find(RM==max(RM),1,'last');

%PRF = find(Parameters(:,1,clusterInd)==max(Parameters(:,1,clusterInd)), 1, 'last' );

NRM=RM/RM(PRF);

[NRM,b]=sort(NRM,'descend');


% define parameters
% parameters should be the cll
Parameters = [NRM,parametersCell{1,1,clusterInd}(b,:),...
    repmat(PRF,length(b),1),repmat(length(b),length(b),1)];  %b is event, repmat for RFS

% find most responsive cluster per tilt type

end


