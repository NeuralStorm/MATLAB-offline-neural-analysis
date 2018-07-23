function  [tscounts, wfcounts, evcounts ]= plx_info_personal(filename, fullread)
% plx_info(filename, fullread) -- read and display .plx file info
%
% [tscounts, wfcounts, evcounts] = plx_info(filename, fullread)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   fullread - if 0, reads only the file header
%              if 1, reads all the file
% OUTPUT:
%   tscounts - 5x130 array of timestamp counts
%      tscounts(i, j) is the number of timestamps for channel i, unit j
%   wfcounts - 5x130 array of waveform counts
%     wfcounts(i, j) is the number of waveforms for channel i, unit j
%   evcounts - 1x512 array of external event counts
%     evcounts(i) is the number of events for channel i
%
% Note that for tscounts, wfcounts, the unit,channel indices i,j are off by one. 
% That is, for channels, counts for channel n is at index n-1, and for units,
%  index 1 is unsorted, 2 = unit a, 3 = unit b, etc
% If a fullread is done, the first dimension is 27 instead of 5, to handle more units


fid=fopen(filename);
fseek(fid,136,'cof');
out.frchevad=fread(fid,[1,4],'int');
fseek(fid,8,'cof');
out.datearr=fread(fid,[1,3],'int');
fseek(fid,192,'bof');
out.duration=fread(fid,1,'double')/out.frchevad(1);
fseek(fid,256,'bof');
tscounts=(fread(fid,[5,130],'int'));
wfcounts=(fread(fid,[5,130],'int'));
evcounts=(fread(fid,[1,512],'int'));
fclose(fid);