function plx_Online(varargin)
% Adds the Plexon ClientSDK folder to the current directory and adds it to
% the MATLAB search path.
%
% Note: This function is not fully documented and is planned to be removed
% soon. The ClientSDK folder needs to be incorporated into the NeuroToolbox
% project in a more intelligent way
%   Mike Meyers - 05/21/2015

clear mex

currFile = mfilename('fullpath');
lastSep = find(currFile==filesep,1,'last');
currDir = currFile(1:lastSep);
onlineFolder = [currDir,'ClientSDK',filesep];

firstPlus = find(currDir=='+',1,'first');
parentDir = currDir(1:firstPlus-2);
newFolder = [parentDir,filesep,'ClientSDK',filesep];

if nargin >=1
    if varargin{1}
        copyfile(onlineFolder,newFolder);
        addpath(newFolder);
    else
        rmpath(newFolder);
        rmdir(newFolder,'s');
    end
else
    
    pathCell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive
        onPath = any(strcmpi(newFolder(1:end-1), pathCell));
    else
        onPath = any(strcmp(newFolder(1:end-1), pathCell));
    end
    
    if onPath
        rmpath(newFolder);
        rmdir(newFolder,'s');
    else
        copyfile(onlineFolder,newFolder);
        addpath(newFolder);
    end
    
end


end