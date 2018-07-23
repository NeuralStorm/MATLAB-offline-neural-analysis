function [ PEHMClass,Neurons] = PEHMchanselect(PEHMClass, bin_matr, Neurons,chanGroup,options)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


originalDuration=length(chanGroup)/Neurons;




                            newDuration=size(bin_matr,2)/Neurons;
                            
                            [chans,firstChanInd,~]=unique(chanGroup);
                            
                            chanReps=[diff(firstChanInd);...
                                size(chanGroup,2)+1-firstChanInd(end)]./originalDuration;
                            
                            chanGroupNew=[]; %pre-allocate in future
                            for channel=1:length(chans)
                                
                                chanValue=chans(channel);
                                
                                chanGroupNew=[chanGroupNew,...
                                    repmat(chanValue,1,chanReps(channel)*newDuration)];
                            end
                            
                            
                            chanMask=ismember(chanGroupNew,options.region);
                            
                            PEHMClass=PEHMClass(:,chanMask);
                            
                            Neurons=size(PEHMClass,2)/newDuration;


end

