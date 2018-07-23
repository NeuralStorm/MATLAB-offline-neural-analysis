%Nate Version
%clear all;
% close all;

%Version 01_16_15
%update: changes made so that user can specify the number of tilt types
%used in this experiment
%% Select Tilt Number
reply='N';
while reply=='N'
tilt_type_no = input('Type the number of tilt types used for this experiment ')
reply = input('Did you select the correct number of tilt types? Y/N [Y]: ', 's');
end


%% 
disp('Performing RecField Analysis...')
%MatndFileDir = 'H:\Computer\Documents\Jaimie Tilt\Converted Mat Files (for Recfield)' ;%HL ONLY
%MatndFileDir ='C:\Users\Nate\Documents\Jaimie Tilt\Converted Mat Files (for Recfield)';
MatndFileDir=savdir;


A = dir(MatndFileDir);
A = A(3:end) ;   %commented out
files = {A.name}' ; 
% filenames{1} = strcat(MatndFileDir,filesep,files{1});%1, 3, 4confirm location of wanted file  %5 is tx data  %%%%1 2 10 13

%% Options You (the user) Specifies
options.bin=0.050; % size of the bin   (originally 2 ms bins)
options.region={17:32}; % electrode channels 
options.regionname={'RCTX','LCTX'}; % regions of the brain, double check correct for some animals
options.binsizean=[50]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; %maybe for the ttest. 
options.TILT = 1; % only for the tilting 
options.fileinfostring='exp.ratid.type.week.date.';
EVwind=.200;  

files{1:end}
reply='N';
while reply=='N'
FILN = input('What files do you want(if multiple 1:n)? ');
files{FILN}
reply = input('Did you select the correct files? Y/N [Y]: ', 's');
end

%% Re-defines Inputs
currEv=[1:tilt_type_no];
backevents=[1+tilt_type_no:tilt_type_no+tilt_type_no]; 
EVwind=repmat(EVwind,1,tilt_type_no);

%% RecField Analysis
for j=1:length(FILN)%:12;%:12;
    filename{1} = strcat(MatndFileDir,filesep,files{FILN(j)});%%
    for i=1:length(EVwind);%:2%currEv
        timewin=EVwind(i);%add the i in for processing all events
        options.pretime = timewin;%Pretime;%(i);
        options.posttime = timewin;%Posttime;%(i);%in seconds!!!!  ??
        options.response=[.001 timewin];%Posttime];%(i)];
        options.CurrentEvents=currEv(i);

        %options.CurrentEvents=St_and_Return_Events(i,:);  %this was originally the first one below
        %currEv(i,:);%currEv(i);%St_and_Return_Events(i,:);%currEv(i);%currEv(i);%
        options.backgroundevent=backevents(i);
% 
        [outdataset]=Rec_Field_Analysis(filename,options);
    
    
% % %         outdataset=Rec_Field_Analysis(filename,options);
        if j==1%for batch processing make this a 1 - for single files, make it whatever j is.
            if i==1
                results=outdataset(1,:);
            end
        else
        end
        if isempty(outdataset)
            results=results;
        else
            results=[results;outdataset(:,1:27)];
        end
    end
%     %%        AllStCom_win=[AllStCom_win;AllStInfovsBack];


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







