function [varargout] = tilt_evnts(varargin)
%TILT_EVENTS organizes tilt experiment filename(s) and events for analysis
% 
%     This function is designed to pull out the relevant event timestamps
%     and associate them with thier appropiately formatted filename for 
%     batch processing(or single file analysis) for tilt experiments. 
%     Specifically, this function's outputs are intended for use in the 
%     "Rec_Field_Analysis" and "PSTH_Classification_Analysisv2" functions 
%     specifically for experiments carried out on the tilt platform.  These 
%     events include the start of tilt and background timestamps created 
%     from the "tilt_evnt_formatter" function. 
%
%     Syntax:
%     
%         INPUTFILENAMES = TILT_EVNTS() prompts user to select
%         file for analysis (assumes only one file being analyzed)
%         
%         [EVNTCHANS,INPUTFILENAMES] = TILT_EVNTS('batchfolder') 
%         assumes user is performing batch processing
%
%         [BCKGRNDEVNTCHANS,EVNTCHANS,INPUTFILENAMES] = TILT_EVNTS('filename', 
%          ’Full') assumes user wants to analyze a specific file
%          
%     Outputs: 
% 
%         INPUTFILENAMES is the filename (folder/filename) of the processed
%         .matnd file
% 
%         EVNTCHANS contains event channels that correspond to the each
%         tilt type (for each INPUTFILENAME)
%
%         BCKGRNDEVNTCHANS contains background event channels that 
%         correspond to each tilt type (for each INPUTFILENAME)
%       
%     Inputs:
%     
%         BATCHFOLDER if the user only supplies two inputs (this being the
%         second input), the function assumes the user is performing 
%         batch processing (i.e. processing multiple .matnd files).  
%         The batch folder is where all of these files are stored  
%        
%         FILENAME is the full filename (directory/filename) 
%         of the .matnd file being analyzed.  This must be followed by 
%         'Full' (single quotation as shown) to inform function of filename 
%         structure
%       
%     See also tilt_evnt_formatter Rec_Field_Analysis PSTH_Classification_Analysisv2
%
%    $Rev: 82 $
%    $Author: Nate $
%    $LastChangedDate: 2017-01-13 17:53:28 -0500 (Fri, 13 Jan 2017) $


clear inputFilename options.evchannels


if nargin==0 
    [fileName,batchFolder,~] = uigetfile('\*.matnd');
    fullFiles=[1;2;3];
    file=0;

elseif nargin==1 
    fullFiles=dir(varargin{1});
    batchFolder=varargin{1};
    file=0;
    
   
    % convert name structure into cell array
    fileNameCell={fullFiles.name};
    
    % find indices of .matnd files
    matndInd=strfind(fileNameCell,'.matnd');
    
    % create logical cell
    logicalPrep=cellfun(@isempty,matndInd,...
        'UniformOutput',false);
    
    % create logical array
    logicalArray=~logical([logicalPrep{:}]);
    
    % remove files that are not .matnd formatted
    fullFiles=fileNameCell(logicalArray)';
    
    
elseif nargin==2 
    
    if ~strcmpi(varargin{2},'Full')   
    fileName=varargin{1};
    batchFolder=varargin{2};
    end
    fullFiles=[1;2;3];
    file=0;
    
else 
    disp('Too many inputs specified')
    
end


for fileRange=1:size(fullFiles,1)  %used to be -2
    
    % if batch processing
    if nargin==1
        %     % cell of file name(s) for analysis
        %     fileName=fullFiles(fileRange+2).name;
        
        % extract file name for analysis
        fileName=fullFiles{fileRange};
    end
    
    % if user selecting a specific file 
    if nargin>=2 && strcmpi(varargin{2},'Full')
        fullFilename=varargin{1};    
    else
    fullFilename=[batchFolder,fileName];
    end
    
    file=file+1;
    inputFilename{file,1}=fullFilename;
    
    % determine no. of tilts events from recording
    load(fullFilename,'-mat');
    
    % parse filename 
    fileParsed=strsplit(fileName,'.');
   
    % determine the total number of tilt events
    tiltTotal=length(regexpi([Events.name],...
        '001|002|003|004|005|006|007|008|009|010|011|012|013|014|015'))/2;
  
    % stores event channel #s for each file for indexed access
    evntChans{file}=1:tiltTotal;
    bckgrndEvntChans{file}=(tiltTotal+1:2*tiltTotal);
    
end

if nargout>=1
    varargout{nargout-2}=bckgrndEvntChans;
end

if nargout>=2
    varargout{nargout-1}=evntChans;
end

if nargout==3
    varargout{nargout}=inputFilename;
end

if nargout>3
    disp('Too many outputs specified')
end
    
