function [varargout] = tilt_detection(options,varargin)
%TILT_DETECTION performs tilt detection information analysis
%   Using the "PSTH_Classification_Analysisv2" for specified matnd files,
%   the amount of information is found in each tilt by comparing individual
%   tilt timestamps with background timestamps.
%
%     Syntax:
%     
%         TILTDETECTIONOUTPUT = TILT_DETECTION(OPTIONS) prompts user to select
%         file for analysis (assumes only one file being analyzed)  
%         
%         TILTDETECTIONOUTPUT = TILT_DETECTION(OPTIONS,'batchfolder') 
%         assumes user is performing batch processing
%         
%         TILTDETECTIONOUTPUT=TILT_DETECTION(OPTIONS,'filename',’Full') 
%         assumes user wants to analyze a specific file
%
%        [PROCESSEDCELL,ERRORCELL,FULLFILENM,TILTDETECTIONOUTPUT]=
%        TILT_DETECTION(__) produces below outputs
%
%     Outputs:
%     
%         TILTDETECTIONOUTPUT contains all of the processed data from the 
%         analysis 
% 
%         FULLFILENAME is a cell of full filename(s) used by the
%         analysis
% 
%         ERRORCELL a cell matrix of any files that were unsuccessfully
%         processed during analysis
%
%         PROCESSEDCELL is a cell matrix of all files that were
%         successfully processed during the analysis
%
%     Inputs:
%     
%         OPTIONS is a structure generated from the options_setup function 
%
%     See also PSTH_Classification_Analysisv2, options_setup.
%$Rev:  $
%$Author: Nate $
%$LastChangedDate: 2016-06-15 18:14:48 -0400 (Wed, 15 Jun 2016) $

[bckgrndEvntChans,evntChans,inputFilenames]=tilt_evnts(varargin{:});

options.evchanCell=evntChans;
backgrndEvnts=bckgrndEvntChans;

%Tilt Detection
tiltDetectionOutput=[];
for file=1:length(inputFilenames)
        for tiltDetectionPair=1:length(options.evchanCell{file})
            
            %Defines event pairs for tilt detection
            options.evchanCell_original{file}=options.evchanCell{file};
            options.evchanCell{file}=[options.evchanCell{file}(tiltDetectionPair),...
                backgrndEvnts{file}(tiltDetectionPair)];
            
            %Performs information analysis 
            [dataOutput,errorCell,processedCell]=PSTH_Classification_Analysisv2(inputFilenames,options);
            
            %Restores event channells to initialized values
            options.evchanCell{file}=options.evchanCell_original{file};
           
            %Concatenates Data Output
            tiltDetectionOutput=[tiltDetectionOutput;dataOutput];
            
        end
        file=0;
        disp('Tilt Detection analysis finished')
        beep
end

%Define Outputs
%Define Outputs
if nargout>=1
    varargout{nargout}=tiltDetectionOutput;
end


if nargout>=2
    varargout{nargout-1}=inputFilenames;
end

if nargout>=3
    if ~isempty(errorCell)
    varargout{nargout-2}=errorCell;
    else
    varargout{nargout-2}='no errors'; 
    end 
end

if nargout==4
    varargout{nargout-3}=processedCell;
end

if nargout>4
    disp('More outputs than function can handle specified')
end
    
    
    
    
    