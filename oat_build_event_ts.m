function output = oat_build_event_ts(MatFile)
% collects liftoff times from Marissa Powers' kinematic data and
% builds the event_ts matrix the parser needs

%% Debugging Code: build path and load .mat file
%clear all %used for debuging
%original_path = 'C:\Users\mahan\OneDrive\Documents\MATLAB\Powers OAT\Animals\EMG015';%used for debuging
%file_path = strcat(original_path,'\','EMG015_group_condition_1_20131106_option.mat');%used for debuging
%MatFile=load(file_path);%used for debuging

%% Ensure necessary arrays are vertical
LO_L=MatFile.LO_L; %Lift of times for left paw
[H,W]=size(LO_L); 
if H==1
    LO_L = LO_L'; %Transpose array if it is horizontal
end
LO_R=MatFile.LO_R; %lift of times for right paw
[H,W]=size(LO_R);
if H==1
    LO_R = LO_R'; %Transpose array if it is horizontal
end
L_Leading_L_Liftoffs_over=MatFile.L_Leading_L_Liftoffs_over; %times the left paw steped over obstacle
[H,W]=size(L_Leading_L_Liftoffs_over);
if H==1
    L_Leading_L_Liftoffs_over = L_Leading_L_Liftoffs_over'; %Transpose array if it is horizontal
end
R_Leading_R_Liftoffs_over=MatFile.R_Leading_R_Liftoffs_over; %times right paw steped over obstacle
[H,W]=size(MatFile.R_Leading_R_Liftoffs_over);
if H==1
    MatFile.R_Leading_R_Liftoffs_over = MatFile.R_Leading_R_Liftoffs_over'; %Transpose array if it is horizontal
end

%% Collecting necessary kinimatic data into one matrix
% column 1: lift off timestamp
% column 2: Paw number (1 for left paw, 2 for right paw)
% column 3: steps from the obstacle (assigned in later code block)
% column 4: Next lift off timestamp
% column 5: Event ID # (assigned in later code block)

%collect data for steps made by the left paw
LeftSteps = [LO_L,ones(length(LO_L),1),zeros(length(LO_L),1)];
%collect data for steps made by the right paw
RightSteps = [LO_R,ones(length(LO_R),1)*2,zeros(length(LO_R),1)];
%collect the next Lift off times
%for the left paw
for i=1:length(LO_L)
    if i==length(LO_L) %if on the last step
        LeftSteps(i,4) = nan; % no next lift off time aviable for the last step
    else
        LeftSteps(i,4) = LO_L(i+1); % next lift off time is the lift off time of the next step
    end
end
% and the right paw
for i=1:length(LO_R)
    if i==length(LO_R) %if on the last step
        RightSteps(i,4) = nan; % no next lift off time aviable for the last step
    else
        RightSteps(i,4) = LO_R(i+1); % next lift off time is the lift off time of the next step
    end
end
%combine into one matrix
Steps = [LeftSteps; RightSteps];
Steps = sortrows(Steps,1);

%% Assign steps away from obstacle to column 3
% assign values for trials where the left paw stepped over the obstacle
for i=1:length(L_Leading_L_Liftoffs_over)
    Index=find(Steps(:,1)==L_Leading_L_Liftoffs_over(i));% finds the location of the step over
    for j=1:length(Steps(:,1))
        if i==1
            Steps(j,3)=j-Index; %assigns initial values
        else
            if abs(j-Index)<abs(Steps(j,3))
                % reassigns the value if this step is closer to the current
                % obstacle then it is to the obstacle it was previsouly
                % assigned as closest to
                Steps(j,3)=j-Index;
            end
        end
    end
end
%repeat process for trials where the right paw stepped over the obstacle
for i=1:length(R_Leading_R_Liftoffs_over)
    Index=find(Steps(:,1)==R_Leading_R_Liftoffs_over(i));% finds the location of the step over
    for j=1:length(Steps(:,1))
        if abs(j-Index)<abs(Steps(j,3))
            % reassigns the value if this step is closer to the current
            % obstacle then it is to the obstacle it was previsouly
            % assigned as closest to
            Steps(j,3)=j-Index;
        end
    end
end
    
%% Remove steps that have nan valvues      %are too far from an obstacle
Remove=isnan(Steps(:,4)); %identify steps that have no end time  %abs(Steps(:,3))>6;% identify steps that are too from the obstacle
Steps(Remove,:)=[];% delete those steps

%% Build an event id hash and assign it to column 5
%if parser requires first column to be whole numbers
for i=1:size(Steps,1)
    if abs(Steps(i,3))>7 %steps that are far away from the obstacle...
        Steps(i,5)=999; %are used for the baseline event
    else
        Steps(i,5)=(Steps(i,3)+7)*10+Steps(i,2); %steps near the obstacle are given a specific event number
    end
end
%if parser allows first column to be integers
%for i=1:length(Steps(:,1))
%    if Steps(i,3)<0
%        Steps(i,5)=Steps(i,3)*10-Steps(i,2);
%    else
%        Steps(i,5)=Steps(i,3)*10+Steps(i,2);
%    end
%end


%% Build final Output matrix
%output=[Steps(:,5), Steps(:,1)];
output=[Steps(:,5), Steps(:,1)/100, Steps(:,4)/100];


end