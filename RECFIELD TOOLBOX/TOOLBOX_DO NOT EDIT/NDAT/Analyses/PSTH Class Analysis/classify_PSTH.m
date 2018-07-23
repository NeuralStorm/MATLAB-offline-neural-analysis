function [ConfusionMatrixnotnorm,I,perf,Class]=classify_PSTH(PEHMClass,Group,options)

[Class,ConfusionMatrix,D,LatEst,ConfusionMatrixnotnorm,PeriEventHistoVector]=MyClassify(PEHMClass,Group,'Euclidean',[],0,0,0,0,1,0);
perf=sum(diag(ConfusionMatrixnotnorm))/sum(sum(ConfusionMatrixnotnorm));
I=I_confmatr(ConfusionMatrix);
