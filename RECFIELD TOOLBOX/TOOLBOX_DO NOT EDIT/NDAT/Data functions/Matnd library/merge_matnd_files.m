function merge_matnd_files(originfilelist,destfile,tomerge,mapflag,explab)

addtimesec=10;

if nargin<3
    tomerge=[0 1 2 3 ];
end

if exist(destfile)
    disp('A merged file with the same name already exist')
    return
else

end
% infile=get_info_from_matnd(originfilelist{1});
finaldestfile=destfile;
[p,f,ext]=fileparts(destfile);
p=fileparts(which('Configure_path'));
destfile=[p,filesep,f,ext];


tic
for i=1:length(originfilelist)
    if i==1
        Channels=[];
        save(destfile,'Channels','-mat');
        info=GetMatndInfo(originfilelist{i});
    else
        info=GetMatndInfo(destfile);
    end
    try
        stoptime=info.stopts;
    catch
        X = load(destfile,'-mat');
        stoptime = max(X.Events(1,3).ts);
        clear X ;
    end
    addtime=stoptime+addtimesec;
    originfilelist{i};
    varinfile=whos('-file',originfilelist{i});
    
    for var={varinfile.name}
        

        tosave=0;
        switch var{:}
            
            
            case 'Channels'
                
                if sum(tomerge==0)
                    tosave=1;
                    toadd=load(originfilelist{i},var{:},'-mat');
                    if i==1
                        eval([var{:},'=toadd.',var{:},';']);
                    else
                        load(destfile,var{:},'-mat');
                        for n=1:length(Channels)
                            chanpos=find([toadd.Channels.channel]==...
                                Channels(n).channel);
                            if ~isempty(chanpos)
                                Channels(n).ts=cat(1,...
                                    Channels(n).ts,addtime+...
                                    toadd.Channels(chanpos).ts);
                                Channels(n).unit=cat(1,...
                                    Channels(n).unit,...
                                    toadd.Channels(chanpos).unit);
                            end
                            if sum(Channels(n).ts==0)>1
                                warning('possible problem with the file')
                            end
                        end
                    end
                end
                
            case 'Events'
                if sum(tomerge==1)
                    toadd=load(originfilelist{i},var{:},'-mat');
                    tosave=1;
                    if i==1
                        eval([var{:},'=toadd.',var{:},';']);
                        if mapflag
                            [fieldsname,fieldsvalue]=...
                                get_file_info(originfilelist{i},explab);
                            index=regexpi(fieldsname,'Loc');
                            index=logical(1-cellfun(@isempty,index));
                            for e=1:length(Events)
                                if Events(e).channel<258 && Events(e).channel>1
                                    epos=length(Events)+1;
                                    Events(epos).channel=17;
                                    Events(epos).name=fieldsvalue{index};
                                    Events(epos).ts=Events(e).ts;
                                    Events(e).name=['Merged_',Events(e).name];
                                end
                            end
                        end
                    else
                        load(destfile,var{:},'-mat');
                        
                        for e=1:length(toadd.Events) % anitha changed evpos to evpos(1) for multiple channels with same ch#. Revoke if necessary
                            evpos=find([Events.channel]==...
                                toadd.Events(e).channel);
                            if ~isempty(evpos)
                                if mapflag
                                    [fieldsname,fieldsvalue]=...
                                        get_file_info(originfilelist{i},explab);
                                    index=regexpi(fieldsname,'Loc');
                                    index=logical(1-cellfun(@isempty,index));
                                    if Events(evpos(1)).channel<258 && Events(evpos(1)).channel>1
                                        epos=length(Events)+1;
                                        Events(epos).channel=16+i;
                                        Events(epos).name=fieldsvalue{index};
                                        Events(epos).ts=addtime+...
                                            toadd.Events(e).ts;
                                        Events(evpos(1)).ts=cat(1,...
                                            Events(evpos(1)).ts,addtime+...
                                            toadd.Events(e).ts);
                                    else
                                        Events(evpos(1)).ts=cat(1,...
                                            Events(evpos(1)).ts,addtime+...
                                            toadd.Events(e).ts);
                                    end
                                    
                                    
                                else
                                    Events(evpos(1)).ts=cat(1,...
                                        Events(evpos(1)).ts,addtime+...
                                        toadd.Events(e).ts);
                                end
                                
                                
                            else
                                
                                epos=length(Events)+1;
                                Events(epos).channel=toadd.Events(e).channel;
                                Events(epos).name=toadd.Events(e).name;
                                Events(epos).ts=addtime+...
                                    toadd.Events(e).ts;
                                if mapflag
                                    epos=length(Events)+1;
                                    Events(epos).channel=16+i;
                                    Events(epos).name=fieldsvalue(index);
                                    Events(epos).ts=addtime+...
                                        toadd.Events(e).ts;
                                end
                            end
                            
                            
                            
                        end
                    end
                end
                
            case 'Continous'
                toadd=load(originfilelist{i},var{:},'-mat');
                
            case 'Intervals'
                if sum(tomerge==2)
                    tosave=1;
                    toadd=load(originfilelist{i},var{:},'-mat');
                    if i==1
                        eval([var{:},'=toadd.',var{:},';']);
                    else
                        load(destfile,var{:},'-mat');
                        
                        
                        for in=1:length(Intervals)
                            
                            Intervals(in).intervals=cat(1,...
                                Intervals(in).intervals,addtime+...
                                toadd.Intervals(in).intervals);
                        end
                    end
                end
            otherwise
                toadd=load(originfilelist{i},var{:},'-mat');
                if sum(tomerge==3)
                    tosave=1;
                    if i==1
                        eval([var{:},'=toadd.',var{:},';']);
                    else
                        load(destfile,var{:},'-mat');
                        
                        if strcmpi(var{:}(1:end-3),'Waveforms')
                            if sum(tomerge==3)
                                eval([var{:},'=mergeWaveforms(',var{:},...
                                    ',toadd.',var{:},',addtime);']);
                            end
                        end
                    end
                end
                
        end
        if tosave
            save(destfile,var{:},'-mat','-append');
            clear(var{:},'toadd');
        end
    end
    
    i
end
OriginalFiles=originfilelist;
save(destfile,'OriginalFiles','-mat','-append');
movefile(destfile,finaldestfile);
toc


function out=mergeWaveforms(out,in,addtime)

out.ts=cat(1,...
    out.ts,addtime+...
    in.ts);
out.unit=cat(1,...
    out.unit,...
    in.unit);
out.waves=cat(1,...
    out.waves,...
    in.waves);