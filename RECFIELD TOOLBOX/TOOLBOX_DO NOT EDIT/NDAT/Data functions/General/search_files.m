function [listdir,listfiles]=search_files(directory,ext)

if nargin==1
    ext='.plx';
elseif nargin<1
    ext='.plx';
    directory=uigetdir;
end

if isempty(directory)
    directory=pwd;
end
listdir={};
listfiles={};



allsubdir=genpath(directory);
if isunix
    sep=':';
else
    sep=';';
end

path_pos=find(allsubdir==sep);
path_pos=[0 path_pos];

for i=1:length(path_pos)-1
    
    currdir=allsubdir(path_pos(i)+1:path_pos(i+1)-1);
    filesindir = dir(currdir);
    numdir=size(filesindir,1);
    
    if numdir>=3
        
        flip_namefiles=cellfun(@fliplr, {filesindir.name},'UniformOutput', false);
        x = strmatch(fliplr(ext),flip_namefiles);
        if isempty(x)~=0
        else
            listdir=cat(1,listdir,currdir);
            for j=1:length(x)
                listfiles=cat(1,listfiles,{[currdir,filesep,filesindir(x(j)).name]});
            end
        end
        
    end
    
end
if nargout==1 % changed from nargout ==0 , by Anitha Manohar
    listdir=listfiles;
end

   