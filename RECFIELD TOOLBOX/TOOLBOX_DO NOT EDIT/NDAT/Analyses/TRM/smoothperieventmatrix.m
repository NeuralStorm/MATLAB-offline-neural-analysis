function [PeriEventMatrixSmoothed]=smoothperieventmatrix(PeriEventMatrix)
n=5;
Neurons = size(PeriEventMatrix,1);
for i=1:Neurons
   B=ones(n,1)/n;
   A=1;
   PeriEventMatrixSmoothed(i,:)=filter(B,A,PeriEventMatrix(i,:));
end
