% bootstrapping

% sample inputs
% filenames = {'/home/anitha/Documents/NDAT Test/081209.RCRTLW10_W3.DUR.MPH.1.0_-30.matnd'};
% options.pretime=-0.005;
% options.posttime=0.045;
% options.bin=0.001;
% % options.intervals={'quiet','whisking'};
% %options.intervals = {} ;
% options.region={16:32};
% options.regionname={'CTX'};
% options.binsizean=[1 2 4 8 10 20 40]/1000;
% options.fileinfostring='date_animal_exp_exp_';
% options.evchannels=[2,4,5];
% options.bootstrapped = 1 ;
% options.bootstrapnum = 200 ;
% % options.bootstrapCI = 0 ;


function [varargout]= BootstrapFunction(PEHMClass,Group,options)

%output 1=InformationBtsp 
%output 2=PerformanceBtsp
%% finds the bootstrapped value of Information based on a fixed number of bootstraps

save('temp','-struct','options');
load temp;
%


  [InformationBtspVector,PerformanceBtspVector]=deal(ones(bootstrapnum,1));
if bootstrapCI==0
    InformationBtspVector = zeros(bootstrapnum,1);
    bc=fprintf(',Bootstrapping');
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
    %% finds the number of bootstraps iteratively and stop when the bootstrap falls within a confidence interval
    
elseif bootstrapCI==1
    
    bc=fprintf(',Bootstrapnum: ');
    
    for k = 1:bootstrapnum
        fprintf('%3.0f',k);
        % random shuffling of trials
        [ignore,randIX] = sort(rand(size(PEHMClass,1),1));
        
        % trials are shuffled randomly
        PEMtemp= PEHMClass;
        PEMtemp(randIX,:)=PEMtemp(1:size(PEMtemp,1),:);
        
        % this is where you find the PSTH information for each of these PEMtemp and
        % store it as I (k,:)
        
        [ConfusionMatrix,Ib,perf,class]=classify_PSTH(PEMtemp,Group);
        InformationBtspVector(k,:) = Ib ;
        fprintf('%c%c%c',8,8,8)
        
        if k>1
            
            
            for i=2:size(InformationBtspVector)
                cummean(i) = mean(InformationBtspVector(1:i));
                cumstd(i)=std(InformationBtspVector(1:i));
                cumci(i)=cumstd(i)*norminv(1-0.005,0,1)/sqrt(i);
            end
            
            if cumci(end)<0.1*cummean(end)
                NumBootstraps = size(cummean,2);
                InformationBtsp = mean(InformationBtspVector);
                delete_char(bc) ;
                return;
            end
            
        end
        
    end
    InformationBtsp = mean(InformationBtspVector);
    
end

if nargout==1
    varargout{1}=InformationBtsp;
elseif nargout==2
    varargout{1}=InformationBtsp;
    varargout{2}=PerformanceBtsp;
else
    disp('Too many output arguments specified')
end
    

delete_char(bc) ;
end


%% subfunctions

function [ConfusionMatrixnotnorm,I,perf,Class]=classify_PSTH(PEHMClass,Group)

[Class,~,~,~,ConfusionMatrixnotnorm,~]=MyClassify(PEHMClass,Group,'Euclidean',[],0,0,0,0,1,0);
perf=sum(diag(ConfusionMatrixnotnorm))/sum(sum(ConfusionMatrixnotnorm));
I=I_confmatr(ConfusionMatrixnotnorm);


end