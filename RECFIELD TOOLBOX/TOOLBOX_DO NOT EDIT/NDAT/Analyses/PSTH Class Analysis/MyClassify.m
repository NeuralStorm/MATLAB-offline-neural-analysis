function [Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PeriEventMatrixAll,Group,Method,p,ErrorAnalysis,VariableDropping,SingleNeuronBins,DropOneNeuron,NlessOne,LatencyEstimate);   %added "TimeLength" to beginningtime

%[Class,ConfusionMatrix,D]=MyClassify(PeriEventMatrixAll,Group,Method,p,ErrorAnalysis,VariableDropping);
%
%INPUTS
%
%PeriEventMatrixAll= data matrix (each raw is a trial, each column is a bin, see Foffani and Moxon 2004)
%
%Goup= grouping vector that express the location identity for every trial (see also function "classify");
%       note that: length(group)=size(PeriEventMatrixAll,1)
%
%Method= string that indicate which distance has to be used; accepted
%       values are: 'euclidean','minkowski','DP'(i.e. dot product),'ML'(i.e. simplified maximum likelihood),
%       'mutual'(i.e. mutual info, TO BE FIXED!!), and any other values accepted by the function 'pdist'.
%       For details see Foffani and Moxon, 2004
%
%p is defined only if Method = 'Minkowski'
%
%ErrorAnalysis= indicates if an error analysis is performed (1) or not (0),
%       for details about the error analysis see Foffani, Tutunculer, Moxon (2004)       
%
%VariableDropping= indicates if a complete variable dropping is performed (1) or not (0),
%       for details about the variable dropping see Foffani and Moxon (2004)     
%
%SingleNeuronBins= option of the VariableDropping procedure to calculate the
%       information carried by individual neurons; the value of
%       SingleNeuronBins should indicate the number of bins per neuron in
%       PeriEventMatrixAll; if SingleNeurons==0, then the standard cumulative variable
%       dropping is performed
%
%DropOneNeuron= option of the SingleNeurons; for every neuron the classification is run using 
%       using all the other neurons; VariableDropping should be equal to 1,
%       SingleNeurons should indicate the number of bits per neuron,
%       DropeOneNeuron should be equal to 1
%
%NlessOne= if 1 corrects the template after subtraction of the single
%       trial by N/(N-1). If absent does not perform the correction.
%
%OUTPUTS
%
%Class= vector that contains the results of the classification; each
%       element of class indicate to which location a single trial was
%       classfied; note that: length(group)=size(PeriEventMatrixAll,1);
%       see also function "classify"
%
%ConfusionMatrix= self explaining; each row corresponds to the real class,
%       each column to the predicted class (so that the sum of the elements
%       in one raw always = 1)
%
%D= the output vector of the error analysis; 
%       D is the error distance. If D=1 a trial is accepted as recognized only if
%       it is the correct guess. If D=2 a trial is accepted as recognized if it is
%       the first or second guess and so on
%       length(D)=size(PeriEventMatrixAll,1)
%
%April 30th 2004 - Guglielmo Foffani (Drexel University and Politecnico di MIlano)
%
%May 31th 2004 - Added option for using the VariableDropping to calculate the information carried by individual neurons 
%              - Corrected the 'house keeping' for the variable dropping (+1 missing)
%June 16th 2004 - Added DropOneNeuron: for every neuron, the classification is perfomed using all the other neurons 
%
%February 11th 2008 - Added option to correct the templates after
%                     subtraction of single trials by N/(N-1)
%
%ATTENZIONE: generalizzare la relazione con locations (non mi ricordo
%perche' avevo scritto questo, ma l'ho lasciato!!)

%Changed output of confusion matrix. The new output is not normalized on
%the number of total stimuli. Each row of the not normalized confusion
%matrix is now equal to the number of stimuli delivered
if SingleNeuronBins==0
    bins=1; 
else 
    bins=SingleNeuronBins;
end


%extract locations from Group
% locations=Group(1);
% for i=2:length(Group)
%     if Group(i)~=locations
%         locations=[locations Group(i)];
%     end
% end
% locations;

locations=unique(Group)';
locations(locations==0)=[];

%Define PSTH templates
for k=locations
    LocIndex=find(Group==k);
    NumTrials(k)=length(LocIndex);
    PeriEventHistoVector(k,:)=mean(PeriEventMatrixAll(LocIndex,:),1); %a raw per location
end

if VariableDropping==1
    %WeightVector=zeros(size(PeriEventMatrixAll,1),max(locations),size(PeriEventMatrixAll,2));
    ConfusionMatrix=zeros(max(locations),max(locations),size(PeriEventMatrixAll,2)/bins);
end
for h=1:size(PeriEventMatrixAll,1)%for every trial
    Trial=PeriEventMatrixAll(h,:); %extract the trial 
    PeriEventHistoVectorTemp=zeros(1,size(PeriEventMatrixAll,2));
    WeightVector=[];
    for k=locations %for every location (=potential location) 
        PeriEventHistoVectorTemp=PeriEventHistoVector(k,:);
        %subtract the single trial from the corresponding template
        if k==Group(h)
            if (nargin>9)+(NlessOne==1)==2
                PeriEventHistoVectorTemp=(PeriEventHistoVectorTemp-(Trial/NumTrials(k)))*NumTrials(k)/(NumTrials(k)-1);
            else
                PeriEventHistoVectorTemp=PeriEventHistoVectorTemp-(Trial/NumTrials(k));
            end
            
            if nargin>8
                [C,IndexC] = xcorr(full(PeriEventHistoVectorTemp),full(Trial),40);
                [pippo,IndexMax]=max(C);
                LatEst(h)=IndexC(IndexMax);
            end
        end
        
        if VariableDropping==1
            %cumulative Euclidean distance
            %WeightVector(k,1)=sum((PeriEventHistoVectorTemp(1:bins)-Trial(1:bins)).^2);    
            if SingleNeuronBins==0 %perform cumulative variable dropping
                WeightVector(k,1)=sum((PeriEventHistoVectorTemp(1:bins)-Trial(1:bins)).^2); 
                for v=2:size(PeriEventMatrixAll,2)/bins %for every variable
                    WeightVector(k,v)=WeightVector(k,v-1)+sum((PeriEventHistoVectorTemp((v-1)*bins+1)-Trial(v*bins)).^2);
                end
            else
                
                if DropOneNeuron==1
                    %for every neuron use the Euclidean distance of all the others
                    WeightVectorAll=sum((PeriEventHistoVectorTemp-Trial).^2);    
                    for v=1:size(PeriEventMatrixAll,2)/bins %for every neuron
                        WeightVector(k,v)=WeightVectorAll-sum((PeriEventHistoVectorTemp((v-1)*bins+1:v*bins)-Trial((v-1)*bins+1:v*bins)).^2);
                    end
                else
                    %single neurons 
                    for v=1:size(PeriEventMatrixAll,2)/bins %for every neuron
                        WeightVector(k,v)=sum((PeriEventHistoVectorTemp((v-1)*bins+1:v*bins)-Trial((v-1)*bins+1:v*bins)).^2);
                    end
                end
            end
        else
            %NormPeriEventHistoMatrixTemp=PeriEventHistoMatrixTemp./(ones(200,1)*max(PeriEventHistoMatrixTemp));
            switch Method
                case 'mutual'
                    %WeightVector(h,k)=information(PeriEventHistoVectorTemp,Trial);
                    numbins=15;
                    %size(PeriEventHistoVectorTemp)
                    %size(Trial)                                    
                    WeightVector(k) = zmi1(SingleTrialVector2Matrix(PeriEventHistoVectorTemp,numbins),SingleTrialVector2Matrix(Trial,numbins),1,numbins,0,0,0);
                case 'minkowski'
                    WeightVector(k)=pdist([PeriEventHistoVectorTemp;Trial],Method,p);
                case 'DP' %dot product
                    WeightVector(k)=-sum((PeriEventHistoVectorTemp.*Trial));
                case 'ML' %simplified maximum likelihood
                    WeightVector(k)=-prod(1+2*Trial.*PeriEventHistoVectorTemp-Trial-PeriEventHistoVectorTemp);
                otherwise
                    WeightVector(k)=pdist([PeriEventHistoVectorTemp;Trial],Method);
            end
        end
       end
    if VariableDropping==1
        for v=1:size(PeriEventMatrixAll,2)/bins %for every variable
            WeightVector(find(WeightVector(:,v)==0),v)=max(WeightVector(:,v))+1; %house keeping
            [Y,Class(h,v)] = min(WeightVector(:,v));
        end
    else
        WeightVector(find(WeightVector==0))=max(WeightVector)+1; %house keeping
        [Y,Class(h)] = min(WeightVector);
        if ErrorAnalysis==1
            [pippo,SortIndex] = sort(WeightVector);
            D(h)=find(SortIndex==Group(h)); 
        end
    end
end
if ErrorAnalysis==1
    D=D';%column vector
else
    D=0;
end
 
%calculate ConfusionMatrix
for i=locations
    if VariableDropping==1
        LocIndex=find(Group==i);
        
        for v=1:size(PeriEventMatrixAll,2)/bins %for every variable
            ResultVectorTemp=zeros(1,length(locations));
            for k=locations
                ResultVectorTemp(k)=length(find(Class(LocIndex,v)==k))/length(LocIndex);     
            end
            for j=1:length(ResultVectorTemp)
                ConfusionMatrix(i,j,v)=ResultVectorTemp(j);
                ConfusionMatrixnotnorm(i,j,v)=ResultVectorTemp(j)*length(LocIndex);
            end
        end
    else
        
        %ResultVectorTemp=zeros(1,20);
        LocIndex=find(Group==i);
        for k=locations
            ResultVectorTemp(k)=length(find(Class(LocIndex)==k))/length(LocIndex);     
        end
        %sum(ResultVectorTemp)
        ConfusionMatrix(i,:)=ResultVectorTemp;
        ConfusionMatrixnotnorm(i,:)=ResultVectorTemp*length(LocIndex);
    end
end

