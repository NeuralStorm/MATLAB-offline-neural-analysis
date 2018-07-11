% =====
% TIPS
% =====
% - For exploratory analysis using GPFA, we often run only Section 1
%   below, and not Section 2 (which finds the optimal latent
%   dimensionality).  This can provide a substantial savings in running
%   time, since running Section 2 takes roughly K times as long as
%   Section 1, where K is the number of cross-validation folds.  As long
%   as we use a latent dimensionality that is 'large enough' in Section 1,
%   we can roughly estimate the latent dimensionality by looking at
%   the plot produced by plotEachDimVsTime.m.  The optimal latent
%   dimensionality is approximately the number of top dimensions that
%   have 'meaningful' temporal structure.  For visualization purposes,
%   this rough dimensionality estimate is usually sufficient.
%
% - For exploratory analysis with the two-stage methods, we MUST run
%   Section 2 to obtain the optimal smoothing kernel width.  There is
%   no easy way estimate the optimal smoothing kernel width from the
%   results of Section 1.

clear
clc

%% Offline sorter for neural spike data
%Functions needed that I will provide: 
% plx_info, plx_ts, plx_event_chanmap,plx_event_ts, Eventspiketimes, graphPSTH, normcount

clear
clc
% With this you will need to select the .plx file that I send you, and it
% will take the spike times and event times
[file,path]=uigetfile('*.plx');

datafile = [path,file];
[tscounts, wfcounts, evcounts, slowcounts] = plx_info(datafile,1); 

%%
    % Fixed: Problems with PRAC 03 day 23
    % Modified above code to be more robust, should work going forward,
    % may need to revisit if encountering unexpected problems.
    % 
    %
[nunits1, nchannels1] = size( tscounts ); 
allts = cell(nunits1, nchannels1);
for iunit = 0:nunits1-1   % starting with unit 0 (unsorted) 
    for ich = 1:nchannels1-1
        if ( tscounts( iunit+1 , ich+1 ) > 0 )
            % get the timestamps for this channel and unit 
            [nts, allts{iunit+1,ich}] = plx_ts(datafile, ich , iunit );
         end
    end
end
svStrobed=[];
svdummy=[];
% and finally the events
[u,nevchannels] = size( evcounts );  
if ( nevchannels > 0 ) 
    % need the event chanmap to make any sense of these
    [u,evchans] = plx_event_chanmap(datafile);
	for iev = 1:nevchannels
		if ( evcounts(iev) > 0 )
            evch = evchans(iev);
            if ( evch == 257 )
				[nevs{iev}, tsevs{iev}, svStrobed] = plx_event_ts(datafile, evch); 
			else
				[nevs{iev}, tsevs{iev}, svdummy{iev}] = plx_event_ts(datafile, evch);
            end
		end
	end
end

events=[];
j=0;
if length(svStrobed)>1
    events = tsevs{1,17};
    events = [svStrobed,events];
else
    for i=1:length(evcounts)
        if evcounts(i) >= 100
            [nevs{i}, tsevs{i}, svdummy] = plx_event_ts(datafile, i);
            j=j+1;
            eventsingle(1:evcounts(i),1)=j;
            events= [events;eventsingle,tsevs{i}];
            eventsingle=[];
        end
    end
    for i=1:length(events)
        if events(i,1)==2
            events(i,1)=3;
        elseif events(i,1)==3
            events(i,1)=4;
        elseif events(i,1)==4
            events(i,1)=6;
        end
    end
end

%% Removes Doubles and Triples from events
i=1;
while i <= length(events)-1
    if abs(events(i,2)-events(i+1,2)) < 2
        events(i+1,:) = [];
    end
    i = i+1;
end
i=1;
while i <= length(events)-1
    if abs(events(i,2)-events(i+1,2)) < 2
        events(i+1,:) = [];
    end
    i = i+1;
end
i=1;
while i <= length(events)-1
    if abs(events(i,2)-events(i+1,2)) < 2
        events(i+1,:) = [];
    end
    i = i+1;
end

spk = [];

% Separate Right & Left Hemispheres
hemisphere = input('Choose Right(1) or Left(2) Hemisphere: ');

if hemisphere == 1
    
    % When plotting graphs label figures with specific figure name, NOT
    % just Figure(#)
    hemiSide = 'Right Hemisphere'; % Used to label Figure as 'Right Hemisphere'
    for i = 1:16
        for j = 2:5
            if length(allts{j,i}) >= 1 ;
                spk = [spk,allts(j,i)];
            end
        end
    end

else 
    hemiSide = 'Left Hemisphere'; % Used to label Figure as 'Left Hemisphere'
    for i = 17:32
        for j = 2:5
            if length(allts{j,i}) >= 1 ;
                spk = [spk,allts(j,i)];
            end
        end
    end
end

spiketimes=spk;

%%
%Organize Events into individual variables that hold all timestamps of a
%single event type
%For angle data, right is positive, left is negative

event1=[]; %Right Fast
event3=[]; %Right Slow
event4=[]; %Left  Fast
event6=[]; %Left  Slow
for i=1:length(events)
    if events(i,1)==1
        event1=[event1; events(i,2)];
    elseif events(i,1)==3
        event3=[event3; events(i,2)];
    elseif events(i,1)==4
        event4= [event4; events(i,2)];
    else
        event6= [event6; events(i,2)];
    end
end

newspikes=[];

for i=1:length(spiketimes)
    for j=1:length(spiketimes{1,i})
    newspikes(i,j)=spiketimes{1,i}(j);
    end
end
%% Bin is now 1 ms 
%bin size is 0.005 seconds (5ms)
%Using Goodneurons rn instead of spiketimes
dimensions=length(spiketimes);
bin = 0.001;
edge=0:bin:0.4;

% classifier bin size
binsize=.001;  %seconds

% classifier window before time zero 
pretime=-.2;   %seconds

% classifier window after time zero 
posttime=.2;   %seconds

%edge endpoints are extended to solve a problem using discretize.


%totalrelspikes is the (400 trials)x(Bins*Neurons) matrix which has each event trial for each
%neuron with data put into 100 bins (-0.2 : 0.2) seconds.
%Binned every 1 ms(see edge above)

[relspikes1]= Eventspiketimes(event1, newspikes, edge);
[relspikes3]= Eventspiketimes(event3, newspikes, edge);
[relspikes4]= Eventspiketimes(event4, newspikes, edge);
[relspikes6]= Eventspiketimes(event6, newspikes, edge);


%This next one is important-has spikes in bins

reltotalspikes = [relspikes1;relspikes3;relspikes4;relspikes6];


%% Uses graphPSTH to create a single PSTH for a neuron given an event
% Uses graphtestPSTH to create a PSTH which represents every trial except one, so that the left out trial can be used to test a decoder.

% % neuronnum= input('Enter Neuron Number(1-#neurons):');
% % graphPSTH(neuronnum,reltotalspikes,edge);

%% Creates a matrix of spikes to perform pca on
%sums each column (bin) for every neuron on a per event basis.

count1 = sum(relspikes1);
count2 = sum(relspikes3);
count3 = sum(relspikes4);
count4 = sum(relspikes6);

%% Normalize counts

[normcount1] = normcount(count1, edge);
[normcount2] = normcount(count2, edge);
[normcount3] = normcount(count3, edge);
[normcount4] = normcount(count4, edge);



%%  PCA

pcacount1=[];
pcacount2=[];
pcacount3=[];
pcacount4=[];


for i=1:dimensions
    pcacount1(1:(length(edge)-1),i)=normcount1((1:length(edge)-1)+((i-1)*(length(edge)-1)));
    pcacount2(1:(length(edge)-1),i)=normcount2((1:length(edge)-1)+((i-1)*(length(edge)-1)));
    pcacount3(1:(length(edge)-1),i)=normcount3((1:length(edge)-1)+((i-1)*(length(edge)-1)));
    pcacount4(1:(length(edge)-1),i)=normcount4((1:length(edge)-1)+((i-1)*(length(edge)-1)));
end



pcatotalcount=[];
coeff=[]; %PC by column
pcascore=[];
latent=[]; % eigenvalues
tsquared=[]; % Hotelling's T-squared statistic for each observation
explained=[]; % eigenvalue percentage of total variance
mu=[]; % estimated mean of each variable

%pcatotalcount is a matrix with the counts such that the bins have been
%transposed so that pca can be performed

pcatotalcount=[pcacount1;pcacount2;pcacount3;pcacount4];
[coeff,pcascore,latent,tsquared,explained,mu]=pca(pcatotalcount);

%% Plot PCA from 1 to N
%Explained is percentage of total variance in each PC

% %  figure;
% %  plot(explained) %Figure 1: This plot will show how much variance is explained by each Principal Component (PC)
% %  figure
% %  for i =1:length(explained)
% %      sumexplained(i) = sum(explained(1:i));
% %  end
% %  plot(sumexplained) %Figure 2: This plot will show what percentage (out of 100) of the variance is explained by by using each PC from 1 to x.
 
 %% Graph PCs
%Sumexplained shows a cumulative sum of the variance percentage
%Choose N for how many PC to graph

% % N=input('How Many PCs would you like to graph (1-# of neurons)? ');
% % for i=1:N
% %     figure 
% %     hold on
% %     pca1=pcascore(1:400,i);
% %     pca2=pcascore(401:800,i);
% %     pca3=pcascore(801:1200,i);
% %     pca4=pcascore(1201:1600,i);
% %     plot(pca1);
% %     plot(pca2);
% %     plot(pca3);
% %     plot(pca4);
% %     legend('Tilt 1','Tilt 3','Tilt 4','Tilt 6');
% %     title([file,' PC',num2str(i)]);
% %     hold off
% % end

%pca(1,2,3,4) will graph the pc score relative to an event(tilt 1,3,4,6)
%(1:Right Fast, 3:Right Slow, 4:Left Fast, 6:Left Slow)

%Compare PCs- Plots PC1 against PC#
% % for i=2:N
% %     compca1=pcascore(1:400,[1,i])';
% %     compca2=pcascore(401:800,[1,i])';
% %     compca3=pcascore(801:1200,[1,i])';
% %     compca4=pcascore(1201:1600,[1,i])';
% %     figure
% %     hold on
% %     scatter(compca1(1,:),compca1(2,:));
% %     scatter(compca2(1,:),compca2(2,:));
% %     scatter(compca3(1,:),compca3(2,:));
% %     scatter(compca4(1,:),compca4(2,:));
% %     legend('Tilt 1','Tilt 3','Tilt 4','Tilt 6');
% %     hold off
% % end
%% 

%Added from other code PSTHclassifer_example_code_original.m
% create PSTH object 
plxDir = path;
plxName = file;

if ~isempty(tsevs(17)) 
    strobed_events = true;
else
    strobed_events = false;
end
decoderPath='+NeuroToolbox/';

% load neuron timestamps "neuronsIn" and event timestamps "eventTS"
if strobed_events
    [neuronsIn, eventTS] = plx2mat3(plxDir, plxName,decoderPath);
    Reference=eventTS;
else
    [neuronsIn, eventTS] = plx2mat3(plxDir, plxName);
    % remove blank event timestamps
    Reference=eventTS(:,~cellfun(@isempty,eventTS(2,:)))';
end

% warn user if size of eventTS matrix unusual 
if size(Reference,1)~=4
    warning('on')
    warning(['You have ',num2str(size(eventTS,1)),...
        ' tilt events when you should have 4'])
    warning('Open "eventTS" variable and investigate')
end

% remove neuron waveform data 
Spikes=neuronsIn(:,[1,2]);
totalSpikesLength = length(Spikes);
if hemisphere == 1
    Spikes = Spikes(1:length(spk),:);
else
    Spikes = Spikes((totalSpikesLength-length(spk)+2:end),:);
end

PSTH = NeuroToolbox.PSTHToolbox.PSTH(Spikes,Reference,...
    'bin_size',binsize,'PSTH_window',[pretime,posttime],...
    'show_progress',true);

% create template from PSTH object
template = NeuroToolbox.PSTHToolbox.SU_Classifier(PSTH);

% peform classification using template 
DecoderOutput = template.classify(Spikes,Reference,...
    'SameDataSet',true);

% quantify performance
Correct_Trials = cellfun(@strcmp,DecoderOutput.Decision,DecoderOutput.Event);
Accuracy=mean(Correct_Trials)

%% Get Correct Trials

newreltotalspikes = [];
for i = 1:length(Correct_Trials)
    if Correct_Trials(i)
        newreltotalspikes = [newreltotalspikes ; reltotalspikes(i,:)];
    end
end


%% Organize Data
% Puts data from reltotalspikes into format for GPFA

[rows, columns] = size(newreltotalspikes);
% While loop to create structure data with first field 'fieldId'
k = 1; %Initialize variable k for while loop
while k < rows+1
    dat(k).trialId = k;
    k = k+1;
end

timeSlots = (length(edge)-1);
newTimeSlots = timeSlots;

% Organize reltotalspikes into an array
newTimeSlots = timeSlots;
x = 1; % Initialize variable for while loop
rtspikes(x).neuron = [reshape(newreltotalspikes(1,:), timeSlots, dimensions)]';
x = x + 1;

while newTimeSlots < (columns)
    while x < (rows + 1)
        rtspikes(x).neuron = [reshape(newreltotalspikes(x,:), timeSlots, dimensions)]';
        newTimeSlots = newTimeSlots + timeSlots;
        x = x + 1;
    end
end

newTimeSlots = timeSlots;
n = 1; %Initialize variable n for while loop
dat(n).spikes = rtspikes(n).neuron;
while newTimeSlots < (columns)
    while n < (rows + 1)
        dat(n).spikes = rtspikes(n).neuron;
        newTimeSlots = newTimeSlots + timeSlots;
        n = n + 1;
    end
end

uisave('dat');


%% Done
disp('done')

[file1,path1]=uigetfile('*.mat'); % Gets all table files
load([path1,file1])

%% ===========================================
% 1) Basic extraction of neural trajectories
% ===========================================
%load('C:\Users\Adrian & Gloria\Desktop\UC LEADS\Moxon Lab\gpfa_v0203\gpfa_v0203\mat_sample\sample_dat');
%load('C:\Users\Adrian & Gloria\Desktop\UC LEADS\Moxon Lab\ourData2'); % Our version of Data

% Results will be saved in mat_results/runXXX/, where XXX is runIdx.
% Use a new runIdx for each dataset.

cd('C:\Users\Adrian & Gloria\Desktop\UC LEADS\Moxon Lab\gpfa_v0203\gpfa_v0203');
runIdx = input('Enter Run Index Number: ');

% Select method to extraclcct neural trajectories:
% 'gpfa' -- Gaussian-process factor analysis
% 'fa'   -- Smooth and factor analysis
% 'ppca' -- Smooth and probabilistic principal components analysis
% 'pca'  -- Smooth and principal components analysis
method = 'pca';

% Select number of latent dimensions
xDim = 8;
% NOTE: The optimal dimensionality should be found using 
%       cross-validation (Section 2) below.

% If using a two-stage method ('fa', 'ppca', or 'pca'), select
% standard deviation (in msec) of Gaussian smoothing kernel.
kernSD = 30;
% NOTE: The optimal kernel width should be found using 
%       cross-validation (Section 2) below.

% Extract neural trajectories
result = neuralTraj(runIdx, dat, 'method', method, 'xDim', xDim,... 
                    'kernSDList', kernSD);
% NOTE: This function does most of the heavy lifting.

% Orthonormalize neural trajectories
[estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
% NOTE: The importance of orthnormalization is described on 
%       pp.621-622 of Yu et al., J Neurophysiol, 2009.

% Plot neural trajectories in 3D space

plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3);
savefig(input('Figure Name: '));
% uisave(savefig);
% NOTES:
% - This figure shows the time-evolution of neural population
%   activity on a single-trial basis.  Each trajectory is extracted from
%   the activity of all units on a single trial.
% - This particular example is based on multi-electrode recordings
%   in premotor and motor cortices within a 400 ms period starting 300 ms 
%   before movement onset.  The extracted trajectories appear to
%   follow the same general path, but there are clear trial-to-trial
%   differences that can be related to the physical arm movement. 
% - Analogous to Figure 8 in Yu et al., J Neurophysiol, 2009.
% WARNING:
% - If the optimal dimensionality (as assessed by cross-validation in 
%   Section 2) is greater than 3, then this plot may mask important 
%   features of the neural trajectories in the dimensions not plotted.  
%   This motivates looking at the next plot, which shows all latent 
%   dimensions.

% Plot each dimension of neural trajectories versus time
plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
% NOTES:
% - These are the same neural trajectories as in the previous figure.
%   The advantage of this figure is that we can see all latent
%   dimensions (one per panel), not just three selected dimensions.  
%   As with the previous figure, each trajectory is extracted from the 
%   population activity on a single trial.  The activity of each unit 
%   is some linear combination of each of the panels.  The panels are
%   ordered, starting with the dimension of greatest covariance
%   (in the case of 'gpfa' and 'fa') or variance (in the case of
%   'ppca' and 'pca').
% - From this figure, we can roughly estimate the optimal
%   dimensionality by counting the number of top dimensions that have
%   'meaningful' temporal structure.   In this example, the optimal 
%   dimensionality appears to be about 5.  This can be assessed
%   quantitatively using cross-validation in Section 2.
% - Analogous to Figure 7 in Yu et al., J Neurophysiol, 2009.

fprintf('\n');
fprintf('Basic extraction and plotting of neural trajectories is complete.\n');
fprintf('Press any key to start cross-validation...\n');
fprintf('[Depending on the dataset, this can take many minutes to hours.]\n');
% savefig('ourGraph');
%pause;


%% ========================================================
% 2) Full cross-validation to find:
%  - optimal state dimensionality for all methods
%  - optimal smoothing kernel width for two-stage methods
% ========================================================

% Select number of cross-validation folds
numFolds = 4;

% Perform cross-validation for different state dimensionalities.
% Results are saved in mat_results/runXXX/, where XXX is runIdx.
for xDim = [2 5 8]
  neuralTraj(runIdx, dat, 'method',  'pca', 'xDim', xDim, 'numFolds', numFolds);
  neuralTraj(runIdx, dat, 'method', 'ppca', 'xDim', xDim, 'numFolds', numFolds);
  neuralTraj(runIdx, dat, 'method',   'fa', 'xDim', xDim, 'numFolds', numFolds);
  neuralTraj(runIdx, dat, 'method', 'gpfa', 'xDim', xDim, 'numFolds', numFolds);
end
fprintf('\n');
% NOTES:
% - These function calls are computationally demanding.  Cross-validation 
%   takes a long time because a separate model has to be fit for each 
%   state dimensionality and each cross-validation fold.

% Plot prediction error versus state dimensionality.
% Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
kernSD = 30; % select kernSD for two-stage methods
plotPredErrorVsDim(runIdx, kernSD);
% NOTES:
% - Using this figure, we i) compare the performance (i.e,,
%   predictive ability) of different methods for extracting neural
%   trajectories, and ii) find the optimal latent dimensionality for
%   each method.  The optimal dimensionality is that which gives the
%   lowest prediction error.  For the two-stage methods, the latent
%   dimensionality and smoothing kernel width must be jointly
%   optimized, which requires looking at the next figure.
% - In this particular example, the optimal dimensionality is 5. This
%   implies that, even though the raw data are evolving in a
%   53-dimensional space (i.e., there are 53 units), the system
%   appears to be using only 5 degrees of freedom due to firing rate
%   correlations across the neural population.
% - Analogous to Figure 5A in Yu et al., J Neurophysiol, 2009.

% Plot prediction error versus kernelSD.
% Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
xDim = 5; % select state dimensionality
plotPredErrorVsKernSD(runIdx, xDim);
% NOTES:
% - This figure is used to find the optimal smoothing kernel for the
%   two-stage methods.  The same smoothing kernel is used for all units.
% - In this particular example, the optimal standard deviation of a
%   Gaussian smoothing kernel with FA is 30 ms.
% - Analogous to Figures 5B and 5C in Yu et al., J Neurophysiol, 2009.
