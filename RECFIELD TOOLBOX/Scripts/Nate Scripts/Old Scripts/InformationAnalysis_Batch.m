%% CLEAN-UP
clc;
clear all;
close all;

%% SETUP
addpath('F:\Matlab\Matlab Repository\General Purpose Functions')
[~,~]=directorySetup('analysis','information');
[options, directories]=informationSetup('region',{1:32});

%User-specified options
analysisType='TiltDiscrimination';   %options include: "TiltDiscrimination" or "TiltDetection"
save='No';                      %options include: "Yes" or "No"

%% INFORMATION ANALYSIS
files=dir(batchFolder);
file=0;
clear inputFilename
tiltDetectionOutput=[];
for fileRange=3:length(files)
    clear options.evchannels
    
    %Cell of file names for analysis
    fileName=files(fileRange).name;
    fullFilename=[batchFolder,fileName];
    file=file+1;
    inputFilename{file,1}=fullFilename;
    
    %Determine no. of tilts events from recording
    load(fullFilename,'-mat');
    tiltTotal=length(regexpi([Events.name],'5|6|7|8|9|10'))/2;
    
    %Stores event channel #s for each file for indexed access
    options.evchanCell{file}=1:tiltTotal;
    backgrndEvnts{file}=(tiltTotal+1:2*tiltTotal);
    
    
    if strcmpi(analysisType,'TiltDiscrimination')
        
        %TILT DISCRIMINATION
        [tiltDiscriminationOutput,errorCell,processedCell]=PSTH_Classification_Analysisv2(inputFilename,options);
        disp('Tilt Discrimination analysis finished')
        beep
        
    elseif strcmpi(analysisType,'TiltDetection') 
        
        %TILT DETECTION
        for tiltDetectionPair=1:length(options.evchanCell{file})
            
            %Defines event pairs for tilt detection
            options.evchanCell_original{file}=options.evchanCell{file};
            options.evchanCell{file}=[options.evchanCell{file}(tiltDetectionPair),...
                backgrndEvnts{file}(tiltDetectionPair)];
            
            %Performs information analysis 
            [dataOutput,errorCell,processedCell]=PSTH_Classification_Analysisv2(inputFilename,options);
            
            %Restores event channells to initialized values
            options.evchanCell{file}=options.evchanCell_original{file};
           
            %Concatenates Data Output
            tiltDetectionOutput=[tiltDetectionOutput;dataOutput];
            
        end
        
        file=0;
        disp('Tilt Detection analysis finished')
        beep
    else
        disp('Analysis type not specified. Choose either "TiltDiscrimination", "TiltDetection", or "All"')
        beep
    end 
end

%% SAVING (needs to be updated)

if strcmpi(save,'Yes')
    %Establish filename for all saved files
    saveFilename=['InfoAnlys.',datestr(now,'mm.dd.yy_HHMM')];
    
    %Save output for access later
    cd(infoDataOutputFldr)
    save([saveFilename,'_Discrim.mat'],'tiltDiscriminationOutput')
    disp('Data output saved')
    
    %Select relevant data for saving
    output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,5) ...
        dataoutput(:,6) dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
        dataoutput(:,11) dataoutput(:,12) dataoutput(:,13)...
        dataoutput(:,14) dataoutput(:,15) dataoutput(:,16)...
        dataoutput(:,17) dataoutput(:,18)];
    
   output=[tiltDetectionOutput(:,1) tiltDetectionOutput(:,2) tiltDetectionOutput(:,5) ...
        tiltDetectionOutput(:,6) tiltDetectionOutput(:,8) tiltDetectionOutput(:,9) tiltDetectionOutput(:,10)...
        tiltDetectionOutput(:,11) tiltDetectionOutput(:,12) tiltDetectionOutput(:,13)...
        tiltDetectionOutput(:,14) tiltDetectionOutput(:,15) tiltDetectionOutput(:,16)...
        tiltDetectionOutput(:,17) tiltDetectionOutput(:,19)];
    
    output=[tiltDiscriminationOutput(:,1) tiltDiscriminationOutput(:,2) tiltDiscriminationOutput(:,5) ...
        tiltDiscriminationOutput(:,6) tiltDiscriminationOutput(:,8) tiltDiscriminationOutput(:,9) tiltDiscriminationOutput(:,10)...
        tiltDiscriminationOutput(:,11) tiltDiscriminationOutput(:,12) tiltDiscriminationOutput(:,13)...
        tiltDiscriminationOutput(:,14) tiltDiscriminationOutput(:,15) tiltDiscriminationOutput(:,16)...
        tiltDiscriminationOutput(:,17) tiltDiscriminationOutput(:,19)];
    %Converts output into a cell matrix for saving
    summarymat=dataset2cell(output);
    
    %Saves as Excel Spreasheet in Information Results Folder
    disp('Saving into spreadsheet...')
    cd(informationResultsFldr)
    xlswrite([saveFilename,'.xls'],summarymat);
    disp('Excel spreadsheet saved')
else
    disp('File not saved. If user wishes to do so specify in "user-specified options" section of script.')
end
