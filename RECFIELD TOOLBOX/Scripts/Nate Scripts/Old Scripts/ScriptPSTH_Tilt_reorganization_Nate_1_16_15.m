%The following script...

%Update date: 010815
%Update: changes to work on Ravi computer and Nate PC/Mac

%% Cleanup & Setup
%clear all;
clc;
PC=1;  %1=Computer, 2=Nate's Mac
tiltdetection=2; %1=means you want to do tilt detection, 2=means you want to do tilt discrimination
confusionmatrix=1; %1 means you want to look at confusion matrix output
filename='Ravi005.Baseline.HLONLY.123014';
batchprocessing=0;

%%
if PC;
    addpath(genpath(matlabdir));
    toolboxpath=toolbox;  %'/Users/Nate/Dropbox/RECFIELD TOOLBOX';
    outputfldr=informationresultsfldr;
else
    addpath(genpath('H:\Computer\Documents\MATLAB'));
    toolboxpath='H:\Computer\Documents\Matlab Toolboxes\RECFIELD TOOLBOX\';
    outputfldr='H:\Tilt Data\RAVI\RAVI mat formatted (for Information)';
    %need to define output directory if using another computer
end

addpath(genpath(toolboxpath));


%% Select files for analysis

[Filename,MatndFileDir,Filterindex] = uigetfile([formatted_datafdr,'\*.matnd']);   %changed from output folder to formatted_datafdr in v 010815
if batchprocessing;
    A = dir(MatndFileDir);
    A = A(3:end) ;
    files = {A.name}' ;
    files{1:end}
    i=1;
    select='N';
    while select=='N'
        result=input('Select range [1 3]: ');
        files{result}
        select=input('Are the above correct (Y/N)? ','s');
    end
    
    filenames{1} = strcat(MatndFileDir,filesep,files{result})
else
    filenames{1}=[MatndFileDir,Filename]
    result=1;
    files{1}=Filename;
end
%% Options

options.pretime = .200;
options.posttime= .200;
options.bin=.001; %in seconds  leave at .001
options.region={17:32};%%1:32; this means number of channels
options.regionname={'CTX'};
options.binsizean=[1 20]/1000;%set binsizes for analysis  doesn't like not having 1
options.fileinfostring='exp.ratid.type.week.date';
options.bootstrapped = 1;   %1 means do bootstrapping  0 means don't do bootstrapping
options.bootstrapnum = 10;  %number of times it bootstraps
%  options.bootstrapCI = 0 ;
options.evchannels=[1 2 3 4 5 6];    %these are the event channels for each tilt type 
%% Tilt Discrimination

%if tiltdetection==2
    
    %%
    summarymat=[];
       %Events 1 through 8 correspond to tilt initiation time stamps for the 8 tilt types
    
    
    
    [dataoutput]=PSTH_Classification_Analysis(filenames,options);
    
    output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,6)...
        dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
        dataoutput(:,11) dataoutput(:,12) dataoutput(:,13)];
    
    %j{1,i}=output;
    %i=i+1;
    newsummat=dataset2cell(output);
    %newsummat{2,size(newsummat,2)+1}=tiltevnts(k);
    summarymat=[summarymat;newsummat([2:2+length(options.binsizean)-1],:)];
    
    disp('Tilt Discrimination Analysis is done !')
    
    
    
    %% Tilt Detection
% %elseif tiltdetection==1
%     
%     %%
    summarymat={'Information','Performance','Binsize','animal','date','exp','stim','NumCells','Bootstrapped','Tilt'};
    tilttot=6;
    %tic
    for q=1:length(result)
        q2=result(q);
        filenames{1} = strcat(MatndFileDir,filesep,files{q2})
        tiltevnts=(1:tilttot);
        backgrndevnts=(tilttot+1:2*tilttot+1);  %changed in 1_8_15 version
        for k=1:tilttot
            options.evchannels=[tiltevnts(k) backgrndevnts(k)];    %Events 1 through 8 correspond to tilt initiation time stamps for the 8 tilt types
            [dataoutput]=PSTH_Classification_Analysis(filenames,options);
            output=[dataoutput(:,1) dataoutput(:,2) dataoutput(:,6)...
                dataoutput(:,8) dataoutput(:,9) dataoutput(:,10)...
                dataoutput(:,11) dataoutput(:,12) dataoutput(:,13)];
            newsummat=dataset2cell(output);
            newsummat{2,size(newsummat,2)+1}=tiltevnts(k);
            summarymat=[summarymat;newsummat([2:2+length(options.binsizean)-1],:)];
        end
    end
%     
% % Define these variables appropriately:
% mail = 'nathaniel.bridges@gmail.com'; %Your GMail email address
% password = 'llersam4^$2kf^';  %Your GMail password
% setpref('Internet','SMTP_Server','smtp.gmail.com');
% 
% 
% setpref('Internet','E_mail',mail);
% setpref('Internet','SMTP_Username',mail);
% setpref('Internet','SMTP_Password',password);
% props = java.lang.System.getProperties;
% props.setProperty('mail.smtp.auth','true');
% props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
% props.setProperty('mail.smtp.socketFactory.port','465');
% 
% % Send the email.  Note that the first input is the address you are sending the email to
% sendmail(mail,'Information Analysis Update','Analysis Complete!')
%     
% else
%     disp('Tilt Detection Type Not Selected')
% end
% %toc
% %%
% cd(outputfldr)
% 
% if computer==2
%     %Below Required for Mac Usage
%     javaaddpath('poi_library/poi-3.8-20120326.jar');
%     javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
%     javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
%     javaaddpath('poi_library/xmlbeans-2.3.0.jar');
%     javaaddpath('poi_library/dom4j-1.6.1.jar');
%     javaaddpath('poi_library/stax-api-1.0.1.jar');
%     
%     xlwrite('Test.xlsx',summarymat)
% else
%     
%     export(summarymat,'XLSFile',filename);
% end
% 
% %%
% if confusionmatrix==1
%     A=ans;  %replace "A" with "output"
%     
%     ConfMat_1=A{1,3};
%     ConfMat_25=A{2,3};
%     ConfMat_50=A{3,3};
%     ConfMat_75=A{4,3};
%     ConfMat_100=A{5,3};
%     ConfMat_150=A{6,3};
%     
%     
%     
%     close
%     xmin=20;
%     xmax=max(options.binsizean.*1000);
%     ymin=0.25;
%     ymax=.95;
%     [cw_vs_ccw,tilt,tilttype,background]=CW_vs_CCW(A,options.binsizean.*1000);
%     %
%     subplot(2,2,3)
%     plot(options.binsizean.*1000,cw_vs_ccw(:,1)','-b.')
%     hold on
%     plot(options.binsizean.*1000,cw_vs_ccw(:,2)','-r.')
%     xlabel('Binsize (ms)')
%     ylabel('Performance')
%     legend('CW','CCW')
%     grid on
%     axis([xmin xmax ymin ymax])
%     
%     subplot(2,2,[1,2])
%     plot(options.binsizean.*1000,tilt(:,1)','-b.')
%     hold on
%     plot(options.binsizean.*1000,tilt(:,2)','-r.')
%     hold on
%     plot(options.binsizean.*1000,tilt(:,3)','-g.')
%     hold on
%     plot(options.binsizean.*1000,tilt(:,4)','-y.')
%     axis([xmin xmax ymin ymax])
%     
%     xlabel('Binsize (ms)')
%     ylabel('Performance')
%     legend('Fast,CW','Slow,CW','Fast,CCW','Slow,CCW')
%     grid on
%     title('Baseline4')
%     
%     subplot(2,2,4)
%     plot(options.binsizean.*1000,tilttype(:,1)','-b.')
%     hold on
%     plot(options.binsizean.*1000,tilttype(:,2)','-r.')
%     
%     xlabel('Binsize (ms)')
%     ylabel('Performance')
%     legend('Fast Tilts','Slow Tilts')
%     grid on
%     axis([xmin xmax ymin ymax])
%     
%     figure
%     plot(options.binsizean.*1000,background(:,2),'-b.')
%     grid on
%     
    
    
    
    % (diagonals(1)+diagonals(2))/...
    %     (sum(confusionmatrix.a(1,:))+sum(confusionmatrix.a(2,:));
    %
    % (diagonals(3)+diagonals(4))/...
    %     (sum(confusionmatrix.a(3,:))+sum(confusionmatrix.a(4,:));
    
    %ConfusionMatrix(1:B,:)=A{1:B,3};
    
    %cd('C:\Users\Nate\Documents\RTNC\RTNC001\111213.RTNC001.Baseline_3\Classifier Outputs')
    
    %export(output,'XLSFile',filename);
%end

