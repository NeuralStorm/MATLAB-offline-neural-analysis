%Jaimie Version
% clear all;
% close all;

% MatndFileDir = 'D:\Matlab\Reorganization_Posture\Matnd Files by Tilt\AmpDur' ;%%2,3,6 for everything, 1 just has diff speeds

MatndFileDir = 'C:\Users\Nate\Documents\Jaimie Tilt\Best\Bestagain' ;%HL ONLY



A = dir(MatndFileDir);
A = A(3:end) ;
files = {A.name}' ; 
% filenames{1} = strcat(MatndFileDir,filesep,files{1});%1, 3, 4confirm location of wanted file  %5 is tx data  %%%%1 2 10 13


% options 
% options.pretime=0.2;
options.bin=0.002; % size of the bin 
options.region={1:16,17:32}; % electrode channels 
options.regionname={'RCTX','LCTX'}; % regions of the brain, double check correct for some animals
options.binsizean=[2]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; %maybe for the ttest. 
options.TILT = 1; % only for the tilting 
options.fileinfostring='exp.ratid.type.week.date.';


% Pretime=[.217];
% Posttime=[.217];%time everything is accelerating, no constant velocity %[0.471 .471 .471 .471 .780 .78 .78 .78];
currEv=[1:8];%[1 3 5 7 2 4 6 8];
backevents=[9:16];%[9:16];%[9 11 13 15 10 12 14 16]; 
St_and_Return_Events=[2 18;4 20;6 22;8 24; 1 17; 3 19; 5 21;7 23]; %[1 2 3 4 5 6 7 8]
% RtEv=[17:24];
EVwind=[.471 .780 .472 .762 .471 .780 .472 .762];% .472 .471 .472];%[.472 .780 .472 .762 .471 .78 .472 .762];%for complete window
% EVwind=.217;%%fopr acc only widow


FILN=[1]%[6 11 16 20 22 26 28 30];%[1:31];
% [6 11 16 20 22 25 26 28];%6 11 15 18 20 21];%update this list
% % [6 8 9 11 13 14 16 17 18 22 23 24 7 12 10 7];
for j=1:length(FILN)%:12;%:12;
    filename{1} = strcat(MatndFileDir,filesep,files{FILN(j)});%%
    for i=1:length(backevents);%:2%currEv
        timewin=EVwind(i);%add the i in for processing all events
        options.pretime = timewin;%Pretime;%(i);
        options.posttime = timewin;%Posttime;%(i);%in seconds!!!!  ??
        options.response=[.001 timewin];%Posttime];%(i)];

        options.CurrentEvents=St_and_Return_Events(i,:);%currEv(i);%St_and_Return_Events(i,:);%currEv(i);%currEv(i);%
        options.backgroundevent=backevents(i);

        outdataset=Rec_Field_Analysis(filename,options);
    
    
% %         outdataset=Rec_Field_Analysis(filename,options);
        if j==1%for batch processing make this a 1 - for single files, make it whatever j is.
            if i==1
                results=outdataset(1,:);
            end
        else
        end
        if isempty(outdataset)
            results=results;
        else
            results=[results;outdataset(:,1:29)];
        end
    end
    %%        AllStCom_win=[AllStCom_win;AllStInfovsBack];
    export(results,'XLSFile','RecField_StvsRttilts_2_4.xlsx');
%     export(results,'XLSFile','RECFIELD_Complete_Window_onefile.xlsx');
end






