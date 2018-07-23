function [varargout] = TiltEventsforAnalysis(varargin)
%UNTITLED2 Summary of this function goes here
%varargin{1}=filename/'batch'  
%varargin{2}=filefolder
%if one input: assumes batch processing
%if two input: assumes analyzing specified file (filename, filefolder)
%or if two input: (fullfilename, 'Full')
%inputFilename,evntChans,bckgrndEvntChans

clear inputFilename options.evchannels


% numInputs=find(~cellfun(@isempty,varargin{1}));
% numInputs=numInputs(end);

if nargin==0 
    
    [fileName,batchFolder,~] = uigetfile('\*.matnd');
    files=[1];
    file=0;

elseif nargin==1 
    fullFiles=dir(varargin{1});
    files=fullFiles(3:end).name;
    file=0;


elseif nargin==2 
    if ~strcmpi(varargin{2},'Full')   
    fileName=varargin{1};
    batchFolder=varargin{2};
    end
    
    files=[1];
    file=0;


else 
    disp('Too many inputs specified')

     
    
end
        


for fileRange=1:length(files)
    
    if nargin==1 
    %Cell of file name(s) for analysis
    fileName=files(fileRange).name;
    end
    
    if nargin>=2 && strcmpi(varargin{2},'Full')
        fullFilename=varargin{1};
    else
    fullFilename=[batchFolder,fileName];
    end
    
    file=file+1;
    inputFilename{file,1}=fullFilename;
    
    %Determine no. of tilts events from recording
    load(fullFilename,'-mat');
    tiltTotal=length(regexpi([Events.name],'5|6|7|8|9|10'))/2;
    
    %Stores event channel #s for each file for indexed access
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
    
