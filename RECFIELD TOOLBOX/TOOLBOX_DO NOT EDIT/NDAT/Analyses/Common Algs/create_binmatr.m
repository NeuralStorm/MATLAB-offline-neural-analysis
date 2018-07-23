function outputmatr=create_binmatr(bin,duration,Neurons)

outputmatr=sparse(zeros(Neurons*duration,ceil(duration/bin)));
curr_row=zeros(duration,1);
curr_row(1:bin)=1;
for i=1:ceil(duration/bin)
    outputmatr(1:duration,i)=curr_row;
    curr_row=circshift(curr_row,bin);
    if i==floor(duration/bin)
        curr_row(1:bin-1)=0;
    end
        
end

outputmatrcurr=outputmatr;
outputmatrcurr=circshift(outputmatrcurr,duration);
for i=1:Neurons-1
    outputmatr=cat(2,outputmatr,outputmatrcurr);
    outputmatrcurr=circshift(outputmatrcurr,duration);
end
