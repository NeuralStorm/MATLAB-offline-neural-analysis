
clear all ;

options.pretime = 0.2;
options.posttime = 0.2 ;
options.bin = 0.005 ;
options.intervals={'all'};
options.region={1:32};
options.binsizean = [0.005];
options.regionname={'CTX'};
options.evchannels = [1 2]';
% list of files 
A = dir('/home/anitha/Documents/Final Work Summer 2010/TRM Files/PlxFiles/Matnd');
List = {A.name}';
filenames = List(3:end);
[TRMDataSet] = Rec_Field_Analysis_WB_TRM(filenames,options);