function [data]=createdatastruct(ver,type)

if nargin<2
    type={};
end

if iscell(type)
    
elseif length(type)==1
    type={type};
else
    type=num2cell(type);
end

for i=1:length(type)
    
    switch ver
        case 100
            data_struct.ver=100;
            data_struct.files(1).name='';
            data_struct.files(1).tscounts=zeros(27,1);
            data_struct.files(1).Neurons(1).name='';
            data_struct.files(1).Events(1).name='';
            data_struct.files(1).Intervals(1).name='';
            varargout(i)=data_struct;
        case 200
            data_struct.ver=200;
            data_struct.files(1).name='';
            data_struct.files(1).tscounts='';
            data_struct.files(1).wfcounts='';
            data_struct.files(1).Neurons(1).name='';
            data_struct.files(1).Events(1).name='';
            data_struct.files(1).Waveforms(1).name='';
            varargout(i)=data_struct;
            
        case 300
            out=[];
            switch type{i}
                
                case {'Neurons','Channels',0}
                    
                    data.Channels.name=''; %sig001     
                    data.Channels.unit=[]; %1, a       
                    data.Channels.ts=[];
                    
                case {'Events',1}
                    
                    data.Events.name=''; %Ev002
                    data.Events.channel=[]; %2 or channel numeric identifier
                    data.Events.ts=[]; 
                    
                case {'Waveforms',3}
                    
                    data.Waveforms.name=''; %sig001a    
                    data.Waveforms.name.ts=[]; %1       
                    data.Waveforms.name.unit=[]; %1, a       
                    data.Waveforms.name.wave=[]; % #TS x WP+1 {[TimeStamps,WavePoints [#WP] ]} matrix
                    
                case {'Intervals',2}
                    
                    data.Intervals.name.name=''; %Int1  
                    data.Intervals.name.intervals=[]; % #Intervals x 2 {Start,End} matrix
                    
                case {'PopulationVector',4}
                    
                    data.PopulationVector.name=''; % PCA 1
                    data.PopulationVector.popvec=[]; % #Neurons x #PopVectors
                    
            end
            
    end
end