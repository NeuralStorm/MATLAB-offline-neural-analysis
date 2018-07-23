function [fields,values]=get_file_info(filename,format)

filename(strfind(filename,'_'))='.';
format(strfind(format,'_'))='.';
%exctracting format
[fields]=regexpi(format,'(?<fields>[a-zA-Z_0-9\-]+)\.|(?<fields>\s+)\.','tokens');

[values]=regexpi(filename,'(?<fields>[a-zA-Z_0-9\-]+)\.|(?<fields>\s+)\.','tokens');
h=1;
toel=[];
for i=1:length(fields)
    currentfield=fields{i}{1};
    currentvalue=values{i}{1};
    values{i}=currentvalue;
    fields{i}=currentfield;
    if strcmpi(currentfield,' ')
        toel=[toel,i];

    else
        if i>1
            if strcmpi(currentfield,fields{i-1})
                toel=[toel,i];
                values{i-1}=[values{i-1},'.',values{i}];
            end
        end


    end
    

end
values(toel)=[];
fields(toel)=[];
values=values(1:length(fields));