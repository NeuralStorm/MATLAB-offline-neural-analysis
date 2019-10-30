%% Code requirments
% this .m file needs to have the .mat file containing Marissa Power's
% kinematic data from the recording session loaded into the workspace.
% Those .mat files have a file name following this structure:
% [month].[day].[year].[animal#].[recording session] Workspace.mat 


%% Slightly edited copy of a segment Marissa Powers' orgional code. 
%does some calculations Powers thought coulden't be done for the last step of the recording session
SL_R = RtX(next_FF_R(1:length(LO_R)))-RtX(LO_R(1:length(LO_R)));
SL_L = LtX(next_FF_L(1:length(LO_L)))-LtX(LO_L(1:length(LO_L)));
for i=1:length(LO_R)
    % Looking at a single step, find the max RtY value
    RtY_OI = max(RtY(LO_R(i):next_FF_R(i)));
    % Take the max height - min height for each step ... if animal shifts
    % left and right on TM, or along the z-axis, the y-coordinate will
    % shift up and down.  This removes that effect on toe height.
    RtY_OI_abs = RtY_OI - min(RtY(LO_R(i):next_FF_R(i)));
    % Return all frame numbers corresponding to this value
    fn_array = find(RtY==RtY_OI);  
    % Return single frame number that falls between LO(i) and FF(i)
    fn = fn_array(find(fn_array>=LO_R(i) & fn_array<=next_FF_R(i)));
    fn = fn(1);
    R_toeHeight(i,:) = [fn RtY_OI RtY_OI_abs]; %[(frame number) (toe Y value) (ht absol value)]
end
for i=1:length(LO_L)
    % Looking at a single step, find the max LtY value
    LtY_OI = max(LtY(LO_L(i):next_FF_L(i)));
    LtY_OI_abs = LtY_OI - min(LtY(LO_L(i):next_FF_L(i)));
    % Return all frame numbers corresponding to this value
    fn_array = find(LtY==LtY_OI);  
    % Return single frame number that falls between LO(i) and FF(i)
    fn = fn_array(find(fn_array>=LO_L(i) & fn_array<=next_FF_L(i)));
    fn = fn(1);
    L_toeHeight(i,:) = [fn LtY_OI LtY_OI_abs];
end

%% collecting kinimatic data into one big matrix
%column 1: a unique ID number for each step
    %will be assigned in next code section
%column 2: Paw# (1 for left paw, 2 for right)
%column 3: Lift off times
%column 4: foot fall times
%column 5: stride length
%column 6: max toe hiehgt
%column 7: swing duration
%column 8: stride duration
%column 9: stance duration
%column 10: swing speed
%column 11: steps from the obstacle. 
    %Will be created and assigned in code section after next

%collect data for steps made by left paw for columns 1 through 7
LeftSteps = [zeros(length(LO_L),1),ones(length(LO_L),1),LO_L,next_FF_L,SL_L,L_toeHeight(:,3),next_FF_L-LO_L]; 
%calculate values for columns 8 through 10. 
%These values can't be calculated for the last step of the session
%so those are left as zero
for i=1:length(LO_L)-1
    LeftSteps(i,8)=LO_L(i+1)-LO_L(i);%Stride duration
    LeftSteps(i,9)=LeftSteps(i,7)-LeftSteps(i,6);%Stance duration
    LeftSteps(i,10)=LeftSteps(i,4)/LeftSteps(i,6);%Swing Speed
end
%values that cant be calcuated for last step
LeftSteps(i+1,8)=0;
LeftSteps(i+1,9)=0;
LeftSteps(i+1,10)=0;

%repeat process for steps done with the right paw
RightSteps = [zeros(length(LO_R),1),ones(length(LO_R),1)+ones(length(LO_R),1),LO_R,next_FF_R,SL_R,R_toeHeight(:,3),next_FF_R-LO_R]; 
for i=1:length(LO_R)-1
    RightSteps(i,8)=LO_R(i+1)-LO_R(i);%stride duration
    RightSteps(i,9)=RightSteps(i,7)-RightSteps(i,6);%stance duration
    RightSteps(i,10)=RightSteps(i,4)/RightSteps(i,6);%Swing Speed
end
%values that cant be calcuated for last step
RightSteps(i+1,8)=0;
RightSteps(i+1,9)=0;
RightSteps(i+1,10)=0;

%% collecting left steps and right steps into one matrix
Steps = [LeftSteps; RightSteps];
Steps = sortrows(Steps,3);%Sort by lift off time
for i=1:length(Steps(:,1))
    Steps(i,1)=i;%adding step index
end

%% Determining how many steps away from an obstcle a specific step was
% Also starts building seperate matricies for trials where the left paw
% stepped over the obstacle and trials where the right paw stepped over the
% obstacle
Steps(:,11)=max(Steps(length(Steps(:,1))),1);%initilizing steps from obstacle column to a maximum value
%Processing times where the left paw was the paw that stepped over
for i=1:length(L_Leading_L_Liftoffs_over)
    Index=find(Steps(:,3)==L_Leading_L_Liftoffs_over(i));%fiding the step index of times the left paw steped over
    for j=1:length(Steps(:,1))
        if abs(Steps(j,1)-Index)<abs(Steps(j,11))
            Steps(j,11)=Steps(j,1)-Index; %setting the number of steps from obstacle. zero is the step over the obstacle.
        end
    end
    if i==1
        LeftLeadingSteps=Steps(max(1,Index-6):Index+6,:);%initalizing matrix of trials where the left paw steped over
    else
        LeftLeadingSteps=[LeftLeadingSteps;Steps(Index-6:min(length(Steps(:,1)),Index+6),:)];%adds additional trials to the matrix of left paw step over
    end
end
%Repeat process for times the right paw was the paw that steped over
for i=1:length(R_Leading_R_Liftoffs_over)
    Index=find(Steps(:,3)==R_Leading_R_Liftoffs_over(i));%Fiding the step index of times the right paw stepped over
    for j=1:length(Steps(:,1))
        if abs(Steps(j,1)-Index)<abs(Steps(j,11))
            Steps(j,11)=Steps(j,1)-Index; %setting the number of steps from obstacle
        end
    end
    if i==1
        RightLeadingSteps=Steps(max(1,Index-6):Index+6,:);%initalizing matrix of trials where the right paw steped over
    else
        RightLeadingSteps=[RightLeadingSteps;Steps(Index-6:min(length(Steps(:,1)),Index+6),:)];%adds additional trials to the matrix of right paw step over
    end
end

%% Creating event_ts matrix that the parser for PSTH analysis needs
event_ts=[0 0];
j=1;
%pulling out event type and event timestamps from right paw stepping over
%trials
for i=1:length(RightLeadingSteps(:,1))
    %create a whole number for event type. Ones digit is paw number, 1 for left paw, 2 for right.
    %tens/hundres digit is steps from obstacle.
    %40's is two steps before obstacle
    %50's is step before obstacle
    %60's is step over obstacle
    %70's is step after obstacle
    %80's is two steps after obstacle
    %Examples:
    %41=Left paw took the step two steps before stepping over the obstacle
    %42=Right paw took the step two steps before stepping over the obstacle
    %51=Left paw took the step before stepping over the obstacle
    %52=Right paw took the step before stepping over the obstacle
    %61=Left paw stepped over the obstacle
    %62=Right paw stepped over the obstacle
    %71=Left paw took the first step after stepping over the obstacle
    %72=Right paw took the first step after stepping over the obstacle
    %81=Left paw took the second step after stepping over the obstacle
    %82=Right paw took the second step after stepping over the obstacle
    %etc
    event_ts(j,1)=(RightLeadingSteps(i,11)+6)*10+RightLeadingSteps(i,2); 
    event_ts(j,2)=RightLeadingSteps(i,3); %timestamp for the step
    j=j+1;
end
%repeat process for trials where the left paw stepped over
for i=1:length(LeftLeadingSteps(:,1))
    event_ts(j,1)=(LeftLeadingSteps(i,11)+6)*10+LeftLeadingSteps(i,2);
    event_ts(j,2)=LeftLeadingSteps(i,3);
    j=j+1;
end
        
%% Convering to tables and adding column headers
StepTable=array2table(Steps);
StepTable.Properties.VariableNames = {'Step_Number','One_For_Left_Two_For_Right','Liftoff_Time','Footfall_Time','Stride_Length','Max_Toe_Height','Swing_Duration','Stride_Duration','Stance_Duration','Swing_Speed','Steps_From_Obstacle'};
LeftLeadingStepTable=array2table(LeftLeadingSteps);
LeftLeadingStepTable.Properties.VariableNames = {'Step_Number','One_For_Left_Two_For_Right','Liftoff_Time','Footfall_Time','Stride_Length','Max_Toe_Height','Swing_Duration','Stride_Duration','Stance_Duration','Swing_Speed','Steps_From_Obstacle'};
RightLeadingStepTable=array2table(RightLeadingSteps);
RightLeadingStepTable.Properties.VariableNames = {'Step_Number','One_For_Left_Two_For_Right','Liftoff_Time','Footfall_Time','Stride_Length','Max_Toe_Height','Swing_Duration','Stride_Duration','Stance_Duration','Swing_Speed','Steps_From_Obstacle'};
event_ts_table = array2table(event_ts);
event_ts_table.Properties.VariableNames = {'Event_code','Event_timestamp'};

%% Collecting into a structure for Json export if necessary
JsonOutputStructure=struct();
FullDate = strcat("y",year,"m",month,"d",day);
JsonOutputStructure.(anim).(FullDate).Kinematics.AllSteps=StepTable;
JsonOutputStructure.(anim).(FullDate).Kinematics.LeftLeadingSteps=LeftLeadingStepTable;
JsonOutputStructure.(anim).(FullDate).Kinematics.RightLeadingSteps=RightLeadingStepTable;
JsonOutputStructure.(anim).(FullDate).Kinematics.event_ts=event_ts;
JsonOutputStructure.(anim).(FullDate).Kinematics.event_ts_table=event_ts_table;