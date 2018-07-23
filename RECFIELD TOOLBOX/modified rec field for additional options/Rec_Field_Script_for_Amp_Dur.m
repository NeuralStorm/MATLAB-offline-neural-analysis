% MatndFileDir = 'D:\Matlab\Reorganization_Posture\Matnd Files by Tilt\AmpDur' ;%%2,3,6 for everything, 1 just has diff speeds

MatndFileDir = 'D:\Matlab\Reorganization_Posture\Matnd Files by Tilt\AmpDur' ;%HL ONLY



A = dir(MatndFileDir);
A = A(3:end) ;
files = {A.name}' ; 
% filenames{1} = strcat(MatndFileDir,filesep,files{1});%1, 3, 4confirm location of wanted file  %5 is tx data  %%%%1 2 10 13


% options 
% options.pretime=0.2;
options.bin=0.001; % size of the bin 
options.region={1:16,17:32}; % electrode channels 
options.regionname={'RCTX','LCTX'}; % regions of the brain, double check correct for some animals
options.binsizean=[1]/1000; %same as binsize analysis, but can do it for an array of binsizes
options.pvalue=0.001; % maybe for the ttest. 
options.TILT = 1; % only for the tilting 
options.fileinfostring='exp.ratID.descr.Week.Date';


% Pretime=[.217];
% Posttime=[.217];%time everything is accelerating, no constant velocity %[0.471 .471 .471 .471 .780 .78 .78 .78];
currEv=[1:8];%[1 3 5 7 2 4 6 8];
backevents=[9:16];%[9 11 13 15 10 12 14 16];
EVwind=[.472 .780 .472 .762 .471 .78 .472 .762];%for complete window
% EVwind=.217;%%fopr acc only widow


FILN=[23]%6 11 15 18 20 21];
for j=1:length(FILN)%:12;%:12;
    filename{1} = strcat(MatndFileDir,filesep,files{FILN(j)});%%
    for i=1:length(currEv);%:2
        timewin=EVwind(i);%add the i in for processing all events
        options.pretime = timewin;%Pretime;%(i);
        options.posttime = timewin;%Posttime;%(i);%in seconds!!!!  ??
        options.response=[.001 timewin];%Posttime];%(i)];

        options.CurrentEvents=currEv(i);
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
    export(results,'XLSFile','rec_field_Smooth10GapsLess20ms_1.xlsx');
%     export(results,'XLSFile','RECFIELD_Complete_Window_onefile.xlsx');
end






%%before I can do this - what is the real time for each type?