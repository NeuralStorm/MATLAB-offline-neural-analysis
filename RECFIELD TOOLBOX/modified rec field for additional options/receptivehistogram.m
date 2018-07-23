function [NormReceptiveFieldMatrix2D]=receptivehistogram(ReceptiveFieldMatrix, PrincRF, minRMinput)


%[NormReceptiveFieldMatrix2D]=receptivehistogram(ReceptiveFieldMatrix, 'prf', .2)

%ReceptiveFieldMatrix= files x neurons x parameters
%parameters: [Response; Peak; FirstBinLatency; LastBinLatency; PeakLatency; BackgroundAvg; BackgroundSTD]
%
%NormReceptiveFieldMatrix2D= (files*neurons)x(parameters+5) [NormResponse; Response; Peak; FirstBinLatency; 
%                                                     LastBinLatency; PeakLatency; BackgroundAvg; BackgroundSTD; Place; Neuron; PRF; RFS]
%										sorted on NormResponse
%
%March 2002 by Guglielmo Foffani (Drexel University)
%
%2/4/2002 Added Place, which is a number that indicates the stimulation site (=the file)
%               Neuron, which is a number that indicates the original neuron or channel 
%1/6/2002 Added the possibility to throw away neurons with princ rec field RM < minRM
%
%September 2nd 2002 Added PRF if nargin==2
%
%February 25th 2003 Now NormReceptiveFieldMatrix2D is free of zero entries
%                   Added the RFS to NormReceptiveFieldMatrix2D (if
%                   nargin==2)
%
%November 24th 2003 minRM as input argument if nargin==3. Default value
%                   minRM=0
%
%May 14th 2004 corrected divide-by-zero problem when minRM=0 (use > instead of >=)


NumFiles=size(ReceptiveFieldMatrix,1);
NumNeurons=size(ReceptiveFieldMatrix,2);
NumParameters=size(ReceptiveFieldMatrix,3);

%minRM=.1538;
%minRM=.63*.25;
%minRM=.2; %SURROUND PAPER
%minRM=1;
%minRM=0;
if nargin>2
    minRM=minRMinput;
else
    minRM=0;
end

%Add the parameter(first element) which represents the relative value respect to the principal receptive field
%The normalization is based on the Response (Normalized Response Magnitude)

if nargin>1
    ReceptiveFieldMatrixAdd=zeros(NumFiles,NumNeurons,NumParameters+5);
    ReceptiveFieldMatrix2D=zeros(NumFiles*NumParameters,NumParameters+5);
else
    ReceptiveFieldMatrixAdd=zeros(NumFiles,NumNeurons,NumParameters+3);
    ReceptiveFieldMatrix2D=zeros(NumFiles*NumParameters,NumParameters+3);
end

for i=1:NumFiles
   for j=1:NumNeurons
      if max(ReceptiveFieldMatrix(:,j,1))>minRM
         [PRFRM,PRF]=max(ReceptiveFieldMatrix(:,j,1));
         ReceptiveFieldMatrixAdd(i,j,1)=ReceptiveFieldMatrix(i,j,1)/PRFRM;
         %add the PRF
         if nargin>1
            ReceptiveFieldMatrixAdd(i,j,NumParameters+4)=PRF; 
            %add the RFS
            RFS=length(find(ReceptiveFieldMatrix(:,j,1)));
            ReceptiveFieldMatrixAdd(i,j,NumParameters+5)=RFS;
         end
         ReceptiveFieldMatrixAdd(i,j,2:NumParameters+1)=ReceptiveFieldMatrix(i,j,1:NumParameters);
         %add the place
         ReceptiveFieldMatrixAdd(i,j,NumParameters+2)=i;
         %add the neuron
         ReceptiveFieldMatrixAdd(i,j,NumParameters+3)=j;
      else
         ReceptiveFieldMatrixAdd(i,j,1)=0;
      end
   end
end


for i=1:NumFiles*NumNeurons
   ReceptiveFieldMatrix2D(i,:)=ReceptiveFieldMatrixAdd(ceil(i/NumNeurons),i-NumNeurons*(ceil(i/NumNeurons)-1),:);
end

%sort in decresing order based on NRM
[Temp,IndexNormResponse]=sort(ReceptiveFieldMatrix2D(:,1));
IndexNormResponse=flipud(IndexNormResponse);
NormReceptiveFieldMatrix2D=ReceptiveFieldMatrix2D(IndexNormResponse,:);

%eliminate zero entries
IndexZeros=find(NormReceptiveFieldMatrix2D(:,2));
NormReceptiveFieldMatrix2D=NormReceptiveFieldMatrix2D(IndexZeros,:);

if 0
    %stem(NormReceptiveFieldMatrix2D(:,1));
    figure
    stem(NormReceptiveFieldMatrix2D(find(NormReceptiveFieldMatrix2D(:,1)>0),1));

    figure
    stem(ReceptiveFieldMatrix2D(find(ReceptiveFieldMatrix2D(:,1)>0),2));

end