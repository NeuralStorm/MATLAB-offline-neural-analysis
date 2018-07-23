function data=import_data(filename,options)

%


%% determining operating system 1=Linux; 2=Mac; 3=Windows;
if isfield(options,'OS')
    OS=options.OS;
    
else
    if ispc
        options.OS=3;
    elseif ismac
        options.OS=2;
    else
        options.OS=1;
    end
end

%% Determing Correct Engine
% Put your import finction here, make sure the file extension is correct.

switch options.import_engine
    
    case '.plx'
        
        
        data=import_plx(filename,options);
        
        
    otherwise
        
        disp('Import engine not found, nothing to do')
end