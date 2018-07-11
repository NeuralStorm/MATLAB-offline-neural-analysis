function DO = reward_punishRate(obj,punishCount,rewardCount,waterCount,...
                    Max_PunishRate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Update DO file
obj.PunishCount=[obj.PunishCount;punishCount];

obj.RewardCount=[obj.RewardCount;rewardCount];

obj.WaterCount=[obj.WaterCount;waterCount];

obj.Max_PunishRate=Max_PunishRate;

DO=obj;



end

