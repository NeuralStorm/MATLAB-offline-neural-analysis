%TILT_EVNT_FORMATTER formats matnd events for tilt experiments
%
%     Extracts relevant time stamps for tilt experiments and adds
%     background events that correspond to some time prior to event time
%     stamps
%
%     Syntax:
%
%         TILT_EVNT_FORMATTER(’parameter_1’,value_1,'parameter_2',
%         value_2…) append parameter-value pairs after the required
%         arguments. You can list several pairs in series. See
%         Parameter-value pairs section below for a list of parameters
%         that can be used.
%
%     Parameter-value pairs:
%
%         Parameter-value pairs can be used after the required inputs to
%         specify the following parameters. Enter the name as a string
%         followed by the value for that parameter. The following
%         parameters are valid
%
%         ‘Parameter_1’ – description of parameter description of parameter
%         description of parameter description of parameter description of
%         parameter description of parameter description of parameter
%         description of parameter
%
%         ‘Parameter_2’ - description of parameter description of parameter
%         description of parameter description of parameter description of
%         parameter description of parameter
%
%
%     See also FUNCTION1, FUNCTION2, FUNCTION3.
%
%    $Rev:  $
%    $Author: Nate $
%    $LastChangedDate: 2016-06-15 18:09:33 -0400 (Wed, 15 Jun 2016) $


%Nathaniel Bridges

%Description: takes in output from GUI import and formats for the
%PSTH_Classification Analysis script

%update:  more flexible to differnt number of tilt events, converted into a
%function

%update date: 3/25/15

%update: everything in setup is defined by an input to the function for
%modularity between Ravi and Nate's computer


function varargout = tilt_evnt_formatter(varargin)

%ASSIGN VARIABLE NAMES
for variablename=1:2:size(varargin,2)-1
    feval(@()assignin('caller',varargin{variablename},varargin{variablename+1}))
end


%DEFAULTS
if ~exist('dataDir','var')
    dataDir='C:\';
    disp(['Default ',dataDir, ' used']);
end

if ~exist('saveDir','var')
    saveDir='C:\';
    disp(['Default ',saveDir, ' used']);
end

if ~exist('timestampNum','var')
    timestampNum=1;
    disp(['Default timestamp number: ',num2str(timestampNum), ' used']);
end


if ~exist('backgrndWin','var')
    backgrndWin=1;
    disp(['Default background window: ',num2str(backgrndWin), ' used']);
end

if ~exist('batchDir','var')
    batchDir='No';
    disp(['Default background window: ',num2str(backgrndWin), ' used']);
else
    
    tiltEventsInput={1,batchDir};  %fix
    
end

if ~exist('GUI_Import','var')
    GUI_Import='No';
else
    % determine data structure indices
    dataIndCell=cellfun(@(x) isfield(x,'Events'),GUI_Import,...
        'UniformOutput', false);
    
    % create logical array
    dataLogical=logical([dataIndCell{:}]);
    
    % extract data structure
    data=GUI_Import(dataLogical);
    nonData=GUI_Import(~dataLogical);
    data=data{:};
    
    % extract experiment label string
    Explab=nonData(strcmpi(nonData,'exp.ratid.type.week.date.'));
    Explab=Explab{:};

    
    % extract filename string
    fileNames=nonData(~strcmpi(nonData,'exp.ratid.type.week.date.'));
    
    
    % activate save into workspace code feature 
    shouldSave='Yes';
    

end

if ~exist('shouldSave','var')
    shouldSave='Yes';
end


if  ~exist('dataToWorkspace','var')
    dataToWorkspace='No';
end

if ~exist('matndFile','var')
    matndFile='No';
else
    fileNames=matndFile;
    GUI_Import='Yes';
end


%% Import Data
disp('Formatting data...')

if strcmpi(GUI_Import,'No') && strcmpi(matndFile,'No')
    if ~strcmpi(batchDir,'No')
        
        
        % extract filenames from batch folder
        [~,~,filenameInfo]=...
            tilt_evnts(batchDir);
        
        % break file name and path into parts
        [filePath,fileName,fileExt] = cellfun(@fileparts,filenameInfo,...
            'UniformOutput',false);
        
        % matrix of dimension value for concatenation
        catDim=cell(size(fileName,1),size(fileName,2));
        catDim(:)={2};
        
        % define filename
        fileNames=cellfun(@cat,catDim,fileName,fileExt,...
            'UniformOutput',false);
        
        
    else
        % ask user to select file
        [fileNames,filePath,~]=uigetfile([dataDir,'*matnd']);
        
        % convert into a cell
        fileNames={fileNames};
    end
end

for file=1:size(fileNames,1)
    
    if strcmpi(GUI_Import,'No')
    data=load([filePath{file},'\',fileNames{file}],...
        '-mat','Explab','Channels','Events');
    Explab=data.Explab;
    end
    
    if exist('data','var')
       
        if isfield(data,'Explab')
            Explab=data.Explab;
        end
        
        if isfield(data,'Channels')
            Channels=data.Channels;
        end
        
        if isfield(data,'Events')
            Events=data.Events;
        end
    end
    
    
    if exist('matnd_Chan','var')
        Channels=matnd_Chan;
    end
    
    if exist('matnd_Events','var')
        Events=matnd_Events';
    end
    
    if exist('matnd_Explab','var')
        Explab=matnd_Explab;
    end
    

    
    
    
    
    disp('Data import finished')
    %% 1st Timestmps
    tiltnum=size(Events,2)-2;
    
    % move "start" and "end" data to the end of the matrix
    Events(2*tiltnum+1).name=Events(tiltnum+1).name;
    Events(2*tiltnum+2).name=Events(tiltnum+2).name;
    
    Events(2*tiltnum+1).channel=2*tiltnum+1;
    Events(2*tiltnum+2).channel=2*tiltnum+2;
    
    Events(2*tiltnum+1).ts=Events(tiltnum+1).ts;
    Events(2*tiltnum+2).ts=Events(tiltnum+2).ts;
    
    for i=1:tiltnum
        
        % names
        %Events(i).name=tilt_names{i};   was intended for defined tilt names
        Events(i+tiltnum).name=[Events(i).name,'_background'];   %names for background events
        
        % channels
        Events(i).channel=i;
        Events(i+tiltnum).channel=i+tiltnum;
        
        % timestamps
        ts_temp=Events(i).ts(1:timestampNum:end);
        Events(i).ts=[];
        Events(i).ts=ts_temp;
        Events(i+tiltnum).ts=ts_temp-backgrndWin; %subtracting 1 second for background event ts
        
    end
    
    
    %% Save Files
    if strcmpi(shouldSave,'Yes')
        
        
        
        if iscell(fileNames)
            fileNames=fileNames{file};
        end
        
        if iscell(saveDir)
            
            for directory=1:length(saveDir)
                cd(saveDir{directory})
                save(fileNames,'Events','Channels','Explab')
                
            end
            
        else
            save(fileNames,'Events','Channels','Explab')
        end
       
       
        disp('Event conversion finished and saved')
    end
    
    %% Save Data in Workspace
    if strcmpi(dataToWorkspace,'Yes')
        
        if exist('Explab','var')
            data.Explab=Explab;
        end
        
        if exist('Channels','var')
            data.Channels=Channels; 
        end
        
        if exist('Events','var')
            data.Events=Events;
        end
        
        varargout{1}=data;
    end
    
end
