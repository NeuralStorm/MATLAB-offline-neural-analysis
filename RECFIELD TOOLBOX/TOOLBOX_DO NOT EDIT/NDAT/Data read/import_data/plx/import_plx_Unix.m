function data = import_plx_Unix(filename, ch, u)

% plx_ts(filename, channel, unit): Read spike timestamps from a .plx file
%
% [n, ts] = plx_ts(filename, channel, unit)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   channel - 1-based channel number
%   unit  - unit number (0- invalid, 1-4 valid)
% OUTPUT:
%   n - number of timestamps
%   ts - array of timestamps (in seconds)


if(nargin ~= 3)
   disp('3 input arguments are required')
   return
end

n = 0;
ts = 0;
if(length(filename) == 0)
   [fname, pathname] = uigetfile('*.plx', 'Select a plx file');
	filename = strcat(pathname, fname);
end

fid = fopen(filename, 'r');
if(fid == -1)
	disp('cannot open file');
   return
end

%disp(strcat('file = ', filename));

% read file header
header = fread(fid, 64, 'int32');
freq = header(35);  % frequency
ndsp = header(36);  % number of dsp channels
nevents = header(37); % number of external events
nslow = header(38);  % number of slow channels
npw = header(39);  % number of points in wave
npr = header(40);  % number of points before threshold
tscounts = fread(fid, [5, 130], 'int32');
wfcounts = fread(fid, [5, 130], 'int32');
evcounts = fread(fid, [1, 512], 'int32');

% skip variable headers 
fseek(fid, 1020*ndsp + 296*nevents + 296*nslow, 'cof');
[unit,channel]=find(tscounts~=0);
tscountu=sparse(max(unit),max(channel)-1);
tscountnum=tscountu;

%initializing variable to import

switch 




for e=1:length(channel)
    data.Neurons(e).ts=zeros(tscounts(unit(e),channel(e)),1);
    data.Neurons(e).channel=channel(e)-1;
    data.Neurons(e).unit=unit(e)-1;
    tscountu(unit(e),channel(e)-1)=1;
    tscountnum(unit(e),channel(e)-1)=e;
end

% read the data
Neurons=[];
while feof(fid) == 0
    arrvar=fread(fid, 8, 'ubit16');
    % 	type = fread(fid, 1, 'int16');
    % 	upperbyte = fread(fid, 1, 'int16');
    % 	timestamp = fread(fid, 1, 'int32');
    % 	channel = fread(fid, 1, 'int16');
    % 	unit = fread(fid, 1, 'int16');
    % 	nwf = fread(fid, 1, 'int16');
    % 	nwords = fread(fid, 1, 'int16');
    if isempty(arrvar)
        break
    end
    %     type = arrvar(1);
    %     upperbyte = arrvar(2);
    %     timestamp = upperbyte*2^32+arrvar(4)*2^16+arrvar(3);
    %     channel = arrvar(5);
    %     unit = arrvar(6);
    %     nwf = arrvar(7);
    %     nwords = arrvar(8);
    %     toread = nwords;
    if arrvar(8) > 0
        %wf = fread(fid, toread, 'int16');
        fseek(fid,arrvar(8)*2,0);
    end
    if arrvar(1) == 1
        if sum(arrvar(5) == ch) >=1
            if sum(arrvar(6) == u(arrvar(5) == ch)) ==1
                
                Neurons(tscountnum(arrvar(6)+1,arrvar(5))).ts...
                    (tscountu(arrvar(6)+1,arrvar(5)))=...
                    (arrvar(2)*2^32+arrvar(4)*2^16+arrvar(3))/freq;
                tscountu(arrvar(6)+1,arrvar(5))=...
                    tscountu(arrvar(6)+1,arrvar(5))+1;
                   
            end
        end
    end
    
    
    if feof(fid) == 1
        break
    end
    
end
%disp(strcat('number of timestamps = ', num2str(n)));



fclose(fid);