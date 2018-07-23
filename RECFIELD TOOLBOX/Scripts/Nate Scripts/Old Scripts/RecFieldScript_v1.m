%Recfield Script
%Version: 1
%Description:  designed to work with RAVI Closed Loop Experiments 


%% Setup
disp('Performing RecField Analysis...')

MatndFileDir='H:\Tilt Data\RAVI\mat formatted';
foldercontents = dir(MatndFileDir);
foldercontents = foldercontents(3:end) ;   %commented out
files = {foldercontents.name}' ; 

%% Function Inputs 
options.bin=50/1000; % size of the bin in seconds 
options.region={1:16,17:32}; % electrode channels 
options.regionname={'RCTX','LCTX'}; % regions of the brain
options.binsizean=[50]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; %maybe for the ttest. 
options.TILT = 1; % only for the tilting 
options.fileinfostring='exp.ratid.type.week.date.';

%% Event Definitions
currEv=[1:8];%[1 3 5 7 2 4 6 8];
backevents=[9:16];
%[10 12 14 16 9 11 13 15];%;%[9 11 13 15 10 12 14 16]; 
St_and_Return_Events=[2 18;4 20;6 22;8 24; 1 17; 3 19; 5 21;7 23]; %[1 2 3 4 5 6 7 8]  %was originally commented
% RtEv=[17:24];
%EVwind=[.472 .780 .472 .762 .471 .78 .472 .762];
%EVwind=[.471 .780 .472 .762 .471 .78 .472 .762];  what was present 3/26/14


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

reply = input('Do you want to save? Y/N [Y]: ', 's');
if reply =='Y'
    directory=cd('H:\Computer\Documents\Jaimie Tilt\Recfield Results')
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    label=input('Type Filename ', 's');
    export(results,'XLSFile',label);
else
    disp('Ok, your file was not saved')
end







