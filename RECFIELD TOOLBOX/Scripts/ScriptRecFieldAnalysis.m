clear
clc
% files=search_files(pwd,'mrg');
MatndFiles= dir(['C:\Users\Nate\Documents\NPP Study\Map Analysis\NPP007\New folder\*.matnd']);
files = {MatndFiles.name}';
% files = MrgFiles{1} ;
    
options.pretime=0.25;
options.posttime=0.25;
options.bin=0.005;
options.region={1:16,16:32};
options.regionname={'RCTX','LCTX'};
options.binsizean=[5]/1000;
options.explab='file';
%options.base=[1:95];
%options.response=[105:200];
%options.pvalue=0.001;
options.TRM=1;

NPP007=Rec_Field_Analysis(files,options);

