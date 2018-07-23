clear
clc
% files=search_files(pwd,'mrg');
% MatndFiles= dir(['C:\Users\Nate\Documents\NPP Study\Map Analysis\New Analysis\Anitha\NPP23\Tactile\Right\*.mrg']);
%MatndFiles= dir(['C:\Users\Nate\Documents\NPP Study\Map Analysis\New Analysis\Anitha\NPP20\Pain\Left\*.matnd']);

MatndFiles= dir(['F:\Projects\NPP\NPP Study\Map Analysis\New Analysis\Anitha\NPP23\Tactile\Right\*.mrg']);
files = {MatndFiles.name}';
% files = MrgFiles{1} ;
    
options.pretime=0.1;
options.posttime=0.1;
options.bin=0.001;
options.region={1:32};
options.regionname={'CTX'};
options.binsizean=[1]/1000;
options.explab='file';
options.base=[1:95];
options.response=[105:200];
options.pvalue=0.001;


NPP007=Rec_Field_Analysis(files,options);

