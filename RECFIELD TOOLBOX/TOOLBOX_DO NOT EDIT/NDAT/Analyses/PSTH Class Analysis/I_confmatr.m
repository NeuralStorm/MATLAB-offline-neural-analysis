function [I]=I_confmatr(confmatr)



%             | Stim1 | Stim2 | ...
%   ----------|-------------------
%   Stim1(LVQ)|       |       |
%   ----------|-------|-------|---
%   Stim2(LVQ)|       |       |
%   ----------|-------|-------|---
%        .
%        .

S=length(confmatr);

numtrial=sum(sum(confmatr));

%%%%%Calcution of Ha and Hb
Ha=0;
Hb=0;
for s=1:S
    pa=sum(confmatr(:,s))/numtrial;
    pb=sum(confmatr(s,:))/numtrial;
    if pa==0
    else
        Ha=Ha-pa*log2(pa);
    end
    if pb==0
    else
        Hb=Hb-pb*log2(pb);
    end
end


%%%%%Calcution of Hab
Hab=0;
for a=1:S
    for b=1:S
        pab=confmatr(a,b)/numtrial;
        if pab==0
        else
            Hab=Hab-pab*log2(pab);
        end
    end
end


%%%%%%%%%%Calculation of I
I=Ha+Hb-Hab;