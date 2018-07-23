function ReceptiveFieldMatrix=receptivefield(PeriEventHistoMatrix,BinSize, TimePre, TimePost, Baseline, TaskPeriod,FixedWindow,NeuronNames, t, BackgroundNorm)

%[ReceptiveFieldMatrix]=receptivefield(PeriEventHistoMatrix,0.001, 100, 100, 1:95, 105:190,'n',NeuronNames, 0.001,'n');
%ReceptiveFieldMatrix= Stimuli x neurons x parameters
%parameters: [Response; Peak; FirstBinLatency; LastBinLatency; PeakLatency; BackgroundAvg; BackgroundSTD]
%
%TimePre,TimePost,Baseline,TaskPeriod in points
%
%FixedWindow='y' or 'n'
%
%BackgroundNorm = 'y' or 'n'
%
%28/2/2002 by Guglielmo Foffani (Drexel University)
%
%6/3/2002 -Inserted for loop (all neurons, all files) fot the MaxUpThresh calculation \
%			 -Save the parameter matrices in .txt tab delimited file
%
%2/4/2002 - Added FixedWindow
%
%11/9/2002 - talpha can be an input parameter. default value=0.001
%
%14/5/2004 - added normalization to the background

SaveWork='n';

if nargin>8
    talpha=t;
else
    talpha=0.001; %significance value for the t-test
end
NSTD=3; %a bin is significant if is NSTD times over the background average

TickRange=[0 20];

NumFiles=size(PeriEventHistoMatrix,3); %23
NumNeurons=size(PeriEventHistoMatrix,2); %67

ReceptiveFieldMatrix=zeros(NumFiles,NumNeurons,7);

if 0
    %MaxUpThresh (last bin with activity over the threshold in the all dataset)
    for j=1:NumNeurons
        for k=1:NumFiles
            Background=mean(PeriEventHistoMatrix(Baseline,j,k));
            Threshold=Background+2.58*std(PeriEventHistoMatrix(Baseline,j,k))/length(Baseline);
            UpThreshIndice=find(PeriEventHistoMatrix(TaskPeriod,j,k)>Threshold)+TaskPeriod(1)-1;
            MaxUpThresh=max([MaxUpThresh;UpThreshIndice]);
            %MinUpThresh=min([MinUpThresh;UpThreshIndice]);
        end
    end
end
%Calculation of the parameters
nneurons=0;
ttestfailed=0;
lengthfailed=0;
for j=1:NumNeurons
    for k=1:NumFiles

        BackgroundAvg=mean(PeriEventHistoMatrix(Baseline,j,k));
        BackgroundSTD=std(PeriEventHistoMatrix(Baseline,j,k));
        %Threshold=BackgroundAvg+2.58*BackgroundSTD/length(Baseline); % 99% confidence interval
        Threshold=BackgroundAvg+NSTD*BackgroundSTD;
        UpThreshIndice=find(PeriEventHistoMatrix(TaskPeriod,j,k)>Threshold)+TaskPeriod(1)-1;
        %significant bins can't be more than 10 bins apart Alessandro
%         while ~isempty(diff(UpThreshIndice)>10)
%             UpThreshIndice([false;diff(UpThreshIndice)>10])=[];
%         end
        
        if ~isempty(UpThreshIndice)
            nneurons=nneurons+1;
            if FixedWindow=='y'
                UpThreshIndice(1)=TaskPeriod(1);
                UpThreshIndice(end)=TaskPeriod(end);
            end
            Response=sum(PeriEventHistoMatrix(UpThreshIndice(1):UpThreshIndice(end),j,k));
            %Response=sum(PeriEventHistoMatrix(UpThreshIndice(1):MaxUpThresh,j,k));
            [Peak,PeakLatencyTemp]=max(PeriEventHistoMatrix(UpThreshIndice,j,k));
            FirstBinLatency=(UpThreshIndice(1)-TimePre)*BinSize; %in sec
            LastBinLatency=(UpThreshIndice(end)-TimePre)*BinSize; %in sec
            PeakLatency=(UpThreshIndice(PeakLatencyTemp)-TimePre)*BinSize; %in sec
            if BackgroundAvg>0
                [H,SIGNIFICANCE CI] = ttest2(PeriEventHistoMatrix(Baseline,j,k),PeriEventHistoMatrix(UpThreshIndice(1):UpThreshIndice(end),j,k),talpha);
            else
                H=1;
            end
            if H==0
                ttestfailed=ttestfailed+1;
                Response=0;
                Peak=0;
                FirstBinLatency=0;
                LastBinLatency=0;
                PeakLatency=0;
            end
            if length(UpThreshIndice)<3
                lengthfailed=lengthfailed+1;
                Response=0;
                Peak=0;
                FirstBinLatency=0;
                LastBinLatency=0;
                PeakLatency=0;
            end
%             if length(find(diff(UpThreshIndice)<2))<2
%                        lengthfailed=lengthfailed+1;
%                 Response=0;
%                 Peak=0;
%                 FirstBinLatency=0;
%                 LastBinLatency=0;
%                 PeakLatency=0;
%             end
            
        else
            Response=0;
            Peak=0;
            FirstBinLatency=0;
            LastBinLatency=0;
            PeakLatency=0;
        end



        parameters=[Response; Peak; FirstBinLatency; LastBinLatency; PeakLatency; BackgroundAvg; BackgroundSTD];
        for i=1:length(parameters)
            ReceptiveFieldMatrix(k,j,i)=parameters(i);
        end

    end
end
size(ReceptiveFieldMatrix);
nneurons;
ttestfailed;
lengthfailed;
if 0
    %Save the parameter matrices in .txt tab delimited file
    Response=ReceptiveFieldMatrix(:,:,1)';
    Peak=ReceptiveFieldMatrix(:,:,2)';
    FirstBinLatency=ReceptiveFieldMatrix(:,:,3)';
    LastBinLatency=ReceptiveFieldMatrix(:,:,4)';
    PeakLatency=ReceptiveFieldMatrix(:,:,5)';
    BackgroundAvg=ReceptiveFieldMatrix(:,:,6)';
    BackgroundSTD=ReceptiveFieldMatrix(:,:,7)';

    save Response.txt Response -ASCII -TABS
    save Peak.txt Peak -ASCII -TABS
    save FirstBinLatency.txt FirstBinLatency -ASCII -TABS
    save LastBinLatency.txt LastBinLatency -ASCII -TABS
    save PeakLatency.txt PeakLatency -ASCII -TABS
    save BackgroundAvg.txt BackgroundAvg -ASCII -TABS
    save BackgroundSTD.txt BackgroundSTD -ASCII -TABS
end

if SaveWork=='y'
    save workspace
end

if 0

    f=figure;
    %ymax=max(max(ReceptiveFieldMatrix(:,:,1))) %ATTENZIONE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ymax=max(max(ReceptiveFieldMatrix(:,:,5)))*1000; %ATTENZIONE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(ReceptiveFieldMatrix,2)
        h=subplot(ceil(2*(size(ReceptiveFieldMatrix,2)/2)^(1/2)),ceil((size(ReceptiveFieldMatrix,2)/2)^(1/2)),i);
        stem(ReceptiveFieldMatrix(:,i,1),'.') %response
        ymax=max(ReceptiveFieldMatrix(:,i,1));
        %stem(ReceptiveFieldMatrix(:,i,5)*1000,'.') %peak latency in ms
        %ymax=max(ReceptiveFieldMatrix(:,i,5)*1000);
        set(h,'XTick',TickRange)
        if ymax==0
            axis([1 size(ReceptiveFieldMatrix,1) 0 1])
        else
            axis([1 size(ReceptiveFieldMatrix,1) 0 ymax])
        end
        if size(ReceptiveFieldMatrix,2)==128
            n=num2str(ceil(i/4));
            if ceil(i/4)-i/4==.75
                lettera='a';
            end
            if ceil(i/4)-i/4==.5
                lettera='b';
            end
            if ceil(i/4)-i/4==.25
                lettera='c';
            end
            if ceil(i/4)-i/4==0
                lettera='d';
            end
            title(strcat('sig',n,lettera))
        else
            if nargin==8
                title(NeuronNames(i,:))
            else
                n=num2str(i);
                title(strcat('neuron',n))
            end
        end
    end
    set(f,'PaperUnits','centimeters');
    %set(f,'PaperType','a4letter')
    set(f,'PaperPosition',[0.63452 0.63452 20.305 26.65]);

    f=figure;
    for i=1:size(ReceptiveFieldMatrix,2)
        h=subplot(2*(size(ReceptiveFieldMatrix,2)/2)^(1/2),(size(ReceptiveFieldMatrix,2)/2)^(1/2),i);
        %stem(ReceptiveFieldMatrix(:,i,1),'.') %response
        %ymax=max(ReceptiveFieldMatrix(:,i,1));
        stem(ReceptiveFieldMatrix(:,i,5)*1000,'.') %peak latency in ms
        ymax=max(ReceptiveFieldMatrix(:,i,5)*1000);
        set(h,'XTick',TickRange)
        if ymax==0
            axis([1 size(ReceptiveFieldMatrix,1) 0 1])
        else
            axis([1 size(ReceptiveFieldMatrix,1) 0 ymax])
        end

        if size(ReceptiveFieldMatrix,2)==128
            n=num2str(ceil(i/4));
            if ceil(i/4)-i/4==.75
                lettera='a';
            end
            if ceil(i/4)-i/4==.5
                lettera='b';
            end
            if ceil(i/4)-i/4==.25
                lettera='c';
            end
            if ceil(i/4)-i/4==0
                lettera='d';
            end
            title(strcat('sig',n,lettera))
        else
            if nargin==8
                title(NeuronNames(i,:))
            else
                n=num2str(i);
                title(strcat('neuron',n))
            end
        end
    end
    set(f,'PaperUnits','centimeters');
    %set(f,'PaperType','a4letter')
    set(f,'PaperPosition',[0.63452 0.63452 20.305 26.65]);

end

if BackgroundNorm=='y'
    for i=1:NumFiles
        for n=1:NumNeurons
            if ReceptiveFieldMatrix(i,n,6)~=0
                if ReceptiveFieldMatrix(i,n,1)~=0
                    ReceptiveFieldMatrix(i,n,1)=ReceptiveFieldMatrix(i,n,1)./(ReceptiveFieldMatrix(i,n,6)*1000*(ReceptiveFieldMatrix(i,n,4)-ReceptiveFieldMatrix(i,n,3)));
                    ReceptiveFieldMatrix(i,n,2)=ReceptiveFieldMatrix(i,n,2)./(ReceptiveFieldMatrix(i,n,6));
                end
            end
        end
    end
end
