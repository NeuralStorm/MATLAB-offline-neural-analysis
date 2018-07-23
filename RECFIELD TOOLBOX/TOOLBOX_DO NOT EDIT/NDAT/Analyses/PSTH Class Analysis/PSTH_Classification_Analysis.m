function [outdataset]=PSTH_Classification_Analysis(filenames,options)

% options.pretime=-0.005;
% options.posttime=0.045;
% options.bin=0.001;
% % options.intervals={'quiet','whisking'};
% %options.intervals = {} ;
% options.region={16:32};
% options.regionname={'CTX'};
% options.binsizean=[1 2 4 8 10 20 40]/1000;
% options.fileinfostring='date_animal_exp_exp_';
% options.evchannels=[2,4,5];
% options.bootstrapped = 1 ;
% options.bootstrapnum = 200 ;
% options.bootstrapCI = 0 ;


if isfield(options,'bootstrapped')
    if options.bootstrapped
        if isfield(options,'bootstrapCI')
            
        else
            options.bootstrapCI = 0;
            options.bootstrapnum = 200;
            if matlabpool('size') == 0
                matlabpool
            else
                matlabpool close
                matlabpool
            end
        end
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


save('temp','-struct','options');
load temp;
outdataset=[];
fprintf('\n')
tw=1;

for t=timewindow
    clc
    ft=fprintf('Time Window: %2.0f|%2.0f',tw,length(timewindow));
    for f=1:length(filenames)
        fc=fprintf(',File: %2.0f|%2.0f',f,length(filenames));
        for r=1:length(region)
            rc=fprintf(',Region %2.0f|%2.0f',r,length(region));
            for i=1:length(intervals)
                ic=fprintf(',Interval %2.0f|%2.0f',i,length(intervals));
                for b=1:length(binsizean)
                    bc=fprintf(',Binsize %2.0f|%2.0f',b,length(binsizean));
                    filename=filenames{f};
                    options.region=region{r};
                    options.regionname=regionname{r};
                    options.bin=binsizean(b);
                    options.intervals=intervals{i};
                    if options.timewindow
                       options.posttime=t;
                       rat=(options.posttime+options.pretime)/options.bin;
                       if rat>=1
                       else
                           delete_char(bc)
                           break
                       end
                    end
                    if b==1
                        [PEHMClass1,Group]=PEHMClassFromMatnd(filename,options);
                    end
                    Duration=length((-options.pretime:binsizean(1):options.posttime))-1;
                    Neurons=size(PEHMClass1,2)/Duration;
                    bin_matr=create_binmatr(options.bin*1000,Duration,Neurons);
                    PEHMClass=PEHMClass1*bin_matr;
                    
                    
                    
                    
                    %disp('done PEHM');
                    [ConfusionMatrix,Ir,perf,class]=classify_PSTH(PEHMClass,Group,options);
                    I(1)=Ir;
                    I(9)=Neurons;
                    if ~strcmpi(options.firstspike,'all')
                        %[ConfusionMatrix_fs,I_fs,perf_fs,class_fs]=classify_PSTH(PEHMClass,Group,options);
                        
                        I(5)= [[I(1)/sum(sum(PEHMClass)/size(PEHMClass,1))]];
                        I(6)= sum(sum(PEHMClass));
                        I(7)= sum(size(PEHMClass,1));
                    end
                    % bootstrap calculation
                    
                    if bootstrapped
                        InformationBtsp = BootstrapFunction(PEHMClass,Group,options);
                        I(2) = [InformationBtsp] ;
                        if ~strcmpi(options.firstspike,'all')
                            %[ConfusionMatrix_fs,I_fs,perf_fs,class_fs]=classify_PSTH(PEHMClass,Group,options);
                            
                            I(8)= [[I(2)/sum(sum(PEHMClass)/size(PEHMClass,1))]];
                        end
                    end
                    %shuffled Information for the estimate of DInoise=I-Ish
                    
                    if options.trialshuffling>1
                        
                        for sh=1:options.trialshuffling
                            shc=fprintf(',Trialshuffling %2.0f|%2.0f',sh,options.trialshuffling);
                            S=unique(Group);
                            PEHMClass_s=[];
                            for g=S'
                                PEHMClass_s=[PEHMClass_s;Trial_Shuffle_PEM(PEHMClass(Group==g,:),Neurons)];
                                
                            end
                            [ConfusionMatrix_sh{sh},I_sh{sh},perf_sh{sh},class_sh{sh}]=classify_PSTH(PEHMClass_s,Group,options);
                            delete_char(shc)
                        end
                        I(3)= [mean([I_sh{:}])] ;
                    end
                    %synergy/redundancy for the estimate of the
                    %DIsig=Synred-DInoise
                    
                    if options.synred
                        B=size(PEHMClass,2)/Neurons;
                        for n=1:Neurons
                            ssr=fprintf(',SynRed Neuron %2.0f|%2.0f',n,Neurons);
                            PEHMClass_sn=PEHMClass(:,(n-1)*B+1:n*B);
                            [ConfusionMatrix_sr{n},I_sr{n},perf_sr{n},class_sr{n}]=classify_PSTH(PEHMClass_sn,Group,options);
                            delete_char(ssr)
                        end
                        I(4)= [sum([I_sr{:}])] ;
                    end
                    
                    
                   
                        
                    
                    
                    outdataset=createdataset(filename,ConfusionMatrix,I,perf,class,options,outdataset);
                    
                    delete_char(bc)
                end
                delete_char(ic)
            end
            delete_char(rc)
        end
        delete_char(fc)
    end
    delete_char(ft)
    tw=tw+1;
end






function [ConfusionMatrixnotnorm,I,perf,Class]=classify_PSTH(PEHMClass,Group,options)

if options.stimback==1
    if min(Group)~=0
    else
        Group(Group~=0)=2;
        Group(Group==0)=1;
    end
elseif options.stimback==2
    Group=Group+1;
end
[Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PEHMClass,Group,'Euclidean',[],0,options.vardropping,0,0,1,0);
for k=1:size(ConfusionMatrixnotnorm,3)
    perf(k,1)=sum(diag(ConfusionMatrixnotnorm(:,:,k)))/sum(sum(ConfusionMatrixnotnorm(:,:,k)));
    I(k,1)=I_confmatr(ConfusionMatrixnotnorm(:,:,k));
end

function outdataset=createdataset(filename,ConfusionMatrix,I,perf,class,options,outdataset)
[fields,values]=get_file_info(filename,'date_animal_exp_stim_');
for i=1:length(fields)
    fileinfos{i}={values(i),fields{i}};
end

tempdatasetadd={};
for k=1:size(ConfusionMatrix,3)
    
    tempdataset(k,:)=dataset({I(k,1),'Information'},{perf(k),'Performance'},{{ConfusionMatrix(:,:,k)},'ConfusionMatrix'},{{class},'Classes'},{{options.regionname},...
        'RegionOrElectrode'},{options.bin,'Binsize'},{{options.intervals},'Intervals'}...
        ,fileinfos{:},{I(k,9),'NumCells'});
    
    if options.vardropping
        tempdatasetadd{1}=dataset({k,'VarDropp'});
        
    end
    if options.bootstrapped
        tempdatasetadd{2}=dataset({I(k,2),'Information_Bootstrapped'});
        
    end
    if options.trialshuffling>1
        tempdatasetadd{3}=dataset({I(k,3),'Information_Shuffled'});
        
    end
    if options.synred
        tempdatasetadd{4}=dataset({I(k,4),'SynRed'});
        
    end
    if ~strcmpi(options.firstspike,'all')
        tempdatasetadd{5}=dataset({I(k,[5,6,7]),[options.firstspike,'_Infoxspike'],[options.firstspike,'_Num'],[options.firstspike,'_NumTrials']});
        if options.bootstrapped
            tempdatasetadd{6}=dataset({I(k,8),'Bootstrap_Infoxspike'});
        end
    end
    if options.timewindow
        tempdatasetadd{7}=dataset({options.posttime,'Timewindow'});
        
    end


end

for i=1:length(tempdatasetadd)
    if ~isempty(tempdatasetadd{i})
        tempdataset=cat(2,tempdataset,tempdatasetadd{i});
    end
end




if isempty(outdataset)
    outdataset=tempdataset;
else
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
