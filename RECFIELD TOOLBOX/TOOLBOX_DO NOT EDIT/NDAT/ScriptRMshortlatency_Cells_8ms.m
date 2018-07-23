%% analysis options
clear
clc
load filenames.mat

%remove file with artifact
filenames(3)=[];

options.pretime=0.1;
options.posttime=0.1;
options.bin=0.001;
options.intervals={'quiet','whisking'};
options.region={16:32};
options.regionname={'CTX'};
options.fileinfostring='date_animal_exp_exp_';
options.binsizean=0.001;
options.base=[3:95];
options.response=[102:195];
options.pvalue=0.001;
options.singlecellsinfo=1;
options.singlecellsinfotype={'Count','Timing'};
options.stimnostim=1;
options.RM=1;
options.timingbinsize=8;
options.timewindow=[102:141];
options.enwindow=[101+options.timingbinsize:options.timingbinsize:141];
%options.firstspike='first';
options.infobtsp=1900;
options.calcinfo=true;

%% analysis

[dataset,popPSTH]=Rec_Field_Analysis(filenames,options);
dt = datestr(now, 'mm_dd_yyyy');
filename=[dt,'RM_analysis_cells_timewindow_8ms'];
save(filename,'dataset')
export_dataset_for_SPSS(dataset,[filename,'.csv']);
save([dt,'popPSTH_analysis_cells_timewindow_8ms'],'popPSTH')
dcell=dataset2cell(dataset);