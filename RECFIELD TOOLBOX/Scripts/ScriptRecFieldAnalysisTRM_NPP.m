clear
clc
% files=search_files(pwd,'mrg');
MatndFiles= dir(['C:\Users\Nate\Documents\NPP Study\Treadmill\NPP3\Rough\*.matnd']);
files = {MatndFiles.name}';
% files = MrgFiles{1} ;
    
options.pretime=0.2;   %Anitha told me .25 but her analysis is .2
options.posttime=0.2;
options.bin=0.005;
options.region={1:16,16:32};
options.regionname={'RCTX','LCTX'};
options.binsizean=[5]/1000;
options.explab='file';
%options.base=[1:95];
%options.response=[105:200];
%options.pvalue=0.001;
options.TRM=1;

NPP003=Rec_Field_Analysis(files,options);

