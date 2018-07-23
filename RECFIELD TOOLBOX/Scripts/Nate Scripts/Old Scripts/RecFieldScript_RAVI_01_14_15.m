%Nate Version
%clear all;
% close all;

%Version 01_14_15
%update: changes made so that analysis could be performed on Ravi and Nate's computer

% MatndFileDir = 'D:\Matlab\Reorganization_Posture\Matnd Files by Tilt\AmpDur' ;%%2,3,6 for everything, 1 just has diff speeds

%% 
disp('Performing RecField Analysis...')
%MatndFileDir = 'H:\Computer\Documents\Jaimie Tilt\Converted Mat Files (for Recfield)' ;%HL ONLY
%MatndFileDir ='C:\Users\Nate\Documents\Jaimie Tilt\Converted Mat Files (for Recfield)';
MatndFileDir=savdir;


A = dir(MatndFileDir);
A = A(3:end) ;   %commented out
files = {A.name}' ; 
% filenames{1} = strcat(MatndFileDir,filesep,files{1});%1, 3, 4confirm location of wanted file  %5 is tx data  %%%%1 2 10 13


% options 
% options.pretime=0.2;
options.bin=0.002; % size of the bin   (originally 2 ms bins)
options.region={17:32}; % electrode channels 
options.regionname={'LCTX'}; % regions of the brain, double check correct for some animals
options.binsizean=[2]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; %maybe for the ttest. 
options.TILT = 1; % only for the tilting 
options.fileinfostring='exp.ratid.type.week.date.';


% Pretime=[.217];
% Posttime=[.217];%time everything is accelerating, no constant velocity %[0.471 .471 .471 .471 .780 .78 .78 .78];
%currEv=[1 3;2 4];%[1 3 5 7 2 4 6 8];
currEv=[1:8];%[1 3 5 7 2 4 6 8];
backevents=[9:16];
%[10 12 14 16 9 11 13 15];%;%[9 11 13 15 10 12 14 16]; 
%St_and_Return_Events=[2 18;4 20;6 22;8 24; 1 17; 3 19; 5 21;7 23]; %[1 2 3 4 5 6 7 8]  %was originally commented
% RtEv=[17:24];
%EVwind=[.472 .780 .472 .762 .471 .78 .472 .762];
EVwind=[.200 .200 .200 .200 .200 .200];   % each position in array corresponds to event (eg [.2 .5] means use a 200ms and 500ms window for event 1 and 2 respectively)
%EVwind=[.471 .780 .472 .762 .471 .78 .472 .762];  what was present 3/26/14
%EVwind=[.78 .762 .78 .762]; for 4 events
% .78 .762];% .472 .471 .472];%[.472 .780 .472 .762 .471 .78 .472 .762];%for complete window
% EVwind=.217;%%fopr acc only widow

files{1:end}
reply='N';
while reply=='N'
FILN = input('What files do you want(if multiple 1:n)? ');
files{FILN}
reply = input('Did you select the correct files? Y/N [Y]: ', 's');
end

%FILN=[2]%[6 11 16 20 22 26 28 30];%[1:31];
% [6 11 16 20 22 25 26 28];%6 11 15 18 20 21];%update this list
% % [6 8 9 11 13 14 16 17 18 22 23 24 7 12 10 7];
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







