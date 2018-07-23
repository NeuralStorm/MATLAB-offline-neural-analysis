
% clear all;
% clc
% files=search_files(pwd,'.matnd');
% MatndFileDir = 'D:\Matlab\Tilt_Folder\Modified Matnd Files' ;
MatndFileDir = 'D:\Matlab\Reorganization_Posture\Matnd Files by Tilt\AmpDur' ;%%2,3,6 for everything, 1 just has diff speeds
% MatndFileDir = 'D:\Matlab\Tilt_Folder\Speed_Changes\Matnd Files\esting_backgrounds' ;

% MatndFileDir = 'D:\Matlab\Tilt_Folder\Matnd Files for 15 deg tilt focus' ;

A = dir(MatndFileDir);
A = A(3:end) ;
files = {A.name}' ; 


i=1;
for q=1:1
filenames{1} = strcat(MatndFileDir,filesep,files{q})%1, 3, 4confirm location of wanted file  %5 is tx data  %%%%1 2 10 13

%FILN=[6 11 16 20 22 25 26 28]

% options 
% options.pretime=0.2;
options.pretime = .0; %a
options.posttime=.4700%572;%in seconds!!!!  ??
options.bin=0.001; %in seconds
%options.intervals={'quiet','whisking'};
%options.intervals = {} ;
options.region={1:32};%%1:32
options.regionname={'CTX'};
options.binsizean=[1 2 5 10 20 50 100]/1000;%set binsizes for analysis
options.fileinfostring='exp.ratid.type.week.date';
options.evchannels=[2 3 4 6 7 8];%[3 4 7 8];%%  32 33 34 3 4 7 8 9 11 13 15
options.bootstrapped = 1;
options.bootstrapnum = 2;
options.bootstrapCI = 0 ;
PSTH_Classification_Analysis(filenames,options)

BB=[ans(:,1) ans(:,2) ans(:,6) ans(:,8) ans(:,9) ans(:,10) ans(:,11) ans(:,12) ans(:,13)];

j{1,i}=BB;
i=i+1;
end

% % % 
% % % 
%  CSRdata=j{1,1};
% for k=2:20
%     CSRdata=[CSRdata; j{1,k};]
% end
% % % 
% export(CSRData,'XLSFile','CSRData_all_8_tilts_780ms_bins.xlsx');
% % % % export(ans,'XLSFile','test.xlsx');
% % % 
% % % % CSRData=[CSR10; CSR14; CSR19; CSR22];
% % % 
% % % %%%%C=[A;B];
% 
