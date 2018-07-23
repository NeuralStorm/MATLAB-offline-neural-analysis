% This script has been modified to analyze the treadmill recordings for
% Chronic Sensorimotor reorganization ( CSR animals) only. I have changed
% the parameters in receptivefield_CSR.m using Tina Kao's paper 2011
% Neurophysiology. 


clear all;
clc;
% [psth,list]=search_files(pwd,'matnd');
% files=list(logical(1-cellfun(@isempty,regexpi(list,'trm'))));

A = dir('E:\Chronic Brain Reorganization after SCI\Treadmill Files\020113.CSR010.TRM.WEEK0\.*matnd');
files = {A.name}';
options.pretime = 0.25;
options.posttime = 0.25 ;
options.bin = 0.005 ;
options.region={1:16,17:32};
options.regionname={'LCTX','RCTX'};
options.binsizean=[5]/1000;
options.explab='file';
% options.IpsiContra=1;
options.TRM=1;
% options.evnames={'LFP','LHPNWSS','LHPWSS',{'LHPNWSS','LHPWSS'},'RFP','RHPNWSS','RHPWSS',{'RHPNWSS','RHPWSS'}};
options.evnames = {'LF','RH','RF','LH'};
CSR010_TRM_Week0 = Rec_Field_Analysis(files,options);                          
