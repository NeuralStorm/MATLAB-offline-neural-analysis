function [] = parser()

    %%
    % Give single .plx file
    [file,path]=uigetfile('*.plx');
    
    % TODO fix it so that file is placed into a parsed directory
    %directory_path = strcat(path, 'parsed_plx');
    %if ~exist(directory_path, 'dir')
    %    mkdir('parsed_plx');
    %end
    

    % Take the spike times and event times
    datafile = [path,file];
    [tscounts, wfcounts, evcounts, slowcounts] = plx_info(datafile,1);
    filename = replace(file, '.plx', '.mat');
    save(filename, 'tscounts', 'wfcounts', 'evcounts', 'slowcounts');
end