%Nathaniel Bridges
%Tilt Script Runner
%Description: currently designed to run the Recfield and Information Analysis
%scripts, as well as any other supporting functions, GUIs etc. 
%
%$Rev: 33 $
%$Author: Nate $
%$LastChangedDate: 2015-05-03 14:36:56 -0400 (Sun, 03 May 2015) $

%% SETUP
clc; clear; 
addpath(genpath('F:\Matlab\Personal Code\General Purpose Functions'))
addpath('F:\Matlab\Matlab Toolboxes\RECFIELD TOOLBOX')
addpath('F:\Matlab\Matlab Toolboxes\PlexonMatlab\Tilt Toolbox')
%Setup directories for saving and loading files
[~,~]=directory_setup('analysis','recField');
[~,~]=directory_setup('analysis','offlineClassifier',...
    'computer','natePC');

%% CONVERT '.plx' TO '.matnd'

%eventimporter6(1,'experimenttype', 'RAVInew')

GUI_ImportDataFiles   %note: only works if one file in folder
% 
% %Things to copy & paste into above GUI
%     %exp.ratid.type.week.date.

    
   
%% FORMAT TIMESTAMPTS FOR TILT ANALYSIS
tilt_evnt_formatter('dataDir',dataDir,'saveDir',saveDir,...
    'batchDir',batchFolder)

%% RECFIELD ANALYSIS

%Specificy input 'options' for below analyses 
saveFigFldr='F:\Projects\RAVI\Figs\RecField';
 [options, directories]=options_setup('binArray',2,'saveFigFldr',saveFigFldr);

%Peform recfield analysis
close all;  %for debugging only
tic
[fullFilenm,recFieldOutput]=...
    tilt_recfield(options,batchFolder);
toc

%% Email when finished
%{
mail='nathaniel.bridges@gmail.com';
password='llersam4^$2kf^';
subject='RecField';
message='Analysis Done';
gmailcodestatus(mail,password,subject,message)

%% Save output data to specified folder


 save_to_sprdsht(recFieldOutput,'RecField',recfield_resultsfldr)
%}
%% TILT DISCRIMINATION
%}
%Specificy input 'options' for below analyses 
% [options, directories]=options_setup('region',{17:32},...
% 'regionName',{'LCTX'},'binArray',[20],'synRed','Yes');



[options, directories]=options_setup('region',{1:16,17:32,1:32},...
'regionName',{'RCTX','LCTX','BOTH'},'binArray',[20],'synRed','Yes');
options.bootstrapped=1;
options.synred=0;

% [options, directories]=options_setup('region',{1:16},...
% 'regionName',{'RCTX'},'binArray',[20],'synRed','Yes');


%Peform tilt discrimination analysis
[processedCell,errorCell,fullFilenm,tiltDiscriminationOutput]=...
    tilt_discrimination(options,batchFolder);

%Email when finished
mail='nathaniel.bridges@gmail.com';
password='nrb2383757'; %'llersam4^$2kf^';
subject='Tilt Discrimination Update';
message='Info Analysis Done';
gmailcodestatus(mail,password,subject,message)


beep
% 
 %% Save output data to specified folder
save_to_sprdsht(tiltDiscriminationOutput,'tiltDicrimination',...
     informationResultsFldr,'-mat') 
 
 
 save_to_sprdsht(cell2dataset(tempdataset_cell),'tiltDicrimination',...
     informationResultsFldr,'-mat')
% % 
%     
%% TILT DETECTION

%Specificy input 'options' for below analyses 
[options, directories]=options_setup('region',{1:16,17:32,1:32},...
'regionName',{'RCTX','LCTX','BOTH'},'binArray',[20],'synRed','Yes');

% [options, directories]=options_setup('region',{1:16,17:32,1:32},...
% 'regionName',{'RCTX','LCTX','Both'},'binArray',[20]);
% [processedCell,errorCell,fullFilenm,tiltDetectionOutput]=...
%     TiltDetection(options,fullFilenm,'Full');

%Peform tilt detection analysis
[processedCell,errorCell,fullFilenm,tiltDetectionOutput]=...
    tilt_detection(options,batchFolder);

options.bootstrapped=1;
options.synred=0;

%Email when finished
% mail='nathaniel.bridges@gmail.com';
% password='llersam4^$2kf^';
% subject='Tilt Detection Update';
% message='Analysis Done';
% gmailcodestatus(mail,password,subject,message)

%% Save output data to specified folder
save_to_sprdsht(tiltDetectionOutput,'tiltDetection',informationResultsFldr)

