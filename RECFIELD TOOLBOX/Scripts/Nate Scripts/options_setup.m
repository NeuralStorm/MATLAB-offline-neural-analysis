function [options, directories] = options_setup(varargin)
%OPTIONS_SETUP outputs 'options' used by RecField and Information analyses
% 
%     This function is designed to output a structure array which comprises
%     all of the appropiate variables and/or parameters (e.g. bin size) 
%     used by the "Rec_Field_Analysis" and "PSTH_Classification_Analysisv2" 
%     functions.  If the user does not specify function inputs, the 
%     function will output programmed defaults.   
%     
%     Syntax:
%     
%         options_setup(…,’parameter_1’,value_1,'parameter_2',value_2…)
%         append parameter-value pairs after the required arguments. You
%         can list several pairs in series. See Parameter-value pairs
%         section below for a list of parameters that can be used.  All
%         input parameter-value pairs are saved into the base workspace
%         (such that they can be passed into other functions) and saved in
%         a cell output
%     
%     Outputs:
%     
%         OPTIONS is a structure array of Rec_Field_Analysis" and 
%         "PSTH_Classification_Analysisv2" function inputs
% 
%         DIRECTORIES is an N x 2 cell matrix, where N corresponds to the 
%         number of parameter-value pairs. The first and second columns 
%         correspond to the 'parameter' and 'value' respectfully
%     
%     Parameter-value pairs:
%     
%         Parameter-value pairs can be used after the required inputs to
%         specify the following parameters. Enter the name as a string
%         followed by the value for that parameter. The following
%         parameters are valid
% 
%         ‘experimenttype’ – defines (string) what experiment future 
%         analyses will be used for.  'RAVInew', is currently the only 
%         option.  Default is 'RAVInew'
% 
%         ‘preTime’ - time in milliseconds (integer) prior to event that is 
%         considered for analysis.  Default is 200
%
%         ‘postTime’ - time in milliseconds (integer) after event that is 
%         considered for analysis.  Default is 200
%
%         'bin' - binsize (integer) used by analysis in milliseconds  
%         Default is 1
%
%         'regionName'- is the name (string) of the brain region where electrodes
%         were placed to acquire the data used for analysis.  Default is
%         'CTX'
%
%         'binArray' - is an array (integers) of bin sizes in milliseconds.  
%         The analysis will be performed independently for each bin size
%
%         'fileInfo'- is a string of labels (string) pulled from the file
%         name that will serve as column headers in the dataset output.
%         Each column header is delimited by '.' in the input string while
%         the rows beneath each header are pulled from the filename with
%         the same structure.  For example, the input string and filename 
%         may be defined as 'exp.ratid.type.week.date' and 
%         'RAVI.009.Test.Week0.072015.xls' respectfully.  Default is 
%         'exp.ratid.type.week.date'
%
%         'bootstrap'- user types 'Yes' or 'No' (string) to indicate 
%         whether bootstrapping will be performed.  Default is 'Yes'
%
%         'bootstrapNum'- number of times (integer) bootstrapping performed.
%         Default is 20.
%
%         'synRed'- activates (1) or deactivates (0) option for
%         synergy/redundancy calculations.  Default is to not use this 
%         the synergy/redundncy option.
%
%         'multipleIterations'-
%
%         'password'- is the password (string) used for email account if user 
%         desires update emails on analysis progress.  Current code only 
%         supports gmail.
%
%         'PC'- specifies the computer being used (string) if the user desires to
%         use auxillary functions or scripts specific to particular
%         computers or operating systems.  Default is 'natePC'
%
%         'region'-cell array/matrix (cell) that specifies which electrode channels are 
%         used for analysis.  If a 1xN matrix is setup, analysis will be
%         performed on seperately for each column (i.e. cell), which can
%         contain either an array of channels or a single one.  
%         Default are channels 1:16 and 17:32 (for first and second
%         analysis respectfully)
%
%         'regionName'-cell array/matrix of string(s) (cell) that correspond to
%         the channels specified by 'region' (see above).  Default is
%         'Right Hemisphere' and 'Left Hemisphere' (for the first and
%         second analysis respectfully)
%
%         'p-value'-alpha decision criterion (integer) required for determining
%         t-test significance when comparing the background and response
%         windows of individual neurons (only applies to 
%         "Rec_Field_Analysis" function).  Default is 0.001
%
%         'tiltYes'-executes code written (string) specifically to handle tilt
%         experiments (applies only to "Rec_Field_Analysis" function).  Supported
%         inputs include: 'Ravi' and 'CSR'
%         Default is 'tiltYes' for 'Ravi'
% 
%         'tiltNo'-executes generalized (string) code (applies only to "Rec_Field_Analysis" function).  
%         Default is 'tiltYes'
%
%         'respWindow'- window of time in milliseconds where binned firing
%          rates are considered significantly greater than the background
%          response window (i.e. "responsive bins").  This is useful for 
%          excluding bin(s) containing a known stimulus artifact occuring  
%          prior to the neural response.  Default is 1 ms to the
%          user-specified post window (i.e. response window edge)
%
%     See also Rec_Field_Analysis, PSTH_Classification_Analysisv2, FUNCTION3.
%$Rev: 119 $
%$Author: Nate $
%$LastChangedDate: 2017-03-23 22:41:57 -0400 (Thu, 23 Mar 2017) $


%ASSIGN VARIABLE NAMES
for variablename=1:2:size(varargin,2)-1
    feval(@()assignin('caller',varargin{variablename},varargin{variablename+1}))
end


%DEFAULTS
if ~exist('experimenttype','var')
    experimenttype='RAVInew';
    disp(['Default ',num2str(experimenttype), ' experiment type used']);
end

if ~exist('preTime','var')
   options.pretime=.200;
    disp(['Default ',num2str(options.pretime), ' pretime window used']);
else
    options.pretime=preTime/1000;
    disp(['User-specified ',num2str(options.pretime),' ms pretime used'])
end

if ~exist('postTime','var')
   options.posttime=.200;
    disp(['Default ',num2str(options.posttime), ' posttime used']);
else
    options.posttime=postTime/1000;
    disp(['User-specified ',num2str(options.posttime),' ms posttime used'])
end

if ~exist('bin','var')
  options.bin=.002;
    disp(['Default ',num2str(options.bin), ' bin size used']);
end

if ~exist('regionName','var')
options.regionname={'CTX'};
    disp('Default "CTX" region name used');
end

%inputs are in mseconds
if ~exist('binArray','var')
    options.binsizean=[1 2 20]/1000;
    disp(['Default ',num2str(options.binsizean), ' bin size(s) used']);
else
    options.binsizean=binArray./1000;
    disp(['User-specified ',num2str(binArray),' bin size(s) used'])
end

if ~exist('fileInfo','var')
  options.fileinfostring='exp.ratid.type.week.date';
    disp(['Default ',num2str(options.fileinfostring), ' used']);
end

if ~exist('bootstrap','var')
  options.bootstrapped = 1;
    disp(['Default ',num2str(options.bootstrapped), ' used']);
end

if ~exist('bootstrapNum','var')
  options.bootstrapnum=20;
    disp(['Default ',num2str(options.bootstrapnum), ' used']);
else
    options.bootstrapnum=bootstrapNum;
end


if ~exist('synRed','var')
    options.synred = 0;
elseif exist('synRed','var') && strcmpi(synRed,'No')
    options.synred = 0;
elseif exist('synRed','var') && strcmpi(synRed,'Yes')
    options.synred = 1;
    disp('Synergy/redundancy option used')
else
    disp('Unrecognized input')
end

if ~exist('multipleIterations','var')
options.multipleIterations=1;
    disp(['Default ',num2str(options.multipleIterations), ' used']);
end

if ~exist('password','var')
    password='F:\Projects\Combined Projects\Exported Data';
    disp(['Default ',num2str(password), ' password used']);
end

if ~exist('PC','var')
    PC='natePC';
    disp(['Default ',num2str(PC), ' password used']);
end

if ~exist('region','var')
    options.region={1:16,17:32};
    disp('Default ch. 1-16 & 17-32 regions used');
else
    options.region=region;
    disp('User-defined region(s) used')
end

if ~exist('regionName','var')
    options.regionname={'Right Hemisphere','Left Hemisphere'};
    disp('Default right and left hemisphere labels used');
else
    options.regionname=regionName;
    disp('User-defined region name used')
end

if exist('trials','var')
    options.trials=trials;
    disp('User-defined trial(s) used')
end

if exist('synBetween','var')
    options.synBetween=synBetween;
end

if exist('BMIkey','var')
   options.BMIkey=BMIkey; 
end

% cell array where each cell contains matrix where each column compared
% {[1,2;3,4]} 1 vs 2 and 3 vs 4
if exist('eventComparisons','var')
    options.eventComparisons=eventComparisons;
end

%% RecField Analysis-specific options

if ~exist('units','var')
    options.units='probability';
    disp(['Default "',options.units,'" units used'])
else
    options.units=units;
    disp(['User-defined "',units,'" units used'])
end


if ~exist('pValue','var')
    options.pvalue=0.001;
    disp('Default 0.001 p-value used')
else
    options.pvalue=pValue;
    disp('User-defined p-value used')
end

if ~exist('tiltYes','var')
    options.TILT = 'RAVI';
    disp('Default tilt-specific analysis used')
elseif exist('tiltYes','var')
    options.TILT = tilt;
    disp('User-defined tilt-specific analysis used')
elseif exist('tiltNo','var')
    %do not define options.TILT
    disp('Tilt-specific code not specified')
else
    disp('Unrecognized input')
end

%allows user to select window following stimulus to consider bins "responsive"  
if ~exist('respWindow','var')
    options.response=[0.001 options.posttime]; %note: CSR study used: [.001 options.posttime];
    disp(['Default ',num2str(options.response),' window used']);
else
    options.response=[respWindow(1),respWindow(2)];
    disp(['User-defined ',num2str(respWindow(1)),' ',...
        num2str(respWindow(2)),' window used'])
end

%Recfield plots generated & saved here
if ~exist('saveFigFldr','var')
     options.saveFigFldr='C:\';
else
    options.saveFigFldr=saveFigFldr;
end
%%
%current variables in workspace
varlist=who;

%save and assign fcn variables to base workspace
for variable=1:size(varlist,1)
    directories{variable,1}=varlist{variable};
    directories{variable,2}=eval(varlist{variable});
    assignin('base',varlist{variable},eval(varlist{variable}))
end
end






