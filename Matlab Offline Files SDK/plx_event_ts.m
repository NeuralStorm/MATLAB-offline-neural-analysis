function [n, ts, sv] = plx_event_ts(filename, channel)
% plx_event_ts(filename, channel): read event timestamps from a .plx or .pl2 file
%
% [n, ts, sv] = plx_event_ts(filename, channel)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   channel - 1-based external channel number or channel name
%             strobed channel has channel number 257  
%
% OUTPUT:
%   n - number of timestamps
%   ts - array of timestamps (in seconds)
%   sv - array of strobed event values (filled only if channel is 257)

n = 0;
ts = -1;
sv = -1;

if nargin ~= 2
    error 'expected 2 input arguments';
end

[ filename, isPl2 ] = internalPL2ResolveFilenamePlx( filename );

channelNumber = plx_event_resolve_channel(filename, channel);
if channelNumber == -1
    fprintf('\n plx_event_ts: no header for the specified event channel.\n');
    return
end

if isPl2 == 1
    % the code here is only to support legacy scripts with plx_* APIs 
    % when working with .plx and .pl2 files generated by OmniPlex.
    if channelNumber == 257
        event = PL2EventTs(filename, 'Strobed');
        if numel(event.Ts) > 0
            n = numel(event.Ts);
            ts = event.Ts;
            sv = event.Strobed;
        end
        return
    end
    if channelNumber == 258
        ts = PL2StartStopTs(filename, 'start');
        n = numel(ts);
        sv = 0;
        return
    end
    if channelNumber == 259
        ts = PL2StartStopTs(filename, 'stop');
        n = numel(ts);
        sv = 0;
        return
    end
    pl2 = PL2GetFileIndex(filename);
    for i=1:numel(pl2.EventChannels)
        if pl2.EventChannels{i}.PlxChannel == channelNumber
            event = PL2EventTs(filename, i);
            if numel(event.Ts) > 0
                n = numel(event.Ts);
                ts = event.Ts;
                sv = event.Strobed;
            end
            return
        end
    end
    fprintf('\n plx_event_ts: no header for the specified event channel.\n');
    return
end

[n, ts, sv] = mexPlex(3, filename, channelNumber);