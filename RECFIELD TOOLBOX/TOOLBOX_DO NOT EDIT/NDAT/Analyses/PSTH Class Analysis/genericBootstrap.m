function [InformationBtsp,PerformanceBtsp] = genericBootstrap( bootstrapnum,PEHMClass,Group)
%UNTITLED9 Summary of this function goes here

%#codegen
%   Detailed explanation goes here
  InformationBtspVector = zeros(bootstrapnum,1);
    PerformanceBtspVector=zeros(bootstrapnum,1);
    
    
    for k = 1:bootstrapnum
        %fprintf('%3.0f',k);
        % random shuffling of trials
        [~,randIX] = sort(rand(size(PEHMClass,1),1));
        
        % trials are shuffled randomly
        PEMtemp= PEHMClass;
        PEMtemp(randIX,:)=PEMtemp(1:size(PEMtemp,1),:);
        
        % this is where you find the PSTH information for each of these PEMtemp and
        % store it as I (k,:)
        
        [~,Ib,perf,~]=classify_PSTH(PEMtemp,Group);
        InformationBtspVector(k,:) = Ib ;
        PerformanceBtspVector(k,:)= perf;
        %fprintf('%c%c%c',8,8,8)
    end
    
    InformationBtsp = mean(InformationBtspVector);
    PerformanceBtsp=mean(PerformanceBtspVector);

end


%% subfunctions

function [ConfusionMatrixnotnorm,I,perf,Class]=classify_PSTH(PEHMClass,Group)

[Class,~,~,~,ConfusionMatrixnotnorm,~]=MyClassify(PEHMClass,Group,'Euclidean',[],0,0,0,0,1,0);
perf=sum(diag(ConfusionMatrixnotnorm))/sum(sum(ConfusionMatrixnotnorm));
I=I_confmatr(ConfusionMatrixnotnorm);


end

