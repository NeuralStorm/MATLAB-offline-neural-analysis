function [varargout] = tilt_discrimination(options,varargin)
%TILT_DISCRIMINATION performs tilt discrimination information analysis
%   Using the "PSTH_Classification_Analysisv2" for specified matnd files,
%   the amount of information is found in distinguishing between specified
%   tilt types
%
%     Syntax:
%     
%         TILTDISCRIMINATIONOUTPUT = TILT_DISCRIMINATION(OPTIONS) prompts 
%         user to select file for analysis (assumes only one file being analyzed)  
%         
%         TILTDISCRIMINATIONOUTPUT = TILT_DISCRIMINATION(OPTIONS,
%         'batchfolder') assumes user is performing batch processing
%         
%         TILTDISCRIMINATIONOUTPUT=TILT_DISCRIMINATION(OPTIONS,'filename'
%         ,’Full') assumes user wants to analyze a specific file
%
%         [PROCESSEDCELL,ERRORCELL,FULLFILENM,TILTDETECTIONOUTPUT]=
%         TILT_DETECTION(__) produces below outputs
%
%     Outputs:
%     
%         TILTDISCRIMINATION contains all of the processed data from the 
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
%$LastChangedDate: 2016-06-15 18:14:32 -0400 (Wed, 15 Jun 2016) $

 [bckgrndEvntChans,evntChans,inputFilenames]=tilt_evnts(varargin{:});
 %options.evchannels=evntChans{1};
 options.evchanCell=evntChans;

 [dataOutput,errorCell,processedCell]=...
    PSTH_Classification_Analysisv2(inputFilenames,options);
disp('Tilt Discrimination analysis finished')
beep

%Define Outputs
if nargout>=1
    varargout{nargout}=dataOutput;
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
    





