function [outdataset,errorCell,processedCell]=PSTH_Classification_Analysisv2(filenames,options)

%$Rev: 125 $
%$Author: Nate $
%$LastChangedDate: 2017-05-05 21:19:14 -0400 (Fri, 05 May 2017) $


%Pre-allocate cell to store files with errors
[errorCell,processedCell,perfBtsp,...
    synRed_bootsub,synRed_bootsub_zero]=deal([]);

processedCount=0;

if isfield(options,'bootstrapped') && options.bootstrapped
    
    %Cases when user does not want to find bootstrap number iteratively
    if ~isfield(options,'bootstrapCI')
        options.bootstrapCI = 0;
    end
    
else
    options.bootstrapped=0;
end

if isfield(options,'intervals')
    
else
    intervals={'all'};
end

if isfield(options,'firstspike')
else
    options.firstspike='all';
end

if isfield(options,'vardropping')
else
    options.vardropping=0;
end

if isfield(options,'trialshuffling')
else
    options.trialshuffling=0;
end
if isfield(options,'synred')
else
    options.synred=0;
end
if isfield(options,'stimback')
else
    options.stimback=0;
end
if isfield(options,'timewindow')
    if options.timewindow==1
        options.timewindowstop=1*options.posttime;
        options.timewindowstart=-1*options.pretime;
        options.timewindow=timewindowstart+timewindowstep:timewindowstep:timewindowstop;
    else
        options.timewindow=1*options.posttime;
    end
else
    options.timewindow=1*options.posttime;
end
if ~isfield(options,'trials')
    options.trials=1;
end


save('temp','-struct','options');
load temp;
outdataset=[];
fprintf('\n')
tw=1;
errorCount=0;
saveCount=1;

[synRed_between_bootsub, synRed_between]=deal([]);


%if user wants to label rows using BMIKey.xls
if exist('BMIkey','var') && ischar('BMIkey')
    [BMIKey_vals,~,BMIKey_raw]=xlsread(BMIkey);
else
    [BMIKey_vals,BMIKey_raw]=deal([]);
end


for t=timewindow
    clc
    ft=fprintf('Time Window: %2.0f|%2.0f',tw,length(timewindow));
    for f=1:length(filenames)
        
        clc
        fprintf('\n')
        
        %         I_sr=[];
        %         perf_sr=[];
        %         I_sr_bootstrapped=[];
        %         perf_sr_bootstrapped=[];
        
        
        % [I_sr,perf_sr,I_sr_bootstrapped,perf_sr_bootstrapped,cellNames]=deal({nan(1,1)});
        
        
        
        
        iterationCount=0;
        
        
        if exist('evchanCell','var')
            options.evchannels=options.evchanCell{f};
        elseif length(f)>1
            warning('User-specified event channels assumed to be the same across all input files. For file-specific events the user must specify "evchanCell" ')
        else
        end
        
        try
            fc=fprintf(',File: %2.0f|%2.0f',f,length(filenames));
            for r=1:length(region)
                rc=fprintf(',Region %2.0f|%2.0f',r,length(region));
                for i=1:length(intervals)
                    ic=fprintf(',Interval %2.0f|%2.0f',i,length(intervals));
                    for b=1:length(binsizean)
                        bc=fprintf(',Binsize %2.0f|%2.0f',b,length(binsizean));
                        for trialSet=1:size(trials,2)
                            
                            filename=filenames{f};
                            options.region=region{r};
                            options.regionname=regionname{r};
                            options.bin=binsizean(b);
                            options.intervals=intervals{i};
                            options.trialSet=trialSet;
                            
                            if options.timewindow
                                options.posttime=t;
                                rat=(options.posttime+options.pretime)/options.bin;
                                if rat>=1
                                else
                                    delete_char(bc)
                                    break
                                end
                            end
                            
                            %Create PEHM using a 1ms bin only
                            options.allChansUsed=1:32; %temp  (if true do below first iteration only
                            
                            if isfield(options,'allChansUsed') && iterationCount==0
                                [PEHMClass1,Group,chanGroup,Duration,~]  = PEHM1ms(options,filename,b);
                            end
                            
                            
                            %(if true do below first iteration only
                            if (length(options.bin) || length(options.binsizean))<2 &&  iterationCount==0
                                [Neurons_all,bin_matr,PEHMClass_binselect] = PEHMbinselect(options,Duration,PEHMClass1 );
                                
                                %pre-allocation
                                [I_sr,perf_sr,I_sr_bootstrapped,...
                                    perf_sr_bootstrapped,cellNames]=deal(cell(Neurons_all,length(region)));
                                
                            end
                            
                            iterationCount=iterationCount+1;
                            
                            
                            
                            [ PEHMClass,Neurons]  = PEHMchanselect(PEHMClass_binselect, bin_matr, Neurons_all,chanGroup,options);
                            
                            
                            
                            %                             if b==1 && strcmpi(options.bin,.001)
                            %                                 [PEHMClass1,Group]=PEHMClassFromMatnd(filename,options);
                            %                                 Duration=length((-options.pretime:.001:options.posttime))-1;
                            %                                 Neurons=size(PEHMClass1,2)/Duration;
                            %                             elseif b==1 && ~strcmpi(options.bin,.001)
                            %                                 tempBin=options.bin;
                            %                                 options.bin=.001;
                            %                                 [PEHMClass1,Group]=PEHMClassFromMatnd(filename,options);
                            %                                 options.bin=tempBin;
                            %                                 Duration=length((-options.pretime:.001:options.posttime))-1;
                            %                                 Neurons=size(PEHMClass1,2)/Duration;
                            %                             else
                            %                             end
                            
                            %                             %derives a PEHM of any bin size from a PEHM made
                            %                             %using a 1ms binsize
                            %                             bin_matr=create_binmatr(options.bin*1000,Duration,Neurons);
                            
                            if isempty(PEHMClass)
                                disp(['Region of electrode ',num2str(r),' not used'])
                                continue
                            end
                            
                            %if user specified number of trials use them
                            %otherwise use all possible trials
                            if isfield(options,'trials') && max(trials{trialSet})<size(Group,1)
                                trialsSelect=trials{trialSet};
                                
                            else
                                trialsSelect=1:size(Group,1);
                            end
                            
                            options.trialsSelect=trialsSelect;
                            
                            
                            %                             %PEHM with user-defined bin size
                            %                             PEHMClass=PEHMClass1*bin_matr;
                            
                            %PEHM with user-defined trials
                            [PEHM_select,Group_select] = PEHMtrialselect(filename,trialsSelect,PEHMClass,Group,options);
                            
%                             combineArray=[2,1;4,3];
                            
                            if isfield(options,'combineArray')
                                for pair=1:size(options.combineArray,1)
                                    Group_select(ismember(Group_select,options.combineArray(pair,:)))=pair;
                                    %options.evchannels=[1,2];
                                end
                            end
                            
                            
                            
                            %General Classification
                            if ~exist('fullInformationAnalysis','var') || fullInformationAnalysis==1
                                
                                
                                
                                [ConfusionMatrix,Ir,perf,class]=classify_PSTH(PEHM_select,Group_select,options);
                                I(1)=Ir;
                                I(9)=Neurons;
                                
                                %store information output for each region
                                informationArray(r)=Ir;
                                
                                if ~strcmpi(options.firstspike,'all')
                                    I(5)= [[I(1)/sum(sum(PEHM_select)/size(PEHM_select,1))]];
                                    I(6)= sum(sum(PEHM_select));
                                    I(7)= sum(size(PEHM_select,1));
                                end
                                
                                % bootstrap calculation
                                if bootstrapped
                                    [InformationBtsp,perfBtsp]= BootstrapFunction(PEHM_select,Group_select,options);
                                    I(2) = [InformationBtsp] ;
                                    
                                    %store information output for each region
                                    informationBtspArray(r)=InformationBtsp;
                                    
                                    if ~strcmpi(options.firstspike,'all')
                                        I(8)= [[I(2)/sum(sum(PEHM_select)/size(PEHM_select,1))]];
                                    end
                                else
                                    [perfBtsp,synRed_bootsub,synRed_bootsub_zero]=deal([]);
                                    
                                end
                            else
                                [ConfusionMatrix,perf,class,I(1),I(9)]=deal(nan(1));
                                
                            end
                            
                            %shuffled Information for the estimate of DInoise=I-Ish
                            if options.trialshuffling>1
                                
                                for sh=1:options.trialshuffling
                                    shc=fprintf(',Trialshuffling %2.0f|%2.0f',sh,options.trialshuffling);
                                    S=unique(Group_select);
                                    PEHM_select_s=[];
                                    for g=S'
                                        PEHM_select_s=[PEHM_select_s;Trial_Shuffle_PEM(PEHM_select(Group_select==g,:),Neurons)];
                                        
                                    end
                                    [ConfusionMatrix_sh{sh},I_sh{sh},perf_sh{sh},class_sh{sh}]=classify_PSTH(PEHM_select_s,Group_select,options);
                                    delete_char(shc)
                                end
                                I(3)= [mean([I_sh{:}])] ;
                            end
                            
                            %synergy/redundancy for the estimate of the
                            %DIsig=Synred-DInoise
                            if options.synred
                                if r==1  %for first brain region iteration only
                                    
                                    %get filename information
                                    info=GetMatndInfo(filename);
                                    
                                    %mask to extract relevant channels
                                    neuronMask=true(size(options.region));
                                    
                                    %mask to extract relevant neuron names
                                    neuronNamesMask=ismember(info.chanunits(:,1),...
                                        options.region(neuronMask));
                                    
                                    %relevant neuron name indice values
                                    neuronInd=find(neuronNamesMask);
                                else
                                    
                                    %if second iteration and beyond only use neurons
                                    %that have not already been analyzed (i.e.
                                    %unused)
                                    
                                    %mask to extract unused channels
                                    neuronMask=~ismember([region{1:r-1}],region{r});
                                    
                                    %mask to extract unused neuron names
                                    neuronNamesMask=ismember(info.chanunits(:,1),...
                                        options.region(neuronMask));
                                    
                                    %unused neuron name indice values
                                    neuronInd=find(neuronNamesMask)-...
                                        find(neuronNamesMask,1)+1;
                                    
                                end
                                
                                %create cell array of cell/neuron names
                                cellNames{r}=info.channame(neuronNamesMask);
                                
                                %for each neuron
                                B=size(PEHM_select,2)/length(neuronInd);
                                
                                
                                if ~isempty(neuronInd)
                                    for n=neuronInd(1):neuronInd(end)
                                        
                                        %calculate information & performance
                                        ssr=fprintf(',SynRed Neuron %2.0f|%2.0f',n,Neurons);
                                        PEHM_select_sn=PEHM_select(:,(n-1)*B+1:n*B);
                                        [~,I_sr{n,r},perf_sr{n,r},~]=classify_PSTH(PEHM_select_sn,Group_select,options);
                                        delete_char(ssr)
                                        
                                        %calculate bootstrapped information & performance
                                        if bootstrapped
                                            [InfoBtsp_snglNeurn,PerfBtsp_singlNeurn] = BootstrapFunction(PEHM_select_sn,Group_select,options);
                                            I_sr_bootstrapped{n,r} = InfoBtsp_snglNeurn;
                                            perf_sr_bootstrapped{n,r}=PerfBtsp_singlNeurn;
                                        end
                                    end
                                    
                                else
                                    
                                    %create cell array using previously
                                    %collected arrays
                                    cellNames{r}=vertcat(cellNames{:});  %cell names
                                    I_sr_previous=num2cell([I_sr{:,:}]'); %information
                                    perf_sr_previous=num2cell([perf_sr{:,:}]'); %performance
                                    I_sr_bootstrapped_previous=num2cell([I_sr_bootstrapped{:,:}]'); %information bootstrapped
                                    perf_sr_bootstrapped_previous=num2cell([perf_sr_bootstrapped{:,:}]'); %performance bootstrapped
                                    
                                    %for each neuron(collected previously)
                                    for n=1:length(I_sr_previous)
                                        
                                        %define information & performance
                                        ssr=fprintf(',SynRed Neuron %2.0f|%2.0f',n,Neurons);
                                        I_sr{n,r}=I_sr_previous{n};
                                        perf_sr{n,r}= perf_sr_previous{n};
                                        
                                        %define information & performance
                                        %bootstrapped
                                        if bootstrapped
                                            I_sr_bootstrapped{n,r}= I_sr_bootstrapped_previous{n};
                                            perf_sr_bootstrapped{n,r}=perf_sr_bootstrapped_previous{n};
                                        end
                                    end
                                end
                                
                                
                                if bootstrapped
                                    
                                    %if ~isempty(neuronInd)
                                    %SINGLE NEURON INFORMATION
                                    
                                    %no bootstrap subtraction
                                    I(4)= sum([I_sr{:,r}]) ;
                                    
                                    %bootstrap subtraction
                                    
                                    infoDifftemp=[I_sr{:,r}]-[I_sr_bootstrapped{:,r}];
                                    synRed_bootsub = sum(infoDifftemp);
                                    
                                    %bootstrap subtraction w/ neg vals set = 0
                                    negvalMask=infoDifftemp<0;
                                    infoDifftemp(negvalMask)=[];
                                    synRed_bootsub_zero = sum(infoDifftemp);
                                    
                                else
                                    
                                    %set number of times bootstrapping=0
                                    options.bootstrapnum=0;
                                    
                                    %no bootstrap subtraction
                                    I(4)= [] ;
                                    
                                    %bootstrap subtraction
                                    infoDiff=[];
                                    infoDifftemp=[];
                                    synRed_bootsub = [];
                                    
                                    %bootstrap subtraction w/ neg vals set = 0
                                    synRed_bootsub_zero = [];
                                    
                                end
                                
                                %if all regions' variables calculated
                                if exist('synBetween','var') && r==length(region)
                                    
                                    
                                    term1= strcmpi(synBetween{1},regionname);
                                    term2=strcmpi(synBetween{2},regionname);
                                    term3=strcmpi(synBetween{3},regionname);
                                    
                                    if length(informationArray)>1
                                        %Synergy/redundancy between hemispheres
                                        %(or selected regions)
                                        synRed_between=informationArray(term1)...
                                            -(informationArray(term2)+informationArray(term3));
                                        
                                    else
                                        
                                        synRed_between=[];
                                    end
                                    
                                    
                                    
                                    if bootstrapped && length(informationArray)>1
                                        % Perform bootstrap subtraction
                                        info_bootsub=informationArray-informationBtspArray;
                                        
                                        synRed_between_bootsub=info_bootsub(term1)...
                                            -(info_bootsub(term2)+info_bootsub(term3));
                                        
                                    end
                                    
                                else
                                    
                                    [synRed_between,synRed_between_bootsub]=deal(nan(1));
                                    
                                    
                                end
                                
                            else
                                
                                %empty below variables
                                %                                 I_sr_bootstrapped{n,r}= I_sr_bootstrapped_previous{n};
                                %                                             perf_sr_bootstrapped{n,r}=perf_sr_bootstrapped_previous{n};
                                
                                % [I_sr_bootstrapped, perf_sr_bootstrapped,
                                
                                neuronInd=[];
                                
                            end
                            
                            
                            
                            
                            %for error output collection
                            processedCount=processedCount+1;
                            processedCell{processedCount,1}=filename;
                            processedCell{processedCount,2}=timewindow;
                            processedCell{processedCount,3}=options.regionname;
                            processedCell{processedCount,4}=binsizean(b);
                            
                            %create ouput dataset (of overall function)
                            outdataset=createdataset(filename,ConfusionMatrix,...
                                I,perf,perfBtsp,class,options,outdataset,...
                                errorCell,I_sr(:,r),I_sr_bootstrapped(:,r),...
                                synRed_bootsub,synRed_bootsub_zero,cellNames{r},...
                                perf_sr(:,r),perf_sr_bootstrapped(:,r),...
                                synRed_between,synRed_between_bootsub,...
                                BMIKey_vals,BMIKey_raw);
                            
                            %save if file gets too large
                            if size(outdataset,1)>5000
                                save(['TiltDiscriminationOutput2_',num2str(saveCount),...
                                    '.mat'],'outdataset','-v7.3')
                                outdataset=[];
                                saveCount=saveCount+1;
                            end
                            
                            if isempty(neuronInd)
                                
                                % Set column empty or next iteration
                                [I_sr(:,r), I_sr_bootstrapped(:,r), cellNames{r},...
                                    perf_sr(:,r),perf_sr_bootstrapped(:,r)]=deal(cell(size(I_sr,1),1));
                                
                            end
                            
                            
                        end
                        
                        delete_char(bc)
                    end
                    delete_char(ic)
                end
                delete_char(rc)
            end
            delete_char(fc)
            
            
        catch error
            
            errorCount=errorCount+1;
            errorCell{errorCount,1}=filename;
            errorCell{errorCount,2}=error.message;
            errorCell{errorCount,3}=timewindow;
            
        end
    end
    delete_char(ft)
    tw=tw+1;
end








function [ConfusionMatrixnotnorm,I,perf,Class]=classify_PSTH(PEHM_select,Group_select,options)

if options.stimback==1
    if min(Group_select)~=0
    else
        Group_select(Group_select~=0)=2;
        Group_select(Group_select==0)=1;
    end
elseif options.stimback==2
    Group_select=Group_select+1;
end
[Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PEHM_select,Group_select,'Euclidean',[],0,options.vardropping,0,0,1,0);
for k=1:size(ConfusionMatrixnotnorm,3)
    perf(k,1)=sum(diag(ConfusionMatrixnotnorm(:,:,k)))/sum(sum(ConfusionMatrixnotnorm(:,:,k)));
    I(k,1)=I_confmatr(ConfusionMatrixnotnorm(:,:,k));
end

function outdataset=createdataset(filename,ConfusionMatrix,...
    I,perf,perfBtsp,class,options,outdataset,...
    errorCell,I_sr,I_sr_bootstrapped,...
    synRed_bootsub,synRed_bootsub_zero,cellNames,perf_sr,perf_sr_bootstrapped,...
    synRed_between,synRed_between_bootsub,BMIKey_vals,BMIKey_raw)

%[fields,values]=get_file_info(filename,'date_animal_exp_stim_');
[fields,values]=get_file_info(filename,'study_animal_exp_day_date_');
for i=1:length(fields)
    fileinfos{i}={values(i),fields{i}};
end

tempdatasetadd={};




for k=1:size(ConfusionMatrix,3)  %note: the third dimension is for 'variable-dropping' (see MyClassify/ Foffani & Moxon, 2004)
    
    tempdataset(k,:)=dataset({I(k,1),'Info_Ensemble'},...
        {perf(k),'Performance'},{{ConfusionMatrix(:,:,k)},'ConfusionMatrix'},...
        {{class},'Classes'},{{options.regionname},'RegionOfElectrode'}...
        ,{options.bin,'Binsize'},{options.pretime,'Pretime'},...
        {options.posttime,'Posttime'},{{options.intervals},'Intervals'}...
        ,fileinfos{:},{I(k,end),'NumCells'},...
        {size(ConfusionMatrix,1),'NumEvents'},{options.bootstrapnum,'NumBootstraps'});
    
    if options.vardropping
        tempdatasetadd{1}=dataset({k,'VarDrop'});
    end
    
    if options.bootstrapped
        if ~isnan(I(1))
            tempdatasetadd{2}=dataset({I(k,2),'Info_Ensmble_Bootstrpd'});
            tempdatasetadd{13}=dataset({perfBtsp,'Perf_Ensmble_Boostrpd'});
        end
    end
    
    if options.trialshuffling>1
        tempdatasetadd{3}=dataset({I(k,3),'Info_Ensmble_Shffld'});
        
    end
    
    if options.synred
        
        tempdatasetadd{4}=dataset({I(k,4),'Info_SingNeurn'});
        
        tempdatasetadd{16}=dataset({synRed_between,'SynRed_Bet_Hemi'});
        
        
        
    end
    
    if options.expandedformat
        if ~isempty(I_sr)
            
            %create cell name dataset
            CellName=dataset(cellNames,'VarNames','CellName');
            
            %create information for each neuron dataset
            NeurnInfoVector= dataset([I_sr{:}]',...
                'VarNames','NeurnInfoVector');
            
            
            
            %create performance for each neuron dataset
            NeurnPerfVector=dataset([perf_sr{:}]',...
                'VarNames','NeurnPerfVector');
            
            
            
            if options.bootstrapped
                
                %create bootstrapped information for each neuron dataset
                NeurnInfoVector_Bootstrpd=dataset([I_sr_bootstrapped{:}]',...
                    'VarNames', 'NeurnInfoVector_Bootstrpd');
                
                
                %create bootstrapped performance for each neuron dataset
                NeurnPerfVector_Bootstrpd=dataset([perf_sr_bootstrapped{:}]',...
                    'VarNames', 'NeurnPerfVector_Bootstrpd');
            else
                
                
                
                %create bootstrapped information for each neuron dataset
                NeurnInfoVector_Bootstrpd=dataset(nan(size(cellNames,1),1),...
                    'VarNames', 'NeurnInfoVector_Bootstrpd');
                
                %create bootstrapped performance for each neuron dataset
                NeurnPerfVector_Bootstrpd=dataset(nan(size(cellNames,1),1),...
                    'VarNames', 'NeurnPerfVector_Bootstrpd');
                
            end
            
        else
            
            %create cell name dataset (NaN)
            CellName=dataset({NaN},'VarNames','CellName');
            
            %create information for each neuron dataset (NaN)
            NeurnInfoVector= dataset({NaN},...
                'VarNames','NeurnInfoVector');
            
            %create bootstrapped information for each neuron dataset
            %(NaN)
            NeurnInfoVector_Bootstrpd=dataset({NaN},...
                'VarNames', 'NeurnInfoVector_Bootstrpd');
            
            %create performance for each neuron dataset(NaN)
            NeurnPerfVector=dataset({NaN},...
                'VarNames','NeurnPerfVector');
            
            %create bootstrapped performance for each neuron
            %dataset(NaN)
            NeurnPerfVector_Bootstrpd=dataset({NaN},...
                'VarNames', 'NeurnPerfVector_Bootstrpd');
        end
    end
    
    
    if options.synred && options.bootstrapped
        
        tempdatasetadd{17}=dataset({synRed_between_bootsub,'SynRed_Bet_Hemi_Bootstrpd'});
        
        
        
        tempdatasetadd{5}=dataset({synRed_bootsub,...
            'Info_SingNeurn_Bootstrppd'});
        
        tempdatasetadd{6}=dataset({synRed_bootsub_zero,...
            'Info_SingNeurn_Bootstrppd_Corrctd'});
        
        
    end
    
    if ~strcmpi(options.firstspike,'all')
        tempdatasetadd{9}=dataset({I(k,[5,6,7]),[options.firstspike,'_Infoxspike'],[options.firstspike,'_Num'],[options.firstspike,'_NumTrials']});
        if options.bootstrapped
            tempdatasetadd{10}=dataset({I(k,8),'Bootstrap_Infoxspike'});
        end
    end
    
    if options.evchannels
        tempdatasetadd{11}=dataset({{options.evchannels},'EventNums'});
    end
    
    %     if ~isempty(errorCell)
    %         tempdatasetadd{12}=dataset({{errorCell},'Errors'});
    %     end
    %
    if isfield(options,'trials')
        
        if isfield(options, 'trialsWithinEvent') && options.trialsWithinEvent
            
            %"1" means trials selected within each event opposed to the
            %entire experiment
            tempdatasetadd{25}=dataset({{1},'Within_Evt_Flag'});
            
        end
        tempdatasetadd{14}=dataset({{options.trialsSelect(1)},'First_Trial'});
        tempdatasetadd{15}=dataset({{options.trialsSelect(end)},'Last_Trial'});
        
        
    end
    
    
    if isfield(options,'BMIkey') && ischar(options.BMIkey)
        
        %BMI Key column headers
        BMIKey_colhdrs=BMIKey_raw(1,:);
        
        %BMI Key Variable Columns
        [~,studyCol]=ismember('Study',BMIKey_colhdrs);
        [~,animalCol]=ismember('Animal',BMIKey_colhdrs);
        [~,hemispherelCol]=ismember('HemiType',BMIKey_colhdrs);
        [~,neuronTypeCol]=ismember('NeuronType',BMIKey_colhdrs);
        [~,animalGroupCol]=ismember('AnimalGroup',BMIKey_colhdrs);
        [~,learnCol]=ismember('P+',BMIKey_colhdrs);
        [~,finExptCol]=ismember('Completed ',BMIKey_colhdrs);
        [~,neuronType_CodeCol]=ismember('NeuronType_Code',BMIKey_colhdrs);
        [~,neuronGroup_CodeCol]=ismember('NeuronGroup_Code',BMIKey_colhdrs);
        [~,animalGroup_CodeCol]=ismember('AnimalGroup_Code',BMIKey_colhdrs);
        
        
        %Filename columns
        [~,studyCol_file]=ismember('study',fields);
        [~,expCol_file]=ismember('exp',fields);
        [~,dayCol_file]=ismember('day',fields);
        [~,dateCol_file]=ismember('date',fields);
        [~,animalCol_file]=ismember('animal',fields);
        
        %Extract relevant row from BMIKey
        BMIKey_mask=[false;ismember(BMIKey_raw(2:end,studyCol),values(studyCol_file)) &...
            logical(ismember([BMIKey_raw{2:end,animalCol}],str2double(values(animalCol_file))))' &...
            ismember(BMIKey_raw(2:end,hemispherelCol),{options.regionname})];
        
        
        
        tempdatasetadd{18}=dataset({BMIKey_raw(BMIKey_mask,neuronTypeCol),'NeuronType'});
        
        tempdatasetadd{19}=dataset({BMIKey_raw(BMIKey_mask,animalGroupCol),'AnimalGroup'});
        
        tempdatasetadd{20}=dataset({BMIKey_raw(BMIKey_mask,learnCol),'P+'});
        
        tempdatasetadd{21}=dataset({BMIKey_raw(BMIKey_mask,finExptCol),'Completed'});
        
        tempdatasetadd{22}=dataset({BMIKey_raw(BMIKey_mask,neuronType_CodeCol),'neuronType_Code'});
        
        tempdatasetadd{23}=dataset({BMIKey_raw(BMIKey_mask,neuronGroup_CodeCol),'neuronGroup_Code'});
        
        tempdatasetadd{24}=dataset({BMIKey_raw(BMIKey_mask,animalGroup_CodeCol),'animalGroup_Code'});
        
        
    end
    
    
end

for i=1:length(tempdatasetadd)
    if ~isempty(tempdatasetadd{i})
        tempdataset=cat(2,tempdataset,tempdatasetadd{i});
    end
end

if options.expandedformat
    
    %repeat tempdataset for each neuron if user wants long format (only if
    %analysis for individual neurons performed)
    if isnan(NeurnInfoVector{1,1})
        repeatedMatrix=tempdataset;
        
    else
        repeatedMatrix=repmat(tempdataset,length(NeurnInfoVector),1);
        
    end
    
    tempdataset=[repeatedMatrix,CellName,NeurnInfoVector,NeurnInfoVector_Bootstrpd,...
        NeurnPerfVector,NeurnPerfVector_Bootstrpd];
    
end
%   tempdataset_cell=dataset2cell(tempdataset);
if isempty(outdataset)
    outdataset=tempdataset;
    
    
else
    
    % if new tempdataset missing columns
    if size(outdataset,2)>size(tempdataset,2)
        
        missingCols=size(outdataset,2)-size(tempdataset,2);
        missingDataSet=outdataset(1,end-missingCols+1:end);
        tempdataset=[tempdataset,missingDataSet];
    end
    
    outdataset=cat(1,outdataset,tempdataset);
    
end







function oldcode
bin_vect=str2num(get(handles.ed_bin_vect,'string'));
time_window=str2num(get(handles.ed_time_window,'string'));
El{1,1}=get(handles.ed_el1_name,'string');
El{2,1}=get(handles.ed_el2_name,'string');
El{3,1}=get(handles.ed_el3_name,'string');
El{4,1}=get(handles.ed_el4_name,'string');
El{1,2}=str2num(get(handles.ed_el1_sel,'string'));
El{2,2}=str2num(get(handles.ed_el2_sel,'string'));
El{3,2}=str2num(get(handles.ed_el3_sel,'string'));
El{4,2}=str2num(get(handles.ed_el4_sel,'string'));
to_el=cellfun(@isempty,El);
[row,col]=find(to_el==1);
El(unique(row),:)=[];
waitbar_handle = waitbar(0,'please wait...');

try
    
    directory=get(handles.tx_loaded_file,'string');
    dirstruct=dir(([directory,'\Matlab files\*struct*.mat']));
    
    if isempty(dirstruct)
        dirstruct=dir(([directory,'\*struct*.mat']));
        if ~isdir(directory)
            handles.file=directory;
        else
            handles.file=[directory,'\',dirstruct(1).name];
        end
    else
        handles.file=[directory,'\Matlab files\',dirstruct(1).name];
    end
    data=load(handles.file);
    directory=data.directory;
    data=data.data;
    data.directory=directory;
    
    
    
    
catch
    
    errordlg('No files imported, please hit cancel and re-import the files');
    
    close(waitbar_handle);
    return
end

try
    mkdir([directory,'\PSTH Analysis',get(handles.ed_sav_dir,'string'),'\',locnames{loc},'\']);
catch
    pos=find(handles.file=='\');
    directory=handles.file(1:pos(end-1)-1);
    data.directory=directory;
    if isempty(dir([directory,'\PSTH Struct.*']))
        mkdir([directory,'\PSTH struct\']);
        copyfile(handles.file,[directory,'\PSTH struct\']);
    else
    end
    
end
assignin('base','PSTH_class_raw_data',data);
clear data;
warning off MATLAB:xlswrite:AddSheet
savedir=[directory,'\PSTH Analysis','\'];
mkdir(savedir);
% flag
if get(handles.rb_usecons,'value')
    inclusion=1;
    usefile='R:\Metha data Analysis\PSTH Analysis\allrespcells\inclusionallanimals.xls';
else
    usefile='';
    inclusion=0;
end

data=evalin('base','PSTH_class_raw_data');
locations=get(handles.lb_locations,'value');


% locations=[1 3];
% if get(handles.lb_dir,'value')==98
%     locations=[1 2];
% end

data.filenum=length(locations);
data.files=data.files(locations);
data.anfiles=data.anfiles(locations);
data.numstimuli=data.filenum;
[PeriEventMatrixAll,Group_select]=interface_class(data,1,time_window...
    ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
if nargin>3
    if length(filelist)>1
        for i=2:length(filelist)
            data=load(filelist{i});
            directory=data.directory;
            data=data.data;
            data.directory=directory;
            [PeriEventMatrixAlltemp,Group_selecttemp]=interface_class(data,1,time_window...
                ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
            for j=1:length(PeriEventMatrixAll)
                PeriEventMatrixAll{j}=cat(1,PeriEventMatrixAll{j},PeriEventMatrixAlltemp{j});
                
            end
            Group_select=cat(2,Group_select,Group_selecttemp);
        end
    end
    [FileName,PathName] = uigetfile(['*.*']);
    load([PathName,FileName]);
    cl=length(conditions);
    for cond=1:cl
        for j=1:size(El,1);
            Eln{(cond-1)*cl+j,1}=[El{j,1},'_',conditions{1,cond}];
            Eln{(cond-1)*cl+j,2}=El{j,2};
            PeriEventMatrixAlln{(cond-1)*cl+j}=PeriEventMatrixAll{j}(logical(conditions{2,cond}),:);
            Group_selectn{(cond-1)*cl+j}=Group_select(logical(conditions{2,cond}));
        end
    end
    El=Eln;
    PeriEventMatrixAll=PeriEventMatrixAlln;
    Group_select=Group_selectn;
end


duration=time_window(2)-time_window(1);
for i=1:length(bin_vect)
    fprintf('\n Executing analysis for binsize %2.0f  \n',bin_vect(i));
    ConfusionMatrix_sav={};
    I{1,3}='Cells number';
    I{1,2}='Electrode';
    I{1,i+3}=[num2str(bin_vect(i)),' ms'];
    for j=1:size(El,1);
        Neurons=size(PeriEventMatrixAll{j},2)/duration;
        if Neurons~=0
            bin_matr=create_binmatr(bin_vect(i),duration,Neurons);
            PeriEventMatrixAll_curr=PeriEventMatrixAll{j}*bin_matr;
            if iscell(Group_select)
                Group_select_curr=Group_select{j};
            else
                Group_select_curr=Group_select;
            end
            [Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PeriEventMatrixAll_curr...
                ,Group_select_curr,'Euclidean',[],0,0,0,0,1,0);
        else
            ConfusionMatrix=zeros(10);
            
        end
        I{(j)+1,1}=['Electrode ',num2str(j)];
        I{(j)+1,2}=El{j,1};
        I{(j)+1,3}=Neurons;
        I{(j)+1,i+3}=I_confmatr(ConfusionMatrix);
        tot_perf{(j)+1,i+3}=sum(diag(ConfusionMatrix))/size(ConfusionMatrix,1);
        fprintf('\n Analysis performed on Electrode %1.0f  \n',j);
        ConfusionMatrix_tmp=mat2cell(ConfusionMatrix,ones(1,size(ConfusionMatrix,1)),ones(1,size(ConfusionMatrix,1)));
        toprow=cell(1,size(ConfusionMatrix_tmp,2));
        toprow(1,1:2)=I((j)+1,1:2);
        ConfusionMatrix_tmp=[toprow;ConfusionMatrix_tmp];
        ConfusionMatrix_sav=[ConfusionMatrix_sav;ConfusionMatrix_tmp];
        
        
    end
    g=max(find(directory=='\'));
    name='';
    name=[directory(g+1:length(directory)),'_',date];
    ConfusionMatrix_cell{i}=ConfusionMatrix_sav;
    %     xlswrite([savedir,'classresults_',name,'.xls'],ConfusionMatrix_sav,...
    %         ['ConfusionMatrix_binsize=',num2str(bin_vect(i))]);
    fprintf('\n Analysis for binsize %2.0f completed \n',bin_vect(i));
    waitbar(i/length(bin_vect),waitbar_handle);
end
tot_perf(1,:)=I(1,:);
tot_perf(:,1:3)=I(:,1:3);
tot_perf{1,1}='total % of correct';
tot_perf(:,1:3)=[];
I=cat(2,I,tot_perf);
%I(:,length(bin_vect)+2+1:length(bin_vect)+2+2)=[];
I{1,1}='Information in bits';
pause(5)
xlswrite([savedir,'classresults_',name,'.xlsx'],I,'Information');
savefile=[savedir,'classresults_',name,'.mat'];
save(savefile,'Class','ConfusionMatrix_cell','I');
assignin('base','PSTH_analysis_results',I);
close(waitbar_handle);
warning on MATLAB:xlswrite:AddSheet

fprintf('\n Analysis has been performed without errors \n');
locI=I;
locI(:,3)=[];
locI(:,1)=[];

for i=2:size(locI,1)
    fields={};
    values={};
    
    for j=1:length(locations)
        filenamean=data.anfiles{j};
        format=get(handles.ed_nameformat,'string');
        [fieldstemp,valuestemp]=get_file_info(filenamean,format);
        fields=cat(2,fields,cellfun(@cat,num2cell(ones(size(fieldstemp))*2),...
            repmat({['LOC',num2str(locations(j)),'_']},...
            1,size(fieldstemp,2)),fieldstemp,'uniformoutput',false));
        values=cat(2,values,valuestemp);
    end
    infos(i,:)=values;
end
infos(1,:)=fields;
locI(1,end+1)={'Locations'};
locI(2:end,end)={length(locations)};
cols=size(locI,2);
rows=size(locI,1);
locI=cat(2,locI,infos);
locI(1,cols+1)={'Directory'};
locI(2:rows,cols+1)={directory};

studyfile=get(handles.ed_studyfile,'string');
[pathname,filename]=fileparts(studyfile);
if isempty(studyfile)
    
else
    if ispc
        try
            
            [a,b,values]=xlsread(studyfile,'study');
            locI(1,:)=[];
            cols=size(values,2);
            if cols~=size(locI,2)
                locI{1,cols}=nan;
            end
            locI=cat(1,values,locI);
            xlswrite(studyfile,locI,'study');
        catch
            xlswrite(studyfile,locI,'study');
        end
    end
    try
        
        load([filename,pathname,'.mat']);
        PSTHStudy=cat(1,PSTHStudy,locI(2:end,:));
        save([pathname,'\',filename,'.mat'],...
            'PSTHStudy','-append')
    catch
        PSTHStudy=locI;
        save([pathname,'\',filename,'.mat'],...
            'PSTHStudy');
    end
    
    
end
