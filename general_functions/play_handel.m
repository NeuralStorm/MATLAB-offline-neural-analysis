function [] = play_handel()
    % function designed to play handel. Meant to be combined with
    % other command window calls to notify user when commands are
    % finished
    load handel
    sound(y,Fs)
end