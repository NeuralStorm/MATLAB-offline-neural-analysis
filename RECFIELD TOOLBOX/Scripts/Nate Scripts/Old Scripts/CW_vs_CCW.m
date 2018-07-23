function [CW_vs_CCW]=CW_vs_CCW(PSTHscriptoutput,binsizean)

A=PSTHscriptoutput;
B=length(binsizean);
fields={'a','b','c','d','e','f','g'};

for i=1:B
confusionmatrix.(fields{i})=A{i,3};
end

for j=1:B
diagonals=diag(confusionmatrix.(fields{j}))
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
end