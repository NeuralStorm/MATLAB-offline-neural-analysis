function [outdataset]=Rec_Field_Analysis_WB_TRM(filenames,options)

% options.pretime = 1.5 ;
% options.posttime = 1.5 ;
% options.bin = 0.005 ;
% options.intervals={'all'};
% options.region={1:32};
% options.binsizean = [0.005];
% options.regionname={'CTX'};
% options.evchannels = {[20 23]',[48 51]',[44 47]',[54 57]',[41 44]'} ;  % LHP, RHP only
% options.evchannels = {[5]'};
% filenames = {'Z:\Final Work Summer 2010\BC Compare\022009.WB011.WB.PR02.matnd'} ;    
% list of files 
% A = dir('Z:\Final Work Summer 2010\BC Compare\MatndFiles');
% List = {A.name}';
% filenames = List(3:end);

save('temp','-struct','options');
load temp;
outdataset=[];
for f=1:length(filenames)
    for r=1:length(region)
        for i=1:length(intervals)
            
            for b=1:length(binsizean)
               
                filename=filenames{f};
                options.region=region{r};
                options.regionname=regionname{r};
                options.bin=binsizean(b);
                options.intervals=intervals{i};
                options.evchannels = evchannels;
                options.units='probability';
                [PEHM] = PEHMFromMatndTRM(filename,options); 
                disp('done PEHM');
                ParamData = recfieldtest_TRM(PEHM,options,filenames{f});
                pause(5);
                close all;
                if isempty(outdataset)
                    outdataset=ParamData;
                else
                    outdataset=cat(1,outdataset,ParamData);
                
            end
        end
    end
end

end


% 
% function [NormRFMatrix2D]=receptive_field(PEHM,options)
% 
% ReceptiveFieldMatrix=receptivefield(PEHM,options.bin,options.pretime, options.posttime, options.base,options.response,'n',num2str([1:128]'),options.pvalue, 0);
% [NormRFMatrix2D]=receptivehistogram(ReceptiveFieldMatrix, 'prf');
% 
% 
% function outdataset=createdataset(filename,...
%     NormRFMatrix2D,options,outdataset)
% 
% [fields,values]=get_file_info(filename,'date_animal_exp_exp_');
% 
% rows=size(NormRFMatrix2D,1);
% for i=1:length(fields)
%     fileinfos{i}={repmat({values{i}},rows,1),fields{i}};
% end
% 
% tempdataset=dataset({NormRFMatrix2D,'NormResponse',' Response',...
%     ' Peak', 'FirstBinLatency','LastBinLatency','PeakLatency',...
%     'BackgroundAvg','BackgroundSTD', 'Place','Neuron',...
%     'PRF','RFS' },{repmat({options.regionname},...
%     rows,1),'RegionOrElectrode'},{repmat({options.bin},rows,1),'binsize'},...
%     {repmat({options.intervals},rows,1),'Intervals'}...
%     ,fileinfos{:});
% 
% if isempty(outdataset)
%     outdataset=tempdataset;
% else
%     outdataset=cat(1,outdataset,tempdataset);
% end
%     
% 
% 
% 
% function oldcode
% bin_vect=str2num(get(handles.ed_bin_vect,'string'));
% time_window=str2num(get(handles.ed_time_window,'string'));
% El{1,1}=get(handles.ed_el1_name,'string');
% El{2,1}=get(handles.ed_el2_name,'string');
% El{3,1}=get(handles.ed_el3_name,'string');
% El{4,1}=get(handles.ed_el4_name,'string');
% El{1,2}=str2num(get(handles.ed_el1_sel,'string'));
% El{2,2}=str2num(get(handles.ed_el2_sel,'string'));
% El{3,2}=str2num(get(handles.ed_el3_sel,'string'));
% El{4,2}=str2num(get(handles.ed_el4_sel,'string'));
% to_el=cellfun(@isempty,El);
% [row,col]=find(to_el==1);
% El(unique(row),:)=[];
% waitbar_handle = waitbar(0,'please wait...');
% 
% try
% 
%     directory=get(handles.tx_loaded_file,'string');
%     dirstruct=dir(([directory,'\Matlab files\*struct*.mat']));
% 
%     if isempty(dirstruct)
%         dirstruct=dir(([directory,'\*struct*.mat']));
%         if ~isdir(directory)
%             handles.file=directory;
%         else
%             handles.file=[directory,'\',dirstruct(1).name];
%         end
%     else
%         handles.file=[directory,'\Matlab files\',dirstruct(1).name];
%     end
%     data=load(handles.file);
%     directory=data.directory;
%     data=data.data;
%     data.directory=directory;
%     
% 
% 
% 
% catch
% 
%     errordlg('No files imported, please hit cancel and re-import the files');
%     
%     close(waitbar_handle);
%     return
% end
% 
% try
%     mkdir([directory,'\PSTH Analysis',get(handles.ed_sav_dir,'string'),'\',locnames{loc},'\']);
% catch
%     pos=find(handles.file=='\');
%     directory=handles.file(1:pos(end-1)-1);
%     data.directory=directory;
%     if isempty(dir([directory,'\PSTH Struct.*']))
%         mkdir([directory,'\PSTH struct\']);
%         copyfile(handles.file,[directory,'\PSTH struct\']);
%     else
%     end
%     
% end
% assignin('base','PSTH_class_raw_data',data);
% clear data;
% warning off MATLAB:xlswrite:AddSheet
% savedir=[directory,'\PSTH Analysis','\'];
% mkdir(savedir);
% % flag
% if get(handles.rb_usecons,'value')
%     inclusion=1;
%     usefile='R:\Metha data Analysis\PSTH Analysis\allrespcells\inclusionallanimals.xls';
% else
%     usefile='';
%     inclusion=0;
% end
% 
% data=evalin('base','PSTH_class_raw_data');
% locations=get(handles.lb_locations,'value');
% 
% 
% % locations=[1 3];
% % if get(handles.lb_dir,'value')==98
% %     locations=[1 2];
% % end
% 
% data.filenum=length(locations);
% data.files=data.files(locations);
% data.anfiles=data.anfiles(locations);
% data.numstimuli=data.filenum;
% [PeriEventMatrixAll,Group]=interface_class(data,1,time_window...
%     ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
% if nargin>3
%     if length(filelist)>1
%         for i=2:length(filelist)
%             data=load(filelist{i});
%             directory=data.directory;
%             data=data.data;
%             data.directory=directory;
%             [PeriEventMatrixAlltemp,Grouptemp]=interface_class(data,1,time_window...
%                 ,El,savedir,inclusion,str2num(get(handles.ed_RMlim,'string')),usefile);
%             for j=1:length(PeriEventMatrixAll)
%                 PeriEventMatrixAll{j}=cat(1,PeriEventMatrixAll{j},PeriEventMatrixAlltemp{j});
%                 
%             end
%             Group=cat(2,Group,Grouptemp);
%         end
%     end
%     [FileName,PathName] = uigetfile(['*.*']);
%     load([PathName,FileName]);
%     cl=length(conditions);
%     for cond=1:cl
%        for j=1:size(El,1);
%            Eln{(cond-1)*cl+j,1}=[El{j,1},'_',conditions{1,cond}];
%            Eln{(cond-1)*cl+j,2}=El{j,2};
%            PeriEventMatrixAlln{(cond-1)*cl+j}=PeriEventMatrixAll{j}(logical(conditions{2,cond}),:);
%            Groupn{(cond-1)*cl+j}=Group(logical(conditions{2,cond}));
%        end
%     end
%     El=Eln;
%     PeriEventMatrixAll=PeriEventMatrixAlln;
%     Group=Groupn;
% end
% 
% 
% duration=time_window(2)-time_window(1);
% for i=1:length(bin_vect)
%     fprintf('\n Executing analysis for binsize %2.0f  \n',bin_vect(i));
%     ConfusionMatrix_sav={};
%     I{1,3}='Cells number';
%     I{1,2}='Electrode';
%     I{1,i+3}=[num2str(bin_vect(i)),' ms'];
%     for j=1:size(El,1);
%         Neurons=size(PeriEventMatrixAll{j},2)/duration;
%         if Neurons~=0
%             bin_matr=create_binmatr(bin_vect(i),duration,Neurons);
%             PeriEventMatrixAll_curr=PeriEventMatrixAll{j}*bin_matr;
%             if iscell(Group)
%                 Group_curr=Group{j};
%             else
%                 Group_curr=Group;
%             end
%             [Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PeriEventMatrixAll_curr...
%                 ,Group_curr,'Euclidean',[],0,0,0,0,1,0);
%         else
%             ConfusionMatrix=zeros(10);
% 
%         end
%         I{(j)+1,1}=['Electrode ',num2str(j)];
%         I{(j)+1,2}=El{j,1};
%         I{(j)+1,3}=Neurons;
%         I{(j)+1,i+3}=I_confmatr(ConfusionMatrix);
%         tot_perf{(j)+1,i+3}=sum(diag(ConfusionMatrix))/size(ConfusionMatrix,1);
%         fprintf('\n Analysis performed on Electrode %1.0f  \n',j);
%         ConfusionMatrix_tmp=mat2cell(ConfusionMatrix,ones(1,size(ConfusionMatrix,1)),ones(1,size(ConfusionMatrix,1)));
%         toprow=cell(1,size(ConfusionMatrix_tmp,2));
%         toprow(1,1:2)=I((j)+1,1:2);
%         ConfusionMatrix_tmp=[toprow;ConfusionMatrix_tmp];
%         ConfusionMatrix_sav=[ConfusionMatrix_sav;ConfusionMatrix_tmp];
% 
% 
%     end
%     g=max(find(directory=='\'));
%     name='';
%     name=[directory(g+1:length(directory)),'_',date];
%     ConfusionMatrix_cell{i}=ConfusionMatrix_sav;
% %     xlswrite([savedir,'classresults_',name,'.xls'],ConfusionMatrix_sav,...
% %         ['ConfusionMatrix_binsize=',num2str(bin_vect(i))]);
%     fprintf('\n Analysis for binsize %2.0f completed \n',bin_vect(i));
%     waitbar(i/length(bin_vect),waitbar_handle);
% end
% tot_perf(1,:)=I(1,:);
% tot_perf(:,1:3)=I(:,1:3);
% tot_perf{1,1}='total % of correct';
% tot_perf(:,1:3)=[];
% I=cat(2,I,tot_perf);
% %I(:,length(bin_vect)+2+1:length(bin_vect)+2+2)=[];
% I{1,1}='Information in bits';
% pause(5)
% xlswrite([savedir,'classresults_',name,'.xlsx'],I,'Information');
% savefile=[savedir,'classresults_',name,'.mat'];
% save(savefile,'Class','ConfusionMatrix_cell','I');
% assignin('base','PSTH_analysis_results',I);
% close(waitbar_handle);
% warning on MATLAB:xlswrite:AddSheet
% 
% fprintf('\n Analysis has been performed without errors \n');
% locI=I;
% locI(:,3)=[];
% locI(:,1)=[];
% 
% for i=2:size(locI,1)
%     fields={};
%     values={};
% 
%     for j=1:length(locations)
%         filenamean=data.anfiles{j};
%         format=get(handles.ed_nameformat,'string');
%         [fieldstemp,valuestemp]=get_file_info(filenamean,format);
%         fields=cat(2,fields,cellfun(@cat,num2cell(ones(size(fieldstemp))*2),...
%             repmat({['LOC',num2str(locations(j)),'_']},...
%             1,size(fieldstemp,2)),fieldstemp,'uniformoutput',false));
%         values=cat(2,values,valuestemp);
%     end
%     infos(i,:)=values;
% end
% infos(1,:)=fields;
% locI(1,end+1)={'Locations'};
% locI(2:end,end)={length(locations)};
% cols=size(locI,2);
% rows=size(locI,1);
% locI=cat(2,locI,infos);
% locI(1,cols+1)={'Directory'};
% locI(2:rows,cols+1)={directory};
% 
% studyfile=get(handles.ed_studyfile,'string');
% [pathname,filename]=fileparts(studyfile);
% if isempty(studyfile)
%     
% else
%     if ispc
%         try
% 
%             [a,b,values]=xlsread(studyfile,'study');
%             locI(1,:)=[];
%             cols=size(values,2);
%             if cols~=size(locI,2)
%                 locI{1,cols}=nan;
%             end
%             locI=cat(1,values,locI);
%             xlswrite(studyfile,locI,'study');
%         catch
%             xlswrite(studyfile,locI,'study');
%         end
%     end
%     try
% 
%         load([filename,pathname,'.mat']);
%         PSTHStudy=cat(1,PSTHStudy,locI(2:end,:));
%         save([pathname,'\',filename,'.mat'],...
%         'PSTHStudy','-append')
%     catch
%         PSTHStudy=locI;
%         save([pathname,'\',filename,'.mat'],...
%         'PSTHStudy');
%     end
% 
% 
% end
