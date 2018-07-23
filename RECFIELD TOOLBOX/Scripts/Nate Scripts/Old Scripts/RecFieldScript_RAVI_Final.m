%%RecFieldScript_RAVI_Final  specifies inputs to RecField Analysis 
% 
%    RecField (short for receptor field) finds response properties of
%    individual nuerons.  Examples include response magnitude, peak
%    latency and first bin latency.  This script specifies the input
%    parameters for using this program.

%
%$Rev:  $
%$Author:  $
%$LastChangedDate: $

%% Initial Setup
disp('Performing RecField Analysis...')
MatndFileDir=savdir;
results=[];

%% User-selected Features
tilttot=4;
batchprocessing=0;
prepostwindow=.200;

options.bin=0.002; % size of the bin   (originally 2 ms bins)
options.region={1:16,17:32}; % electrode channels
options.regionname={'RCTX','LCTX'}; % regions of the brain, double check correct for some animals
options.binsizean=[2]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; %maybe for the ttest.
options.TILT = 1; % only for the tilting
options.fileinfostring='exp.ratid.type.week.date.';


currEv=1:tilttot;
backevents=tilttot+1:2*tilttot;

%Time window before and after event (each element corresponds to event; eg.
%EVwind(3) corresponds to prepost window for event 3
EVwind=repmat(prepostwindow,1,length(currEv));
%% Select File of Interest
[Filename,MatndFileDir,Filterindex] = uigetfile([formatted_datafdr,'\*.matnd']);   %changed from output folder to formatted_datafdr in v 010815
if batchprocessing;
    A = dir(MatndFileDir);
    A = A(3:end) ;
    files = {A.name}' ;
    files{1:end}
    i=1;
    select='N';
    while select=='N'
        FILN=input('Select range [1 3]: ');
        files{FILN}
        select=input('Are the above correct (Y/N)? ','s');
    end
    
    filenames{1} = strcat(MatndFileDir,filesep,files{FILN})
else
    filenames{1}=[MatndFileDir,Filename]
    FILN=1;
    files{1}=Filename;
end



for j=1:length(FILN)
    filename{1} = strcat(MatndFileDir,filesep,files{FILN(j)});%%
    for i=1:length(EVwind);%:2%currEv
        timewin=EVwind(i);%add the i in for processing all events
        options.pretime = timewin;%Pretime;%(i);
        options.posttime = timewin;%Posttime;%(i);%in seconds!!!!  ??
        options.response=[.001 timewin];%Posttime];%(i)];
        options.CurrentEvents=currEv(i);
        options.backgroundevent=backevents(i);
        
        [outdataset]=Rec_Field_Analysis(filename,options);
        
        if isempty(outdataset)
            results=results;
        else
            results=[results;outdataset(:,1:27)];
        end
    end
end

disp('Refield Analysis Done')
%%
reply = input('Do you want to save? Y/N [Y]: ', 's');
if reply =='Y'
    directory=cd(recfield_resultsfldr)
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    label=input('Type Filename (".xls" extension required) ', 's');
    export(results,'XLSFile',label);
else
    disp('Ok, your file was not saved')
end







