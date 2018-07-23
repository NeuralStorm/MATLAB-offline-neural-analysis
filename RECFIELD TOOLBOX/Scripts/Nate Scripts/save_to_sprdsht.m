function [ output_args ] = save_to_sprdsht(file,filetype,savefldr,varargin)
%SAVE_TO_SPRDSHT saves analyses output to excel spreadsheet
%
%     Converts outputs from the "tilt_recfield" and "tilt_discrimination"
%     functions into excel spreadsheets
%
%     Syntax:
%
%         SAVE_TO_SPRDSHT(FILE,FILETYPE,SAVEFLDR) converts specified
%         FILE into an excel spreadsheet and saves into a specified folder
%         (SAVEFLDR)depending on the FILETYPE.
%
%         SAVE_TO_SPRDSHT(FILE,FILETYPE,SAVEFLDR,FORMAT) saves file into an
%         additional alternate file format (e.g. .mat) in addition to
%         performing actions specified above
%
%
%     Inputs:
%
%         FILE is a string of full filename to be saved
%
%         FILETYPE is a string describing the analysis the file came from.
%         Currenty file types include 'RecField', 'tiltDicrimination' and
%         'tiltDetection'
%
%         SAVEFLDR is a string specifying which folder the converted file
%         is to be saved
%
%         FORMAT is a string specifying the type format you want to save
%         the file in (in addition to .xls).  '.mat' format currently the
%         only supported format
%
%     See also tilt_recfield, tilt_discrimination.
%$Rev: 121 $
%$Author: Nate $
%$LastChangedDate: 2017-03-24 09:49:04 -0400 (Fri, 24 Mar 2017) $

%ASSIGN VARIABLE NAMES
for variablename=1:2:size(varargin,2)-1
    feval(@()assignin('caller',varargin{variablename},varargin{variablename+1}))
end
fileformat=[];

%RecField
if strcmpi(filetype,'RecField')
    
    directory=cd(savefldr);
    direlements=dir(directory);
    samplefilename=direlements(end-1).name;
    disp(samplefilename);
    
    if ~exist('label','var')
        label=input('Type Filename (".xls" extension required) ', 's');
    end
    export(file,'XLSFile',label);
    disp('RecField file saved');
    
    %Tilt Discrimination
elseif strcmpi(filetype,'tiltDicrimination')
    
    % user-defined variables (or columns) to be removed from saved file
    %(should become a function input)
    variablesRemove={'ConfusionMatrix','Classes','Intervals',...
        'Errors'};
    
    
    % extract and display sample file name
    directory=cd(savefldr);
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    
    % ask user to type filename of file to be saved
    if ~exist('label','var')
        label=input('Type Filename: ', 's');
    end
    
    % extract column header text from dataset file
    colHdrs=get(file,'VarName');
    
    % remaining variables (or columns) that will be saved
    variablesKeep=~ismember(colHdrs,variablesRemove);
    
    % remove variables headers not to save
    colHdrsAdj=colHdrs(variablesKeep);
    
    % remove variable information not to save
    fileAdj=file(:,variablesKeep);
    
    % apply default save version if not specified
    if ~exist('saveVersion','var')
        saveVersion='v1';
    end
    
    if strcmpi(saveVersion,'v1')
        % order of variables in saved spreadsheet
        variableOrder={'Info_Ensemble',	'Performance',...
            'RegionOfElectrode','Binsize','Pretime','Posttime',...
            'animal', 'date', 'day', 'exp', 'study',...
            'NumCells', 'NumEvents', 'NumBootstraps', 'Info_SingNeurn',...
            'EventNums', 'First_Trial', 'Last_Trial', 'SynRed_Bet_Hemi',...
            'NeuronType', 'AnimalGroup', 'P_', 'Completed',...
            'neuronType_Code', 'neuronGroup_Code', 'animalGroup_Code',...
            'CellName', 'NeurnInfoVector', 'NeurnInfoVector_Bootstrpd',...
            'NeurnPerfVector', 'NeurnPerfVector_Bootstrpd',...
            'Day_w_LastBaseline',...
            'Experiment', 'Pair', 'Info_SingNeurn',...
            'Info_SingNeurn_Bootstrppd',...
            'Info_SingNeurn_Bootstrppd_Corrctd','Perf_Ensmble_Boostrpd',...
            'NeurnInfoVector_Corrected','Info_Ensmble_Bootstrpd',...
            'NeurnInfoVector_Corrected_mean_centered_Day0',...
            'NeurnInfoVector_Corrected_zscore_Day0',...
            'NeurnInfoVector_Corrected_ratio_Day0'};
        
        % indices needed to extract relevant variables
        fileAdjInd=cellfun(@(x) find(strcmpi(colHdrsAdj,x)),...
            variableOrder,'UniformOutput',false);
        
        % cell array of logical values corresponding to relevant variables
        cells=cellfun(@isempty,fileAdjInd,'UniformOutput',false);
        
        % indices needed for extraction in double format
        cellInds=find(~[cells{:}]);
        
        % convert dataset into a cell
        cellFile=dataset2cell(fileAdj);
        
        % create file to be saved
        excelFile(:,cellInds)=cellFile(:,[fileAdjInd{:}]);
        
        
        % logical array/mask corresponding to "EventNums" header
        evntNumsCol=cellfun(@(x) find(strcmpi(excelFile(1,:),x)),...
            {'EventNums'},'UniformOutput',false);
        
        % logical array/mask corresponding to actual "EventNums"
        evntNums=excelFile(2:end,evntNumsCol{:});
        
        % convert "EventNums" to string
        evntNums2str=cellfun(@mat2str,evntNums,'UniformOutput',false);
        
        % replace original "EventNums" to those converted into string
        excelFile(2:end,evntNumsCol{:})=evntNums2str;
        
        % extract animal number and dates 
        IDs=cellfun(@(x) str2double(x),excelFile(2:end,[7,8]),'UniformOutput',false);
        
        % additional columns for finding unique recordings 
        uniqueColIDs=[1,2,12];
        
        % matrix of identifiers used for finding unique recordings
        colIDmat=[excelFile(2:end,uniqueColIDs),IDs];
        
        % identify unique rows
        [~,uniqueRow]=unique(cell2mat([excelFile(2:end,uniqueColIDs),IDs]),'rows');
        
        % pre-allocate offline performance filter column with zeros
        excelFileAppend=zeros(size(excelFile,1),1);
        
        % define relevant rows with "1"
        excelFileAppend(uniqueRow+1,:)=1;
        
        % convert to cell
        excelFileAppendCell=num2cell(excelFileAppend)
        
        % add heading
        excelFileAppendCell{1}='OfflinePerformanceFilter';
        
        % create new excel file
        excelFile=[excelFile,excelFileAppendCell];
        
        
    else
        % inform user that save version not specified
        error('An appropiate save version was not specified')
    end
    
    % save extracted dataset as excel file
    xlswrite([label,'.xls'],excelFile);
    disp('Tilt discrimination excel file saved');
    
    % save in alternate format
    if nargin>=1
        % save as .mat file
        if strcmpi('-mat',varargin{1})
            save([label,'.mat'],'file')
            disp('Tilt discrimination .mat file saved');
        end
        % alternate formats...
    end
    
    %Tilt Detection
elseif strcmpi(filetype,'tiltDetection')
    
    directory=cd(savefldr);
    direlements=dir(directory);
    samplefilename=direlements(end).name;
    disp(samplefilename)
    label=input('Type Filename (".xls" extension required) ', 's');
    
    file=[file(:,1) file(:,2) file(:,5) ...
        file(:,6) file(:,8) file(:,9) file(:,10)...
        file(:,11) file(:,12) file(:,13)...
        file(:,14) file(:,15) file(:,16)...
        file(:,17) file(:,18) file(:,19)];
    
    export(file,'XLSFile',label);
    disp('Tilt detection file saved');
    
else
    disp('Input not recognized')
end

end

