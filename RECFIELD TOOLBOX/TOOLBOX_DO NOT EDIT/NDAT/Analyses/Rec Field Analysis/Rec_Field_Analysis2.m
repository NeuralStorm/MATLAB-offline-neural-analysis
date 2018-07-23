function [outdataset,NumCells,NumResp,popPSTH,popPEM]=Rec_Field_Analysis(filenames,options)

% options.pretime=0.1;
% options.posttime=0.1;
% options.bin=0.001;
% options.intervals={'quiet','whisking'};
% options.region={16:32};
% options.regionname={'CTX'};
% options.binsizean=[1 2 4 8 10 20 40]/1000;
% options.fileinfostring='date_animal_exp_exp_';



if isfield(options,'wires')
else
    options.wires=0;
end
if isfield(options,'intervals')
    
else
    intervals=1;
    
end
if isfield(options,'RM')
    
else
    options.RM=0;
    
end
% if isfield(options,'TILT')
% else
%     options.TILT = 0;
% end
if isfield(options,'explab')
else
    options.explab='file';
end
if isfield(options,'timewindow')
else
    options.timewindow=options.posttime;
end
if isfield(options,'singlecellsinfo')
    options.singlecellsinfo=1;
    if isfield(options,'singlecellsinfotype')
        
    else
        options.singlecellsinfotype={'Count','Timing'};
    end
    if isfield(options,'singlecellsinfotimewindow')
        
    else
        options.singlecellsinfotimewindow=options.timewindow;
    end
    if isfield(options,'stimnostim')
    else
        options.stimnostim=0;
    end
else
    options.singlecellsinfo=0;
    
end

if isfield(options,'enwindow')
else
    options.enwindow=max(options.timewindow);
end

%%temp file for resuming analysis

dt = datestr(now, 'mm_dd_yyyy')
options.tempdirectory=[dt,'RecFieldTempData_0']
if exist([pwd,filesep,options.tempdirectory])
    numdirs=length(dir(['*',options.tempdirectory(1:end-3),'*']));
    options.tempdirectory=[options.tempdirectory(1:end-1),num2str(numdirs)]
end
mkdir(options.tempdirectory);
cd(options.tempdirectory)
options.tempfilename=[dt,'TempRecField_0001'];
save(options.tempfilename,'options')
cd('..')


save('temp','-struct','options');
load temp;
outdataset=[];
cont=1;
firstit=1;
tcont=1;
fromfile=0;
for f=1:length(filenames)
    filename=filenames{f};
    options.filename=filenames{f};
    [d,fp]=fileparts(options.filename);
    clc
    fprintf('File: %s \n',fp)
    
    if strcmpi(options.explab,'file') || fromfile==1
        try
            load(filename,'Explab','-mat');
            options.explab=Explab;
            fromfile=1;
        end
    end
    for r=1:length(region)
        for i=1:length(intervals)
            if iscell(intervals)
                options.intervals=intervals(i);
                
            end
            options.regionname=regionname{r};
            options.region=region{r};
            if length(intervals)~=1
                fprintf('Interval: %s \n',options.intervals{:})
            end
            for b=1:length(binsizean)
                
                
                
                
                options.bin=binsizean(b);
                tic
                [PEHM,options]=PEHMFromMatnd(filename,options);
                
           load(filename,'-mat');
           if length(Channels)<=16
                    
                [UnitFiringRateRegion1] = BackgroundFiringRate(filename);
                
           else
               [UnitFiringRateRegion1,UnitFiringRateRegion2] = BackgroundFiringRate(filename);
           
           end
%                 if options.TRM    %%Nate added this part %%%%%%%%%
%                  BackgroundFiringRates=cat(2,UnitFiringRateRegion1,UnitFiringRateRegion2)   %%Nate added this part %%%%%%%%%
%                 else    %%Nate added this part %%%%%%%%%
                if r == 1
                    BackgroundFiringRates = UnitFiringRateRegion1;
                elseif r ==2
                    BackgroundFiringRates = UnitFiringRateRegion2;
                end
                %end     %%Nate added this part %%%%%%%%%
                NumCells(f) = size(PEHM,2);
                % Added to include Background Firing Rate from entire
                % recording
                
               
                
                                         
                %end addition 
                toc
                PEHM(isnan(PEHM(:)))=0;
                %disp('done PEHM');
                if options.singlecellsinfo
                    [PEHMClass1,Group]=PEHMClassFromMatnd(filename,options);
                    cd(tempdirectory)
                    
                    
                    popPEM{cont,1}=PEHMClass1;
                    popPEM{cont,2}=Group;
                    popPEM{cont,3}=options;
                    try
                        save(options.tempfilename,'popPEM','-append');
                    catch
                        save(options.tempfilename,'popPEM');
                    end
                    cd('..')
                end
                popPSTH{cont,1}=PEHM;
                popPSTH{cont,2}=options;
                
                cd(tempdirectory)
                if cont~=1
                    save(options.tempfilename,'popPSTH');
                else
                    save(options.tempfilename,'popPSTH','-append');
                end
                cd('..')
                
                for t=options.enwindow
                    options.timewindow=[min(options.timewindow):t];
                    options.singlecellsinfotimewindow=options.timewindow;
                    
                    fprintf('Timewindow: %3.0f \n',t)
                    
                    
                    
                    
                    
                    
                    
                    
                    if 0
                        subplot(1,3,1)
                        L1PSTH=PEHM([options.base,options.response],:,1);
                        pcolor(L1PSTH./repmat(max(L1PSTH),size(L1PSTH,1),1))
                        subplot(1,3,2)
                        L2PSTH=PEHM([options.base,options.response],:,2);
                        pcolor(L2PSTH./repmat(max(L2PSTH),size(L2PSTH,1),1))
                        subplot(1,3,3)
                        L3PSTH=PEHM([options.base,options.response],:,3);
                        pcolor(L3PSTH./repmat(max(L3PSTH),size(L3PSTH,1),1))
                        colormap(bone)
                    end
                    if options.RM==0
                        NormRFMatrix2D=[];
                        if isempty(PEHM)~=1
                            if isfield(options,'TRM')
                                
                                if options.TRM
                                    %load(filename,'-mat','Channels','Events');
                                    %FiringRates = CellMeanFiringRate(Channels,Events) ;
                                    [NormRFMatrix2D]=receptive_field_TRM(PEHM,options,BackgroundFiringRates);
                                else
                                    [NormRFMatrix2D]=receptive_field(PEHM,options);
                                end
                            elseif isfield(options,'TILT')
                                if options.TILT
                                    [NormRFMatrix2D]=receptive_field_TILT(PEHM,options);
                                else
                                    [NormRFMatrix2D]=receptive_field(PEHM,options);
                                end
                            elseif isfield(options,'Press')
                                if options.Press
                                    [NormRFMatrix2D]=receptive_field_Press(PEHM,options);
                                else
                                    [NormRFMatrix2D]=receptive_field(PEHM,options);
                                end
                            else
                                [NormRFMatrix2D]=receptive_field(PEHM,options);
                            end
                        end
                    else
                        NormRFMatrix2D=calculate_RM(PEHM,options);
                    end
                    %disp('done RecField');
                    if ~isempty(NormRFMatrix2D)
                        toutdataset=createdataset(filename,NormRFMatrix2D,options,[]);
%                         T = toutdataset(strcmp(toutdataset.LocName,'Chime'),:);
%                         T(strcmp(T.PRFName,'PreChime'),:)=[];
%                         NumResp(f) = size(T,1);
                    else
                        toutdataset=[];
                    end
                    if options.singlecellsinfo
                        [Infores,Jitter,firstspdist]=EstimateInfo(PEHMClass1,Group,options);
                        %disp('done Info');
                        toutdataset=addinfotodataset(filename,toutdataset,Infores,Jitter,firstspdist,options);
                    end
                    
                    
                    cd(options.tempdirectory)
                    %                     load(tempfilename,'outdataset');
                    outdataset=toutdataset;
                    try
                        save(options.tempfilename,'outdataset','options','-append');
                    catch
                        save(options.tempfilename,'outdataset');
                    end
                    tcont=1+tcont;
                    pos=max(regexpi(options.tempfilename,'_'));
                    options.tempfilename=sprintf([options.tempfilename(1:pos),'%04.0f'],tcont);
                    clear outdataset
                    cd('..')
                    
                    
                    
                end
                
                cont=cont+1;
            end
        end
    end
end
options.tempfilename=[dt,'TempRecField'];
cd(options.tempdirectory)
a=dir('*.mat');
x=load(a(1).name);
for f=2:length(a)
    
    y=load(a(f).name);
    finf=fields(y);
    for fi=1:length(finf)
        try
        x.(finf{fi})=cat(1,x.(finf{fi}),y.(finf{fi}));
        catch
        x.(finf{fi})=x.(finf{fi}); % changed by anitha
        end
    end
end

save(options.tempfilename,'-struct','x');
outdataset=x.outdataset;
cd('..')
% rmdir(options.tempdirectory);

function outdataset=addinfotodataset(filename,outdataset,Infores,Jitter,firstspdist,options)
rows=size(Infores,1);
[fields,values]=get_file_info(filename,options.explab);
for i=1:length(fields)
    fileinfos{i}={repmat({values{i}},rows,1),fields{i}};
end
tempdataset=dataset({Infores(:,[1,2,7,8,11,12,3,4]),'Count','Timing',...
    'Countsh','Timingsh','Countsnb','Timingnb','Channel','Unit' },{repmat({options.regionname},...
    rows,1),'RegionOrElectrode'},{repmat(options.bin,rows,1),'Binsize'}...
    ,fileinfos{:});
if options.stimnostim
    adddataset=dataset({Infores(:,[5:6,9,10,13,14]),'CountAllStimvsBack',...
        'TimingAllStimvsBack','CountAllStimvsBacksh',...
        'TimingAllStimvsBacksh','CountAllStimvsBacknb',...
        'TimingAllStimvsBacknb'});
    tempdataset=cat(2,tempdataset,adddataset);
end
outdataset = join(outdataset,tempdataset,...
    'key',{'animal','date','Channel','Unit'},...
    'Type','inner','MergeKeys',true);


rows=size(Jitter,1);
for i=1:length(fields)
    fileinfos{i}={repmat({values{i}},rows,1),fields{i}};
end
tempdatasetJ=dataset({Jitter(:,[1:5]),'LatFs','Jitter','Stimulus'...
    'Channel','Unit', },{repmat({options.regionname},...
    rows,1),'RegionOrElectrode'},{repmat(options.bin,rows,1),'Binsize'}...
    ,fileinfos{:},{firstspdist','Firstspikedist'});
tempdatasetJ(:,3)=dataset({options.evnames(tempdatasetJ.Stimulus)','Stimulus'});
if options.stimnostim
    adddataset=dataset({Jitter(:,[6,7,10,11,12,13,8,9,14:21]),'CountsingleStimvsBack',...
        'TimingsingleStimvsBack','CountsingleStimvsBacksh',...
        'TimingsingleStimvsBacksh','CountsingleStimvsBacknb',...
        'TimingsingleStimvsBacknb','R_NsCount','R_NsTiming',...
        'T_Count','EstNR_Count','UR_Count',...
        'T_Timing','EstNR_Timing','UR_Timing','Numzerotrial','Ratiozerotrials'});
    tempdatasetJ=cat(2,tempdatasetJ(:,1:end-1),adddataset,tempdatasetJ(:,end));
end
outdataset = join(outdataset,tempdatasetJ,...
    'key',{'animal','date','Channel','Unit','Stimulus'},...
    'Type','inner','MergeKeys',true);



function [Infores,Jitter,firstspdist]=EstimateInfo(PEHMClass1,Group,options)
Jitter=[];
calcinfo=options.calcinfo;
bins=options.pretime/options.bin+options.posttime/options.bin+1;
Neurons=size(PEHMClass1,2)/bins;
S=length(unique(Group));
Groupold=Group;
for n=1:Neurons
    Group=Groupold;
    currNeur=PEHMClass1(:,(n-1)*bins+options.singlecellsinfotimewindow);
    
    bin_matr=create_binmatr(options.timingbinsize,size(currNeur,2),1);
    currNeur=currNeur*bin_matr;
    sc=1;
    PEM=[];
    for s=reshape(unique(Group),1,[])
        opt.nt(sc)=sum(Group==s);
        PEM(1:opt.nt(sc),:,sc)=currNeur(Group==s,:);
        sc=sc+1;
    end
    totnt=opt.nt;
    opt.method='dr';
    opt.bias='pt';
    term={'HR','HRS','HshRS','HiRS','HshR','HlR'};
    if options.temporalinfo==1
        
        for s=1:S
            PEMss{s}=PEM(:,:,s);
            [i]=find(PEMss{s}~=0);
            [i,j,k]=ind2sub(size(PEMss{s}),i);
            
            x{s}=logical(hist(i,1:size(PEMss{s},1)));
            PEMss{s}(~x{s},:)=[];
            T(s)=size(PEMss{s},1);
        end
        xl=[];
        PEMn=[];
        for s=1:S
            PEMn(1:T(s),:,s)=PEMss{s};
            xl=[xl,~x{s}(1:opt.nt(s))];
        end
        Group(logical(xl))=nan;
        PEM=PEMn;
        opt.nt=T;
        %         currNeur=[];
        %         if isempty(PEM)
        %             currNeur=[];
        %         else
        %             for s=1:S
        %                 currNeur=[currNeur;PEM(1:T(s),:,s)];
        %             end
        %         end
    end
    if sum(strcmpi(options.singlecellsinfotype,'Count'))
        %calculating count info
        R=permute(sum(PEM,2),[2 1 3]);
        %opt.nt=size(PEM,1);
        
        opt.btsp=options.infobtsp;
        if calcinfo && ~isempty(R)
            [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                entropy(R,opt,term{:});
        else
            HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
        end
        Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
        Ish=HR-HiRS+HshRS-HRS;
        Infores(n,1)=Ishush(1)-mean(Ishush(2:end));
        Infores(n,7)=Ish(1)-mean(Ish(2:end));
        Infores(n,11)=Ishush(1);
        if options.stimnostim
            oldnt=opt.nt;
            currNeurnBT=[];
            h=1;
            for s=reshape(unique(Groupold),1,[])
                baseline=options.singlecellsinfotimewindow-sum(minmax(options.singlecellsinfotimewindow)-100);
                currNeurnB=PEHMClass1(Group==s,(n-1)*bins+baseline)*bin_matr;
                currNeurnS=PEHMClass1(Group==s,(n-1)*bins+options.singlecellsinfotimewindow)*bin_matr;
                opt.nt=size(currNeurnB,1);
                if isempty(currNeurnS)
                    R=[];
                else
                    PEMSnS=cat(3,full(currNeurnS),full(currNeurnB));
                    currNeurnBT=cat(1,currNeurnBT,currNeurnB);
                    R=permute(sum(PEMSnS,2),[2 1 3]);
                end
                
                if calcinfo && ~isempty(R)
                    [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                        entropy(R,opt,term{:});
                else
                    HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
                end
                Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
                Ish=HR-HiRS+HshRS-HRS;
                InforesSnS((n-1)*S+h,1)=Ishush(1)-mean(Ishush(2:end));
                InforesSnS((n-1)*S+h,8)=Ish(1)-mean(Ish(2:end));
                InforesSnS((n-1)*S+h,[4,5])=options.anchan(n,:);
                InforesSnS((n-1)*S+h,3)=s;
                InforesSnS((n-1)*S+h,17)=length((unique(R(:,:,1)','rows')));
                if isempty(R)
                    R=nan;
                end
                InforesSnS((n-1)*S+h,6)=opt.nt/(max(R(:,:,1))'+1);
                InforesSnS((n-1)*S+h,10)=Ishush(1);
                InforesSnS((n-1)*S+h,15)=opt.nt;
                InforesSnS((n-1)*S+h,16)=(max(R(:,:,1))'+1);
                % trials with zeros
                InforesSnS((n-1)*S+h,21)=totnt(s)-opt.nt;
                InforesSnS((n-1)*S+h,22)=InforesSnS((n-1)*S+h,21)/totnt(s);
                h=h+1;
            end
            if isempty(currNeurnBT)
                R=[];
            else
                opt.nt=[sum(oldnt),size(currNeurnBT,1)];
                PEMt=cat(3,full(currNeur(~isnan(Group),:)),full(currNeurnBT));
                R=permute(sum(PEMt,2),[2 1 3]);
            end
            
            if calcinfo && ~isempty(R)
                [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                    entropy(R,opt,term{:});
            else
                HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
            end
            Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
            Ish=HR-HiRS+HshRS-HRS;
            
            Infores(n,5)=Ishush(1)-mean(Ishush(2:end));
            Infores(n,9)=Ish(1)-mean(Ish(2:end));
            Infores(n,13)=Ishush(1);
            opt.nt=oldnt;
        end
        
    end
    if sum(strcmpi(options.singlecellsinfotype,'Timing'))
        %calculating Timing info
        
        if options.temporalinfo
            PEM=extract_1stspike(PEM);
            size(PEM,1);
        end
        R=permute(PEM,[2 1 3]);
        %opt.nt=size(PEM,1);
        
        opt.btsp=options.infobtsp;
        
        try
            if calcinfo && ~isempty(R)
                [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                    entropy(R,opt,term{:});
            else
                HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
            end
            Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
            Ish=HR-HiRS+HshRS-HRS;
        catch
            I=nan;
        end
        Infores(n,2)=Ishush(1)-mean(Ishush(2:end));
        Infores(n,8)=Ish(1)-mean(Ish(2:end));
        Infores(n,12)=Ishush(1);
        if options.stimnostim
            oldnt=opt.nt;
            currNeurnBT=[];
            h=1;
            for s=reshape(unique(Groupold),1,[])
                baseline=options.singlecellsinfotimewindow-sum(minmax(options.singlecellsinfotimewindow)-100);
                currNeurnB=PEHMClass1(Group==s,(n-1)*bins+baseline)*bin_matr;
                currNeurnS=PEHMClass1(Group==s,(n-1)*bins+options.singlecellsinfotimewindow)*bin_matr;
                opt.nt=size(currNeurnB,1);
                if isempty(currNeurnS)
                    R=[];
                else
                    PEMSnS=cat(3,full(currNeurnS),full(currNeurnB));
                    currNeurnBT=cat(1,currNeurnBT,currNeurnB);
                    R=permute(PEMSnS,[2 1 3]);
                end
                try
                    if calcinfo && ~isempty(R)
                        [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                            entropy(R,opt,term{:});
                    else
                        HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
                    end
                    Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
                    Ish=HR-HiRS+HshRS-HRS;
                catch
                    I=nan;
                end
                InforesSnS((n-1)*S+h,2)=Ishush(1)-mean(Ishush(2:end));
                InforesSnS((n-1)*S+h,20)=length((unique(R(:,:,1)','rows')));
                if isempty(R)
                    R=nan;
                end
                InforesSnS((n-1)*S+h,[7])=opt.nt/prod(max(R(:,:,1)')+1);
                InforesSnS((n-1)*S+h,9)=Ish(1)-mean(Ish(2:end));
                InforesSnS((n-1)*S+h,11)=Ishush(1);
                InforesSnS((n-1)*S+h,18)=opt.nt;
                InforesSnS((n-1)*S+h,19)=prod(max(R(:,:,1)')+1);
                h=h+1;
            end
            if isempty(currNeurnBT)
                R=[];
            else
                opt.nt=[sum(oldnt),size(currNeurnBT,1)];
                PEMt=cat(3,full(currNeur(~isnan(Group),:)),full(currNeurnBT));
                R=permute(PEMt,[2 1 3]);
            end
            try
                if calcinfo && ~isempty(R)
                    [HR,HRS,HshRS,HiRS,HshR,HlR]=...
                        entropy(R,opt,term{:});
                else
                    HR=0;HRS=0;HshRS=0;HiRS=0;HshR=0;HlR=0;
                end
                Ishush=HR-HshR+HlR-HiRS+HshRS-HRS;
                Ish=HR-HiRS+HshRS-HRS;
            catch
                I=nan;
            end
            Infores(n,6)=Ishush(1)-mean(Ishush(2:end));
            Infores(n,10)=Ish(1)-mean(Ish(2:end));
            Infores(n,14)=Ishush(1);
            opt.nt=oldnt;
        end
        %calculating Jitter
        h=1;
        
        for s=reshape(unique(Groupold),1,[])
            currNeurStim=currNeur(Group==s,:);
            latfs=nan;
            for t=1:size(currNeurStim,1)
                fs=min(options.timewindow-options.pretime/options.bin)+...
                    min(find(currNeurStim(t,:)~=0));
                if isempty(fs)
                    latfs(t)=nan;
                else
                    latfs(t)=fs;
                end
            end
            firstspdist{(n-1)*S+h}=latfs;
            Jitter((n-1)*S+h,1)=nanmean(latfs);
            Jitter((n-1)*S+h,2)=nanstd(latfs);
            Jitter((n-1)*S+h,3)=s;
            Jitter((n-1)*S+h,[4,5])=options.anchan(n,:);
            
            h=h+1;
        end
    end
    Infores(n,[3,4])=options.anchan(n,:);
    
    fprintf('Information done for unit: %2.0f %2.0f and min numbers of trials were: %2.0f \n',options.anchan(n,1),options.anchan(n,2),min(oldnt))
end
Infores(isnan(Infores))=0;
InforesSnS(isnan(InforesSnS))=0;
if exist('Jitter')
    if exist('InforesSnS')
        Jitter=cat(2,Jitter,InforesSnS(:,[1,2,6,7,8,9,10,11,15:22]));
        
    end
    
elseif exist('InforesSnS')
    Jitter=InforesSnS;
end
function [NormRFMatrix2D]=receptive_field(PEHM,options)
options.pretime=options.pretime*1/options.bin;
options.posttime=options.posttime*1/options.bin;
ReceptiveFieldMatrix=receptivefield(PEHM,options.bin,...
    options.pretime, options.posttime, options.base,...
    options.response,'n',num2str([1:128]'),...
    options.pvalue, 0);
[NormRFMatrix2D]=receptivehistogram(ReceptiveFieldMatrix, 'prf');
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),1);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),2);
NormRFMatrix2D(:,10)=[];
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,2)-NormRFMatrix2D(:,7).*1000.*...
    (NormRFMatrix2D(:,5)-NormRFMatrix2D(:,4));
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,3)-NormRFMatrix2D(:,7);

%NormRFMatrix2D(:,9)=options.evnames(NormRFMatrix2D(:,9));

function [NormRFMatrix2D]=receptive_field_TRM(PEHM,options,BackgroundFiringRates)

NormRFMatrix2D = recfield_TRM(PEHM,options,BackgroundFiringRates);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),1);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),2);
NormRFMatrix2D(:,10)=[];
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,2)-(NormRFMatrix2D(:,7)/1000).*1/options.bin.*...
    (NormRFMatrix2D(:,5)-NormRFMatrix2D(:,4));
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,3)-NormRFMatrix2D(:,7)/1000;

function [NormRFMatrix2D]=receptive_field_TILT(PEHM,options)

NormRFMatrix2D = recfield_TILT_Nate(PEHM,options);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),1);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),2);
NormRFMatrix2D(:,10)=[];
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,2)-NormRFMatrix2D(:,7).*1/options.bin.*...
    (NormRFMatrix2D(:,5)-NormRFMatrix2D(:,4));
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,3)-NormRFMatrix2D(:,7);

function [NormRFMatrix2D]=receptive_field_Press(PEHM,options)

NormRFMatrix2D = recfield_Press(PEHM,options);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),1);
NormRFMatrix2D(:,end+1)=options.anchan(NormRFMatrix2D(:,10),2);
NormRFMatrix2D(:,10)=[];
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,2)-NormRFMatrix2D(:,7).*1/options.bin.*...
    (NormRFMatrix2D(:,5)-NormRFMatrix2D(:,4));
NormRFMatrix2D(:,end+1)=NormRFMatrix2D(:,3)-NormRFMatrix2D(:,7);

function outdataset=createdataset(filename,...
    NormRFMatrix2D,options,outdataset)

[fields,values]=get_file_info(filename,options.explab);

rows=size(NormRFMatrix2D,1);
for i=1:length(fields)
    fileinfos{i}={repmat({values{i}},rows,1),fields{i}};
end
if options.RM==0
    tempdataset=dataset({NormRFMatrix2D,'NormResponse',' Response',...
        ' Peak', 'FirstBinLatency','LastBinLatency','PeakLatency',...
        'BackgroundFiringRate','BackgroundAvg', 'LocNum',...
        'PRFNum','RFS','Channel','Unit','RM_BS','Peak_BS' },{repmat({options.regionname},...
        rows,1),'RegionOrElectrode'},{repmat(options.bin,rows,1),'Binsize'}...
        ,fileinfos{:},{repmat(max(options.timewindow),rows,1),'Timewindow'});
    
else
    tempdataset=dataset({NormRFMatrix2D,'NormResponse',' Response',...
        ' Peak','PeakLatency','RM_BS','Peak_BS','BackgroundAvg','BackgroundSTD'...
        ,'Loc','Channel','Unit'},{repmat({options.regionname},...
        rows,1),'RegionOrElectrode'},{repmat(options.bin,rows,1),'Binsize'}...
        ,fileinfos{:},{repmat(max(options.timewindow),rows,1),'Timewindow'});
end

tempdataset=cat(2,tempdataset,dataset({reshape(options.EvTrials(tempdataset.LocNum),[],1),'LocTrials'}));
tempdataset=cat(2,tempdataset,dataset({reshape(options.evnames(tempdataset.LocNum),[],1),'LocName'}));
tempdataset=cat(2,tempdataset,dataset({reshape(options.evnames(tempdataset.PRFNum),[],1),'PRFName'}));
for i=1:size(tempdataset,1)
    if iscell(tempdataset.LocName{i})
        evs=tempdataset.LocName{i};
        tempdataset.LocName{i}=[evs{:}];
    end
    if iscell(tempdataset.PRFName{i})
        evs=tempdataset.PRFName{i};
        tempdataset.PRFName{i}=[evs{:}];
    end
end

if isfield(options,'intervals')
    datasetadd=dataset({repmat(options.intervals,rows,1),'Intervals'});
    tempdataset=cat(2,tempdataset,datasetadd);
end

%inserting cellname
for i=1:size(tempdataset,1)
    cellname{i,1}=['sig',sprintf('%03.0f',tempdataset.Channel(i)),...
        char(tempdataset.Unit(i)+96)];
end
datasetadd=dataset({cellname,'CellName'});
tempdataset=cat(2,tempdataset,datasetadd);

outdataset=tempdataset;
%finding ipsi contra
if isfield(options,'IpsiContra')
    if options.IpsiContra
        IC={};
        RFS_IPSI={};
        RFS_CONTRA={};
        [a,b,c]=unique(outdataset.CellName);
        for i=1:length(a)
            neurind=find([strcmpi(outdataset.CellName,a(i))]==1);
            %ipsicontra
            ipsi=0;
            contra=0;
            ipin=false(length(c),1);
            coin=false(length(c),1);
            ipsi=0;
            contra=0;
            for j=1:length(neurind)
                fr=outdataset.RegionOrElectrode(neurind(j));
                pos1=regexpi(outdataset.LocName(neurind(j)),fr{1}(1));
                
                if pos1{1}==1
                    IC{neurind(j),1}='IPSI';
                    ipsi=ipsi+1;
                    ipin(neurind(j),1)=true;
                else
                    IC{neurind(j),1}='CONTRA';
                    contra=contra+1;
                    coin(neurind(j),1)=true;
                    
                end
                RFS_CONTRA(or(coin,ipin),1)={contra};
                RFS_IPSI(or(coin,ipin),1)={ipsi};
            end
            
        end
        datasetadd=dataset({IC,'Ipsi_Contra'},{[[RFS_CONTRA{:}]',[RFS_IPSI{:}]'],'RFS_Contra','RFS_Ipsi'});
        outdataset=cat(2,outdataset,datasetadd);
    end
    
    
    
end


infile=whos('-file',filename);
if sum(strcmpi({infile.name},'OriginalFiles'))
    load(filename,'OriginalFiles','-mat')
    for i=1:size(outdataset,1)
        [p,f,e]=fileparts(OriginalFiles{outdataset.LocNum(i)});
        if isempty(p) % this if loop was added just because of a problem I ran into (Anitha Manohar) - use only the part inside the else-end of this loop if you are having problems.
            pos = max(regexp(f,'\'));% the problem was due to using multiple platforms, windows and ubuntu for the same analysis
            f =f(pos+1:end);
            [fields,values]=get_file_info([f,'.'],options.explab);
            for j=1:length(values)
                outdataset.(fields{j})(i)=values(j);
            end
        else
            [fields,values]=get_file_info([f,'.'],options.explab);
            for j=1:length(values)
                outdataset.(fields{j})(i)=values(j);
            end
        end
    end
end


% if isempty(outdataset)
%     outdataset=tempdataset;
% else
%     %outdataset=cat(1,outdataset,tempdataset);
%     outdataset=join(outdataset,tempdataset,...
%     'key',{'animal','date','Channel','Unit','Stimulus'},...
%     'Type','inner','MergeKeys',true);
% end

function RMMatrix2D=calculate_RM(PEHM,options)
h=1;
for i=1:size(PEHM,2)
    for s=1:size(PEHM,3)
        
        %calculating BA
        RMMatrix2D(h,1)=mean(PEHM(options.base,i,s));
        %calculating BASD
        RMMatrix2D(h,2)=std(PEHM(options.base,i,s));
        %calculating RM
        RMMatrix2D(h,3)=sum(PEHM(options.timewindow,i,s));
        %calculating RM_BA
        RMMatrix2D(h,4)=RMMatrix2D(h,3)-length(options.timewindow)*RMMatrix2D(h,1);
        %calculating Peak
        RMMatrix2D(h,5)=max(PEHM(options.timewindow,i,s));
        %calculating Peak_BA
        RMMatrix2D(h,6)=max(PEHM(options.timewindow,i,s))-RMMatrix2D(h,1);
        %Identify Channel
        RMMatrix2D(h,7)=options.anchan(i,1);
        %Identify Unit
        RMMatrix2D(h,8)=options.anchan(i,2);
        %Identify Stimulus
        RMMatrix2D(h,9)=s;
        %calculating NRM
        RMMatrix2D(h,10)=RMMatrix2D(h,3)/max(sum(PEHM(options.timewindow,i,:)));
        %calculating Peak_Latency
        RMMatrix2D(h,11)=min(find(PEHM(options.timewindow,i,s)==...
            max(PEHM(options.timewindow,i,s))))+...
            (min(options.timewindow-options.pretime/options.bin));
        h=h+1;
    end
    %     [null,idx]=sort(RMMatrix2D((i-1)*3+1:i*3,10),'descend');
    %     RMMatrix2D((i-1)*3+1:i*3,:)=RMMatrix2D(idx+(i-1)*3,:);
end
RMMatrix2D=RMMatrix2D(:,[10,3,5,11,4,6,1,2,9,7,8]);

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
[PeriEventMatrixAll,Group]=interface_class(data,1,time_window...
    ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
if nargin>3
    if length(filelist)>1
        for i=2:length(filelist)
            data=load(filelist{i});
            directory=data.directory;
            data=data.data;
            data.directory=directory;
            [PeriEventMatrixAlltemp,Grouptemp]=interface_class(data,1,time_window...
                ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
            for j=1:length(PeriEventMatrixAll)
                PeriEventMatrixAll{j}=cat(1,PeriEventMatrixAll{j},PeriEventMatrixAlltemp{j});
                
            end
            Group=cat(2,Group,Grouptemp);
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
            Groupn{(cond-1)*cl+j}=Group(logical(conditions{2,cond}));
        end
    end
    El=Eln;
    PeriEventMatrixAll=PeriEventMatrixAlln;
    Group=Groupn;
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
            if iscell(Group)
                Group_curr=Group{j};
            else
                Group_curr=Group;
            end
            [Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PeriEventMatrixAll_curr...
                ,Group_curr,'Euclidean',[],0,0,0,0,1,0);
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
