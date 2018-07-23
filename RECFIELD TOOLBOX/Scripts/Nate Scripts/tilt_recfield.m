function [varargout] = tilt_recfield(options,varargin)
%TILT_RECFIELD performs receptor field analysis for tilt experiments
%
%     Determines inputs to "Rec_Field_Analysis" function specifically for
%     for experiments carried out on the tilt platform.  Tilt and background
%     timestamps are organized and/or creted using the "tilt_evnts"
%     function.  Analysis outputs for each tilt type are concatenated into
%     and saved as one output for this function.
%
%     Syntax:
%
%         RECFIELDOUTPUT = TILT_RECFIELD(OPTIONS) prompts user to select
%         file for analysis (assumes only one file being analyzed)
%
%         [FULLFILENM,RECFIELDOUTPUT] = TILT_RECFIELD(OPTIONS,
%         'batchfolder') assumes user is performing batch processing
%
%         [FULLFILENM,RECFIELDOUTPUT,ERRORCELL] = TILT_RECFIELD(OPTIONS,
%          'filename',’Full') assumes user wants to analyze a specific file
%
%     Outputs:
%
%         RECFIELDOUTPUT contains receptor field measures for each tilt type
%
%         FULLFILENM is the filename (folder/filename) of the processed
%         .matnd file
%
%         ERRORCELL contains any files (particularly during batch processing)
%         that were not analyzed due to an error
%
%         PROCESSEDCELL contains any files (particularly during batch
%         processing) that were analyzed
%
%     Inputs:
%
%         OPTIONS contains all the "Rec_Field_Analysis" input parameters.
%         Note you can use the "options_setup" function to set these
%         options up.
%
%         BATCHFOLDER if the user only supplies two inputs (this being the
%         second input), the function assumes the user is performing
%         batch processing (i.e. processing multiple .matnd files).
%         The batch folder is where all of these files are stored.
%
%         FILENAME is the full filename (directory/filename)
%         of the .matnd file being analyzed.  This must be followed by
%         'Full' (single quotation as shown) to inform function of filename
%         structure.
%
%         Parameter-value pairs can be used after the required inputs to
%         specify the following parameters. Enter the name as a string
%         followed by the value for that parameter. The following
%         parameters are valid
%
%
%
%     See also options_setup
%
%    $Rev: 102 $
%    $Author: Nate $
%    $LastChangedDate: 2017-02-06 13:43:10 -0500 (Mon, 06 Feb 2017) $

disp('Performing RecField Analysis...')

outdataset=[];
errorCell=[];
processedCell=[];

% extract events from files 
[bckgrndEvntChans,evntChans,inputFilenames]=...
    tilt_evnts(varargin{:});

options.evntChans=evntChans;
options.bckgrndEvntChans=bckgrndEvntChans;


% perform RecField Analysis 
[outdataset,errorCell]=Rec_Field_Analysis(inputFilenames,options);


disp('Refield Analysis Done')


% define Outputs
if nargout>=1
    varargout{1}=outdataset;
end


if nargout>=2
    varargout{2}=inputFilenames;
end

if nargout>=3
    if ~isempty(errorCell)
        varargout{3}=errorCell;
    else
        varargout{3}='no errors';
    end
end

if nargout==4
    varargout{4}=processedCell;
end

if nargout>4
    disp('More outputs than function can handle specified')
end




end

