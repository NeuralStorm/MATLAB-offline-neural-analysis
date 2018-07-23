function [fields,values]=get_file_info(filename,format)
[dir,filename,ext]=fileparts(filename);
filename=[filename,ext];
filename(strfind(filename,'_'))='.';
format(strfind(format,'_'))='.';
%exctracting format
[fields]=regexpi(format,'(?<fields>[a-zA-Z_0-9()\-]+)\.|(?<fields>\s+)\.','tokens');

[values]=regexpi(filename,'(?<fields>[a-zA-Z_0-9()\-]+)\.|(?<fields>\s+)\.','tokens');
values=[values{:}];
h=1;
toel=[];
[fieldslist,poslist]=unique([fields{:}]);
for i=1:length(fieldslist)
    pos=strcmpi(fieldslist(i),[fields{:}]);
    if sum(pos)<=1
        valuest{i}=values{poslist(i)};
    else
        valuest{i}=cat(2,[values{pos}]);
        
    end
    
end
values(toel)=[];
fields=fieldslist;
values=valuest;
1;
values(strcmpi(fields,'d'))=[];
fields(strcmpi(fields,'d'))=[];