%Below compares clockwise performance (1st column) with counterclockwise
%performance (2nd column).  Each row corresponds to a different binsize
%applied to the same dataset 

%function 

function [CW_vs_CCW,tilt,tilttype,background]=CW_vs_CCW(PSTHscriptoutput,binsizean)

A=PSTHscriptoutput;
B=length(binsizean);
fields={'a','b','c','d','e','f','g'};

for i=1:B
confusionmatrix.(fields{i})=A{i,3};
end

for j=1:B
diagonals=diag(confusionmatrix.(fields{j}));
a=0;
b=1;
i2=1;
for i=1:2:length(confusionmatrix.a)-1

  CW_vs_CCW(j,i2)=(diagonals(a+i)+diagonals(b+i))/...
    (sum(confusionmatrix.(fields{j})(a+i,:))...
    +sum(confusionmatrix.(fields{j})(b+i,:))); 


i2=i2+1;
end
end

%Compares the performance of the classifier for each tilt type.  Every
%column is a different tilt type and each row corresponds to a different
%bin size
for j=1:B
diagonals=diag(confusionmatrix.(fields{j}));

for i=1:1:length(confusionmatrix.a)

  tilt(j,i)=diagonals(i)/(sum(confusionmatrix.(fields{j})(i,:))); 


i2=i2+1;
end
end

for j=1:B
diagonals=diag(confusionmatrix.(fields{j}));
a=0;
b=2;
i2=1;
for i=1:1:length(confusionmatrix.a)/2

  tilttype(j,i)=(diagonals(a+i)+diagonals(b+i))/...
    (sum(confusionmatrix.(fields{j})(a+i,:))...
    +sum(confusionmatrix.(fields{j})(b+i,:))); 


end
end

for j=1:B
diagonals=diag(confusionmatrix.(fields{j}));



  background(j,i)=diagonals(5)/(sum(confusionmatrix.(fields{j})(5,:))); 




end



end

% function[]=yy()
% sss
% end
% 
% end
