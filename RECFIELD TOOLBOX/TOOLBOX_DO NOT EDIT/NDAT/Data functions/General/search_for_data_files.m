function [listdir,listfiles]=search_for_data_files(directory,exts)
listfiles={};
listdir={};

for i=1:length(exts)
    [listdirt,listfilest]=search_files(directory,exts{i});
    listdir=cat(1,listdir,listdirt);
    listfiles=cat(1,listfiles,listfilest);
end