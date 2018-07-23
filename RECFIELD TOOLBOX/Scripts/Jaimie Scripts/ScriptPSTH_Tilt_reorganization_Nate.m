


clear all;

filename='CSR037 Week0 Information';
% clc
%if newfolder
%newfolder=cd(newfolder);

% cd('C:\Users\Nate\Documents\RECFIELD TOOLBOX\Scripts\Jaimie Scripts')
% load(newfolder)
% newfolder=cd(MatndFileDir);
% 
[Filename,MatndFileDir,Filterindex] = uigetfile('*.mat');
% save('newfolder','MatndFileDir')


A = dir(MatndFileDir);
A = A(3:end) ;
files = {A.name}' ; 


i=1;
for q=3:3
filenames{1} = strcat(MatndFileDir,filesep,files{q})

% options 
% options.pretime=0.2;
options.pretime = 0  %.500; %a
options.posttime= .5  %.500%572;%in seconds!!!!  ??
options.bin=0.001; %in seconds  leave at .001
%options.intervals={'quiet','whisking'};
%options.intervals = {} ;
options.region={1:32};%%1:32
options.regionname={'CTX'};
options.binsizean=[1 20 50 100]/1000;%set binsizes for analysis  doesn't like not having 1
options.fileinfostring='exp.ratid.type.week.date';
options.evchannels=[1 2 3 4 5 6 7 8];
%  options.bootstrapped = 1;
%  options.bootstrapnum = 2;
%  options.bootstrapCI = 0 ;
[dataoutput]=PSTH_Classification_Analysis(filenames,options)

output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,6)...
    dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
    dataoutput(:,11) dataoutput(:,12) dataoutput(:,13)];

j{1,i}=output;
i=i+1;
end
cd('C:\Users\Nate\Documents\Jaimie Tilt\Information Results\')
%export(output,'XLSFile',filename);

%%
A=ans;  %replace "A" with "output"

ConfMat_1=A{1,3};
ConfMat_25=A{2,3};
ConfMat_50=A{3,3};
ConfMat_75=A{4,3};
ConfMat_100=A{5,3};
ConfMat_150=A{6,3};



close
xmin=20;
xmax=max(options.binsizean.*1000);
ymin=0.25;
ymax=.95;
 [cw_vs_ccw,tilt,tilttype,background]=CW_vs_CCW(A,options.binsizean.*1000);
%
subplot(2,2,3)
 plot(options.binsizean.*1000,cw_vs_ccw(:,1)','-b.')
 hold on
 plot(options.binsizean.*1000,cw_vs_ccw(:,2)','-r.')
 xlabel('Binsize (ms)')
 ylabel('Performance')
 legend('CW','CCW')
 grid on
 axis([xmin xmax ymin ymax])
 
subplot(2,2,[1,2])
 plot(options.binsizean.*1000,tilt(:,1)','-b.')
 hold on
 plot(options.binsizean.*1000,tilt(:,2)','-r.')
 hold on
 plot(options.binsizean.*1000,tilt(:,3)','-g.')
 hold on
 plot(options.binsizean.*1000,tilt(:,4)','-y.')
 axis([xmin xmax ymin ymax])

 xlabel('Binsize (ms)')
 ylabel('Performance')
 legend('Fast,CW','Slow,CW','Fast,CCW','Slow,CCW')
 grid on
 title('Baseline4')
 
subplot(2,2,4)
 plot(options.binsizean.*1000,tilttype(:,1)','-b.')
 hold on
 plot(options.binsizean.*1000,tilttype(:,2)','-r.')
 
 xlabel('Binsize (ms)')
 ylabel('Performance')
 legend('Fast Tilts','Slow Tilts')
 grid on
 axis([xmin xmax ymin ymax])
 
 figure
 plot(options.binsizean.*1000,background(:,2),'-b.')
 grid on




% (diagonals(1)+diagonals(2))/...
%     (sum(confusionmatrix.a(1,:))+sum(confusionmatrix.a(2,:));
% 
% (diagonals(3)+diagonals(4))/...
%     (sum(confusionmatrix.a(3,:))+sum(confusionmatrix.a(4,:));

%ConfusionMatrix(1:B,:)=A{1:B,3};

cd('C:\Users\Nate\Documents\RTNC\RTNC001\111213.RTNC001.Baseline_3\Classifier Outputs')

%export(output,'XLSFile',filename);

