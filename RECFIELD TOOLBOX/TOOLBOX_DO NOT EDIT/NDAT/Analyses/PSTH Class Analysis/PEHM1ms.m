function [ PEHMClass1,evtGroup,chanGroup,Duration,Neurons] = PEHM1ms(options,filename,b)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if isfield(options,'allChansUsed')
   options.region=options.allChansUsed; 
end


 %Create PEHM using a 1ms bin only
                            if b==1 && strcmpi(options.bin,.001)
                                [PEHMClass1,evtGroup,info]=PEHMClassFromMatnd(filename,options);
                                Duration=length((-options.pretime:.001:options.posttime))-1;
                                Neurons=size(PEHMClass1,2)/Duration;
                            elseif b==1 && ~strcmpi(options.bin,.001)
                                tempBin=options.bin;
                                options.bin=.001;
                                [PEHMClass1,evtGroup,info]=PEHMClassFromMatnd(filename,options);
                                options.bin=tempBin;
                                Duration=length((-options.pretime:.001:options.posttime))-1;
                                Neurons=size(PEHMClass1,2)/Duration;
                            else
                            end
                            
                            
                            
                            [chans,~,chanInds]=unique(info.chanunits(:,1));
                            chanGroup=[]; %pre-allocate in future
                            for neuron=1:length(chanInds)
                               chanInd=chanInds(neuron);
                                
                                chanGroup=[chanGroup,repmat(chans(chanInd),1,Duration)];
                            end



end

