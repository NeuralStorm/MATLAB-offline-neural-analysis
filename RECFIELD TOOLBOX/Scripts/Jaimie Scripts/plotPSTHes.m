function plotPSTHes(PeriEventMatrixAll)
%TIMElength=TimeLength;
TIMElength=10;%280  %makethis the number of bins
% close all;
temp1=PeriEventMatrixAll(1:100,:);  %trial 1 values
temp2=PeriEventMatrixAll(101:200,:);
temp3=PeriEventMatrixAll(201:300,:);

meanPeri1=mean(temp1,1);    %mean trial 1 values for all neurons
meanPeri2=mean(temp2,1);
meanPeri3=mean(temp3,1);
% 
temp4=PeriEventMatrixAll(301:400,:);
meanPeri4=mean(temp4,1);

% temp5=PeriEventMatrixAll(401:500,:);
% meanPeri5=mean(temp5,1);
% temp6=PeriEventMatrixAll(501:600,:);
% meanPeri6=mean(temp6,1);
% temp7=PeriEventMatrixAll(601:700,:);
% meanPeri7=mean(temp7,1);
% temp8=PeriEventMatrixAll(701:800,:);
% meanPeri8=mean(temp8,1);



neurons1(1,1:TIMElength)=meanPeri1(1,1:TIMElength);
neurons2(1,1:TIMElength)=meanPeri2(1,1:TIMElength);
neurons3(1,1:TIMElength)=meanPeri3(1,1:TIMElength);
neurons4(1,1:TIMElength)=meanPeri4(1,1:TIMElength);


% neurons5(1,1:TIMElength)=meanPeri5(1,1:TIMElength);
% neurons6(1,1:TIMElength)=meanPeri6(1,1:TIMElength);
% neurons7(1,1:TIMElength)=meanPeri7(1,1:TIMElength);
% neurons8(1,1:TIMElength)=meanPeri8(1,1:TIMElength);


st(1)=1;
ed(1)=TIMElength;

    
for i=2:(length(meanPeri1)/TIMElength);  %i is the neuron
    stpt=TIMElength*(i-1)+1;    %first bin of PSTH
    endpt=stpt+TIMElength-1;%-1
    neurons1(i,:)=meanPeri1(1,stpt:endpt);
    neurons2(i,:)=meanPeri2(1,stpt:endpt);
    neurons3(i,:)=meanPeri3(1,stpt:endpt);
    neurons4(i,:)=meanPeri4(1,stpt:endpt);
    
    
    
%     neurons5(i,:)=meanPeri5(1,stpt:endpt);
%     neurons6(i,:)=meanPeri6(1,stpt:endpt);
%     neurons7(i,:)=meanPeri7(1,stpt:endpt);
%     neurons8(i,:)=meanPeri8(1,stpt:endpt);
    
    st(i)=stpt;
    ed(i)=endpt;
    
%     
%      tempy1(i,:)=meanPeri1(stpt:endpt);
%     tempy2(i,:)=meanPeri2(stpt:endpt);
%     tempy3(i,:)=meanPeri3(stpt:endpt);
%     
%     tempy4(i,:)=meanPeri4(stpt:endpt);
    nn=10;%8
    Sneurons1(i,:)=smooth(neurons1(i,:),nn);
    Sneurons2(i,:)=smooth(neurons2(i,:),nn);
    Sneurons3(i,:)=smooth(neurons3(i,:),nn);
    Sneurons4(i,:)=smooth(neurons4(i,:),nn);
    
%     Sneurons5(i,:)=slideAverage(neurons5(i,:),nn);
%     Sneurons6(i,:)=slideAverage(neurons6(i,:),nn);
%     Sneurons7(i,:)=slideAverage(neurons7(i,:),nn);
%     Sneurons8(i,:)=slideAverage(neurons8(i,:),nn);
    

end



%     [a b]=size(neurons1)
%     for m=2:50;%4:6%1%:40;%3%25;%a;25  8. 22?  (possibilities: file 12, cell22 - 15a)
% % % m=15
% figure(m);
%         subplot(421)
%         bar(Sneurons1(m,:));
% %             axis([0 280 0 .1]);
%         subplot(423)
%         bar(Sneurons2(m,:));
%         subplot(425)
%         bar(Sneurons3(m,:));
%         subplot(427)
%         bar(Sneurons4(m,:));
%         
%         subplot(422);
%         bar(Sneurons5(m,:));
% %             axis([0 280 0 .1]);
%         subplot(424)
%         bar(Sneurons6(m,:));
%         subplot(426)
%         bar(Sneurons7(m,:));
%         subplot(428)
%         bar(Sneurons8(m,:));
% %         
% %         
% %         
%     end
% %     
% % % %             axis([0 280 0 .1]);
% % %         subplot(413)
% %         bar(neurons3(m,:));
% % %             axis([0 280 0 .1]);
% %         subplot(414)
% %         bar(neurons4(m,:));
% % % %             axis([0 280 0 .1]);
%         
% %             figure(17)
%         subplot(411)
%         imagesc(neurons1);%(m,:));
% %             axis([0 280 0 .1]);
%         subplot(412)
%         imagesc(neurons2);%(m,:));
% %             axis([0 280 0 .%1]);
% %         subplot(413)
% %         imagesc(neurons3);%(m,:));
% % %             axis([0 280 0 .1]);
% %         subplot(414)
% %         imagesc(neurons4);%(m,:));
% % % %             axis([0 280 0 .1]);    
%             
%     end
%     














p=2;
end












%%% %                 options.NeuronSelection=[9 10 14 15 16 17 19 20 21 22 23 24 31];%file12

% r=24;%2, 4, 10, 56
% figure;%(100)%(20)
% subplot(411);
% bar(neurons1(r,1:780));
% title('Intact');
% 
% 
% subplot(412);
% bar(neurons2(r,1:780));
% 
% subplot(413);
% bar(neurons3(r,1:780));
% 
% subplot(414);
% bar(neurons4(r,1:780));
% 

% 
