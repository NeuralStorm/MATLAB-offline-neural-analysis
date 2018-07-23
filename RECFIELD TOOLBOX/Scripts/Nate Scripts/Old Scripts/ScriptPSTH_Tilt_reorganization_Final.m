%The following script...

%Update date: 010815
%Update: changes to work on Ravi computer and Nate PC/Mac

%% CLEANUP & SETUP
clc;
PC=1;  %1=Computer, 2=Nate's Mac
tiltdetection=2; %1=means you want to do tilt detection, 2=means you want to do tilt discrimination
confusionmatrix=1; %1 means you want to look at confusion matrix output
batchprocessing=0;

%% USER-SPECIFIED OPTIONS
tilttot=4;
options.pretime = .200;
options.posttime= .200;
options.bin=.001; %in seconds  leave at .001
options.region={1:32};% corresponds to channel number
options.regionname={'CTX'};
options.binsizean=[1 2 20]/1000; %set binsizes for analysis  doesn't like not having 1
options.fileinfostring='exp.ratid.type.week.date';
options.bootstrapped = 1;   %1 means do bootstrapping  0 means don't do bootstrapping
options.bootstrapnum = 20;  %number of times it bootstraps
%  options.bootstrapCI = 0 ;
options.multipleIterations=1; % if you will do multiple iterations of tilt discrimination fcn (e.g. tilt detection)
options.evchannels=1:tilttot;    %tilt type event channels
%options.synred=1;   %sum of information of each neuron (for synergy/redundancy information calculation) 
%options.neuronInfo=1;  %if you want the information in each neuron
%options.fullInformationAnalysis=0;  %set equal to 1 (or not at all) for basic information analysis 
%% DIRECTORY SETUP
if PC;
    addpath(genpath(matlabdir));
    toolboxpath=toolbox; 
    outputfldr=informationResultsFldr;
else
    addpath(genpath('H:\Computer\Documents\MATLAB'));
    toolboxpath='H:\Computer\Documents\Matlab Toolboxes\RECFIELD TOOLBOX\';
    outputfldr='H:\Tilt Data\RAVI\RAVI mat formatted (for Information)';
    %need to define output directory if using another computer
end

addpath(genpath(toolboxpath));
%% SELECT FILES FOR ANALYSIS
[Filename,MatndFileDir,Filterindex] = uigetfile([formatted_datafdr,'\*.matnd']);   %changed from output folder to formatted_datafdr in v 010815
if batchprocessing;
    filesList = dir(MatndFileDir);
    filesList = filesList(3:end) ;
    files = {filesList.name}' ;
    files{1:end};
    select='N';
    while select=='N'
        result=input('Select range [1 3]: ');
        files{result}
        select=input('Are the above correct (Y/N)? ','s');
    end
    filenames{1} = strcat(MatndFileDir,filesep,files{result});
else
    filenames{1}=[MatndFileDir,Filename];
    result=1;
    files{1}=Filename;
end

%% TILT DISCRIMINATION

%Performs Classification Analysis
[dataoutput,~,~]=PSTH_Classification_Analysisv2(filenames,options);

%Pulls out data of interest from analysis
output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,6)...
    dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
    dataoutput(:,11) dataoutput(:,12) dataoutput(:,16)];

%Converts dataouput into a cell matrix for saving
summarymat=dataset2cell(output);

%----------------consider making a function-------------------------
%Adds pretime
summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
    num2cell(repmat(-options.pretime,(size(summarymat,1)-1),1));
summarymat{1,size(summarymat,2)}='PreTime(sec)';

%Adds postime 
summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
    num2cell(repmat(options.posttime,(size(summarymat,1)-1),1));
summarymat{1,size(summarymat,2)}='PostTime(sec)';

%Adds number of bootstrap iterations (if specified)
if options.bootstrapnum;
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        num2cell(repmat(options.bootstrapnum,(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='BootstrapNum';
end
disp('Tilt Discrimination Analysis is done !')

%Adds hemisphere used 
if ismember(16,options.region{1}) && ~ismember(32,options.region{1});
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
      cellstr(repmat('Right',(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='Hemisphere';
elseif ~ismember(16,options.region{1}) && ismember(32,options.region{1})
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        cellstr(repmat('Left',(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='Hemisphere';
    
elseif ismember(16,options.region{1}) && ismember(32,options.region{1})
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        cellstr(repmat('Both',(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='Hemisphere';
else
    disp('"options.region not selected"')
end
%-----------------------------------------------------------------------    
%Open file of interest for inspection before saving
openvar('summarymat')
beep
%% SAVING (TILT DISCRIMINATION)
reply = input('Do you want to save? Y/N [Y]: ', 's');
if reply =='Y'
   directory=uigetdir;
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    label=input('Type Filename (".xls" extension required) ', 's');
    xlswrite(label,summarymat);
else
    disp('Ok, your file was not saved')
end

%% TILT DETECTION 

%Load formatted mat file
load(filenames{1},'-mat')

%Initialize data output matrix headers
summarymat={'Information','Performance','Binsize','animal',...
    'date','exp','stim','NumCells','Info. Bootstrapped', 'Tilt'};
dataToSave=[];

%Classification Analysis (tilt type vs. background) 
for specifiedFilnames=1:length(result)
    fileIndice=result(specifiedFilnames);
    filenames{1} = strcat(MatndFileDir,filesep,files{fileIndice})
    tiltevnts=(1:tilttot);
    backgrndevnts=(tilttot+1:2*tilttot);  
    
    for tilt=1:tilttot
        options.evchannels=[tiltevnts(tilt) backgrndevnts(tilt)];    %Events 1 through 8 correspond to tilt initiation time stamps for the 8 tilt types
        [dataoutput]=PSTH_Classification_Analysisv2(filenames,options);
        dataoutput=dataset2cell(dataoutput);
        output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,6)...
            dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
            dataoutput(:,11) dataoutput(:,12) dataoutput(:,16)];
        newsummat=output;
       
        newsummat(2:size(newsummat,1),size(newsummat,2)+1)=...
            cellstr(repmat(Events(tilt).name,size(newsummat,1)-1,1)); %tiltevnts(k);
        
        summarymat=[summarymat;newsummat([2:2+length(options.binsizean)-1],:)];
        
        
        if tilt==1
        newdataoutput=dataoutput;
        else
            newdataoutput=dataoutput(2:end,:);
        end
        dataToSave=[dataToSave;newdataoutput];
    end
end

%----------------consider making a function-------------------------
%Adds pretime
summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
    num2cell(repmat(-options.pretime,(size(summarymat,1)-1),1));
summarymat{1,size(summarymat,2)}='PreTime(sec)';
dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
    num2cell(repmat(-options.pretime,(size(dataToSave,1)-1),1));
dataToSave{1,size(dataToSave,2)}='PreTime(sec)';

%Adds postime 
summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
    num2cell(repmat(options.posttime,(size(summarymat,1)-1),1));
summarymat{1,size(summarymat,2)}='PostTime(sec)';
dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
    num2cell(repmat(options.posttime,(size(dataToSave,1)-1),1));
dataToSave{1,size(dataToSave,2)}='PostTime(sec)';


%Adds number of bootstrap iterations (if specified)
if options.bootstrapnum;
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        num2cell(repmat(options.bootstrapnum,(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='BootstrapNum';
     dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
        num2cell(repmat(options.bootstrapnum,(size(dataToSave,1)-1),1));
    dataToSave{1,size(dataToSave,2)}='BootstrapNum';
end


%Adds hemisphere used 
if ismember(16,options.region{1}) && ~ismember(32,options.region{1});
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
      cellstr(repmat('Right',(size(summarymat,1)-1),1));
    dataToSave{1,size(dataToSave,2)}='Hemisphere';
       dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
      cellstr(repmat('Right',(size(dataToSave,1)-1),1));
    dataToSave{1,size(dataToSave,2)}='Hemisphere';
    Hemisphere='Right';
elseif ~ismember(16,options.region{1}) && ismember(32,options.region{1})
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        cellstr(repmat('Left',(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='Hemisphere';
     dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
        cellstr(repmat('Left',(size(dataToSave,1)-1),1));
    dataToSave{1,size(dataToSave,2)}='Hemisphere';
    Hemisphere='Left';
elseif ismember(16,options.region{1}) && ismember(32,options.region{1})
    summarymat(2:size(summarymat,1),size(summarymat,2)+1)=...
        cellstr(repmat('Both',(size(summarymat,1)-1),1));
    summarymat{1,size(summarymat,2)}='Hemisphere';
     dataToSave(2:size(dataToSave,1),size(dataToSave,2)+1)=...
        cellstr(repmat('Both',(size(dataToSave,1)-1),1));
    dataToSave{1,size(dataToSave,2)}='Hemisphere';
    Hemisphere='Both';
else
    disp('"options.region not selected"')
end

disp('Tilt Detection Analysis is done !')
%-------------------------------------------------------------------------
openvar('summarymat')
beep
%% SAVING (TILT DETECTION) 
reply = input('Do you want to save? Y/N [Y]: ', 's');
if reply =='Y'
   directory=uigetdir;
   cd(directory)
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    label=input('Type Filename (".xls" extension required) ', 's');
    xlswrite(label,summarymat);
    save([Filename(1:end-5),Hemisphere,'_information.mat'],'dataToSave')
    disp('Finished saving')
else
    disp('Ok, your file was not saved')
end
