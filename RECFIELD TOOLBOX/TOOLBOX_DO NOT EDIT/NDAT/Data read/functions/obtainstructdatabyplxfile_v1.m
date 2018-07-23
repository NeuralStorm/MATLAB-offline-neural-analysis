function [data,directory,anfiles,infile,names,events]=obtainstructdatabyplxfile_v1(stdir,anfiles,infile,names)


% function data=obtainstructdatabyplxfile()
%
% This function transport the data relative to an experimet session in a
% matlab structure called data. The function requires only the name of the
% directory in which the plexon file are contained, this is implemented
% simply choose the directory in the directory browser, which appears when
% the function is ran.

% 10/16/2004 by Alessandro Scaglione (Drexel University)

% corrected problem with minstimuli 05/16/2006


%%Initialization
t=clock;
%% nargin<1
if nargin<1
    stdir=pwd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Constant Variables%%%%%%%%%%%%%%%%%
%variables for the matlab function
%Neurons recordable per elettrode
Neurons=4;
%minum number of stimuli
evmin=30;
%% Nargin=1
if nargin <2
%     directory= uigetdir(stdir);
    directory=stdir;
    if directory~=0
        filesindir = dir(directory);
        cont=1;
        for currentfile=1:size(filesindir,1)
            if filesindir(currentfile).isdir~=1
                if not(isempty(strfind(filesindir(currentfile).name,'.plx')))&...
                        (strfind(filesindir(currentfile).name,'.plx')==(length(filesindir(currentfile).name)-3))
                    listfile{cont,1}=filesindir(currentfile).name;
                    cont=cont+1;
                end
            end
        end
        listfile=sort(listfile);
        anfiles=listfile;
        data=1;
        filename=listfile{1};
        
        out= plx_header_nodll([directory,filesep,filename]);
        tscounts=out.tscounts;
        wfcounts=out.wfcounts;
        evcounts=out.evcounts;
        % Interpretation of type values: 0-neuron, 1-event, 2-interval, 3-waveform,
        % 4-population vector, 5-continuous variable, 6 - marker
        infile=[];
        tscounts(:,1)=[];
        wfcounts(:,1)=[];
        evcounts(:,1)=[];
        if sum(sum(tscounts))==0
        else
            infile=[infile 0];
        end
        if sum(sum(wfcounts))==0
        else
            infile=[infile 3];
        end
        if sum(sum(evcounts))==0
        else
            infile=[infile 1];
        end
        n=length(out.adchannels);%[n,names] = mexPlex(15,[directory,'\',filename]);        
        events={};
        
        for i=1:length(listfile)
            filenametemp=listfile{i};
            %pause(0.5)
            out= plx_header_nodll([directory,filesep,filenametemp]);
            tscounts1=out.tscounts;
            wfcounts1=out.wfcounts;
            evcounts1=out.evcounts;
            %pause(0.2)
            tscounts1(:,1)=[];
            wfcounts1(:,1)=[];
            evcounts1(:,1)=[];
            evcounts1(256:end)=[];
            A=out.event;%[evnum,A]=plx_event_names([directory,'\',filename]);
            minnumev=0;
            endix=length(evcounts1(evcounts1>minnumev));
            events(1:endix,1,i)=num2cell(evcounts1(evcounts1>minnumev))';
            events(1:endix,2,i)=num2cell(find(evcounts1>minnumev))';
            events(1:endix,3,i)={A(evcounts1>minnumev).name}';
            for j=1:size(events,1)
                events{j,3,i}(events{j,3,i}==0|events{j,3,i}==32)=[];
            end
        end

        names={out.adchannels.name}';
        toel=[];
        for i=1:n
            try
                [adfreq, n, ad] = mexPlex(18,[directory,filesep,filename], i, 1, 2);
                infile=[infile 5];
            catch
                toel=[toel i];
            end
        end
        names(toel,:)=[];
    else
        data=0;
        directory=stdir;
        anfiles=0;
        infile=0;
        names=0;
    end
else
%% initialize variable nargin>2
    minstimuli=0;
    maxstimuli=minstimuli;
    directory=stdir;
    listfile=anfiles;
    filename=listfile{1};
    [Electrodes,chnames] = mexPlex(14,[directory,filesep,filename]);
    files=max(size(listfile));
    for i=1:Electrodes
        electrodes(i).continous.ts(1)=0;
        electrodes(i).continous.val(1)=0;
        for j=1:Neurons
            electrodes(i).neurons(j).timestamps(1)=0;
            %electrodes(i).neurons(j).waveform(1)=0;
        end
    end
    waitbar_handle = waitbar(0,'please wait...');
    %read whole file timestamps
    numstimuli=0;
    for currentfile=1:files
        filename=listfile{currentfile};
        data.files(currentfile).electrodes=electrodes;
        [tscounts, wfcounts, evcounts] = mexPlex(4,[directory,filesep,filename], 1);
        maxstimuli=max(max([evcounts(1:256),maxstimuli]));
        if currentfile==1
            minstimuli=maxstimuli;
        end
        minstimuli=min(min([max(evcounts(1:256)),minstimuli]));
        
        if currentfile==1
            tottscounts=tscounts;
        else
            tottscounts=[tottscounts+tscounts];
        end
            position=find(evcounts(1:256)~=0);
        if isempty(find(infile==1))
        else
            for i=1:length(position)
                try
                    
                    [number,data.files(currentfile).eventts(position(i)).evtimestamps...
                        ,sv]=mexPlex(3,[directory,filesep,filename],position(i));
                    data.files(currentfile).eventts(position(i)).number=number;
                    numstimuli=numstimuli+1;
                catch
                    data.files(currentfile).eventts(position(i)).number=evcounts(position(i));
                    data.files(currentfile).eventts(position(i)).evtimestamps=zeros(evcounts(position(i)),1);
                    numstimuli=numstimuli+1;
                    errordlg('error in file, number of events in the header differs from what in the file. Solution: call Alessandro');
                end
            end
        end
        %waveform aquisition
%         if isempty(find(infile==3))
% 
%         else
% 
%             data.files(currentfile).waveformts=;
% 
%         end
% 
        for i=1:Electrodes
            %acquire timestamps neuron 1
            if isempty(find(infile==0))
            else
                for j=1:Neurons
                    if tscounts(j+1,i+1) == 0
                    else
                        [n,data.files(currentfile).electrodes(i).neurons(j).timestamps]=mexPlex(5,[directory,'\',filename],i,j);
                        data.files(currentfile).tscounts=tscounts;
                    end
%                     if isempty(find(infile==3))
%                     else
%                         %[n,data.files(currentfile).electrodes(i).neurons(j).timestamps]=mexPlex(5,[directory,'\',filename],i,j);
%                         %data.files(currentfile).tscounts=tscounts;
%                     end
                end
            end
        end
        %acquire continous 5
        if isempty(find(infile==5))
        else
            for i=1:size(names,1)
                data.files(currentfile).electrodes(names{i,1}).continous.ts(1)=0;
                data.files(currentfile).electrodes(names{i,1}).continous.val(1)=0;
                data.files(currentfile).electrodes(names{i,1}).continous.name=names{i,2};
            end
        end
        waitbar(currentfile/files,waitbar_handle);
    end
    %storage of service information
    data.maxstimuli=maxstimuli;
    data.minstimuli=minstimuli;
    data.filenum=files;
    data.numstimuli=numstimuli;
    data.elcnumber=Electrodes;
    data.numneur=4;
    data.anfiles=anfiles;
    if isempty(find(infile==5))
         data.continous=[];
        data.continousname=[];
    else
        data.continous=size(names,1);
        data.continousname=names(:,2);
    end
    close(waitbar_handle);
    avchan=findchan(tottscounts,Electrodes,cellstr(chnames));
    data.avchan=avchan;
    data.chnames=cellstr(chnames);
    etime(clock,t);
end