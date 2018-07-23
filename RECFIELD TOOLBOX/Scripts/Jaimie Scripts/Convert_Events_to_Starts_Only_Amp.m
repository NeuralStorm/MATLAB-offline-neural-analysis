totalevents=26;

%
% TiltType=load('D:\Matlab\Reorganization_Posture\Tilt_Types_Files\CSR030.AmpDur.Week0.10222013.TiltTypes.csv');
% TiltType=load('D:\Matlab\Reorganization_Posture\Tilt_Types_Files\CSR029.AmpDur.Week2.10242013.TiltTypes.csv');
% TiltType=load('D:\Matlab\Reorganization_Posture\Tilt_Types_Files\CSR028.AmpDur.Week5.11052013.TiltTypes.csv');
% TiltType=load('D:\Matlab\Reorganization_Posture\Tilt_Types_Files\CSR022.AmpDur.Week9.10082013.TiltTypes.csv');
TiltType=load('C:\Users\Nate\Documents\Jaimie Tilt\Tilt Type Files\CSR.028.Tx.AmpDur.Week13_01.02.2014_13.07_36_TiltTypes.csv');

%%check event locations - sometimes this is importing all screwy
Events(1,totalevents-1)=Events(1,2);%6   %move start and stop to the end - needed for the analysis to run properly.
Events(1,totalevents)=Events(1,3);%7


for i=1:totalevents-2
    Events(1,i).channel=i;
end



%convert start TS
A=Events(1,1).ts;
B=diff(A);
C=find(B>2);
d(1)=A(1);
D=A(C+1);
E=[d;D];
RS=[A(C-1)];

l=[length(E) length(RS)];
lmin=min(l);
E=E(1:lmin,1);
RS=RS(1:lmin,1);
TiltType=TiltType(1:lmin,1);

Events(1,1).ts=E;




events=Events(1,1).ts;

j=1;
for i=1:8
    Ind=find(TiltType==i);
    StTiltTs{j,i}=events(Ind,1);
    RtStTs{j,i}=RS(Ind,1);
    
end

%Put the timestamps into their own events (1-8 are all start tilt, 9-16 are background, 17-24are start of return tilt
for i=1:8
    Events(1,i).ts=StTiltTs{1,i};
    Events(1,i+8).ts=StTiltTs{1,i}-1;
    
    Events(1,i+16).ts=RtStTs{1,i};
   
end


Events(1,1).name='StAmpDur10d285msL';
Events(1,2).name='StAmpDur10d568msL';
Events(1,3).name='StAmpDur20d285msL';
Events(1,4).name='StAmpDur20d568msL';
Events(1,5).name='StAmpDur10d285msR';
Events(1,6).name='StAmpDur10d568msR';
Events(1,7).name='StAmpDur20d285msR';
Events(1,8).name='StAmpDur20d568msR';


Events(1,9).name='BkgAmpDur10d285msL';
Events(1,10).name='BkgAmpDur10d568msL';
Events(1,11).name='BkgAmpDur20d285msL';
Events(1,12).name='BkgAmpDur20d568msL';
Events(1,13).name='BkgAmpDur10d285msR';
Events(1,14).name='BkgAmpDur10d568msR';
Events(1,15).name='BkgAmpDur20d285msR';
Events(1,16).name='BkgAmpDur20d568msR';

Events(1,17).name='RtStAmpDur10d285msL';
Events(1,18).name='RtStAmpDur10d568msL';
Events(1,19).name='RtStAmpDur20d285msL';
Events(1,20).name='RtStAmpDur20d568msL';
Events(1,21).name='RtStAmpDur10d285msR';
Events(1,22).name='RtStAmpDur10d568msR';
Events(1,23).name='RtStAmpDur20d285msR';
Events(1,24).name='RtStAmpDur20d568msR';


