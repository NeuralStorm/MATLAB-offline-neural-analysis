

clear all;
clc
% files=search_files(pwd,'.matnd');
MatndFileDir = '/home/anitha/Documents/Final Work Summer 2010/NC-TX data/NC/Matnd Files' ;
A = dir(MatndFileDir);
A = A(3:end) ;
files = {A.name}' ; 
outdataset = {};

for i = 1:length(files)
filenames{i,1} = strcat(MatndFileDir,filesep,files{i});
end

% options 
% options.pretime=0.2;
options.pretime = 0.0 ; % anitha 
options.posttime=1.5;
options.bin=0.005;
% options.intervals={'quiet','whisking'};
%options.intervals = {} ;
options.region={1:32};
options.regionname={'CTX'};
options.binsizean=[5]/1000;
options.fileinfostring='date_animal_exp_day_';
options.evchannels=[20,21];
% options.bootstrapped = 1 ;
% options.bootstrapnum = 2 ;
% options.bootstrapCI = 0 ;
tempdataset = PSTH_Classification_Analysis(filenames,options)
% if isempty(outdataset)
%     outdataset = tempdataset ;
% else 
%     outdataset = vertcat(outdataset,tempdataset);
% end
