
for m=6:15;%16   %cell nubm   
    
    %does not work for cell #1 for some reason
    
    %number of rows should she be length in workspace
      % m=5%49
%file 6, cell 20 ok but not compelling for single activator
%file 6, cell 53, 54 for scaled cells
%file 9 cell 20,21 for scaled cells (21 prob better), 39 - nonconsec

bk1=1; %window of time for bacground
bk2=400;%138  %%usu 400 for 500ms before and 500ms after
meanFR1=mean(Sneurons1(m,bk1:bk2));%for 280ms with a 2ms bin, 138
meanFR2=mean(Sneurons2(m,bk1:bk2));
meanFR3=mean(Sneurons3(m,bk1:bk2));
meanFR4=mean(Sneurons4(m,bk1:bk2));

% meanFR5=mean(Sneurons5(m,bk1:bk2));%for 280ms with a 2ms bin, 138
% meanFR6=mean(Sneurons6(m,bk1:bk2));
% meanFR7=mean(Sneurons7(m,bk1:bk2));
% meanFR8=mean(Sneurons8(m,bk1:bk2));



stdevFR1=std(Sneurons1(m,bk1:bk2));
stdevFR2=std(Sneurons2(m,bk1:bk2));
stdevFR3=std(Sneurons3(m,bk1:bk2));
stdevFR4=std(Sneurons4(m,bk1:bk2));


% stdevFR5=std(Sneurons5(m,bk1:bk2));
% stdevFR6=std(Sneurons6(m,bk1:bk2));
% stdevFR7=std(Sneurons7(m,bk1:bk2));
% stdevFR8=std(Sneurons8(m,bk1:bk2));


% meanFR=[meanFR1 meanFR2 meanFR3 meanFR4];
meanFR=[meanFR1 meanFR2 meanFR3 meanFR4] 
   % meanFR5 meanFR6 meanFR7 meanFR8];
REALmeanFR=mean(meanFR);
 stdevFR=[stdevFR1 stdevFR2 stdevFR3 stdevFR4];
%stdevFR=[stdevFR1 stdevFR2 stdevFR3 stdevFR4 stdevFR5 stdevFR6 stdevFR7 stdevFR8];
REALstdevFR=mean(stdevFR);
THRESHOLDh=REALmeanFR+3*REALstdevFR;
THRESHOLDl=REALmeanFR-3*REALstdevFR;


L=1000;   %set from before
Y=[THRESHOLDh];
Y(1:L)=Y;
X=[1:1:L];

L2=1000;
Y3=[THRESHOLDl];
Y3(1:L2)=Y3;
X3=[1:1:L2];

y2=REALmeanFR;
Y2(1:L)=y2;
X=[1:1:L];


% 
% % m=15
figure(m);
        subplot(411)
        bar(Sneurons1(m,:));
        hold on;
%             axis([70 280 0 .1]);
                  line(X,Y);        line(X,Y2); line(X,Y3);
%                   axis([500 2000 0 0.1])
            
        subplot(412);hold off;
        bar(Sneurons2(m,:));
%         axis([70 280 0 .1]);
        line(X,Y);        line(X,Y2); line(X,Y3);
%          axis([500 2000 0 0.1])

        subplot(413)
        bar(Sneurons3(m,:));hold off;
        hold on;
%         axis([70 280 0 .1]);
        line(X,Y);                line(X,Y2);    line(X,Y3);
%          axis([500 2000 0 0.1])
        
        subplot(414);hold off;
        bar(Sneurons4(m,:));
        hold on;
%         axis([70 280 0 .1]);
        line(X,Y);                line(X,Y2); line(X,Y3);
%          axis([500 2000 0 0.1])
%         
%         
%         
%         subplot(422)
%         bar(Sneurons5(m,:));
%         hold on;
% %             axis([70 280 0 .1]);
%                   line(X,Y);        line(X,Y2); line(X,Y3);
%                   
%         subplot(424)
%         bar(Sneurons6(m,:));
%         hold on;
% %             axis([70 280 0 .1]);
%                   line(X,Y);        line(X,Y2); line(X,Y3);
% %                    axis([500 2000 0 0.1])
%                   
%                           subplot(426)
%         bar(Sneurons7(m,:));
%         hold on;
% %             axis([70 280 0 .1]);
%                   line(X,Y);        line(X,Y2); line(X,Y3);
% %                    axis([500 2000 0 0.1])
%                    
%                           subplot(428)
%         bar(Sneurons8(m,:));
%         hold on;
% %             axis([70 280 0 .1]);
%                   line(X,Y);        line(X,Y2); line(X,Y3);
% %                    axis([500 2000 0 0.1])

                  
                  
                  
                  
%  figure(2);
%         subplot(421)
%         bar(Sneurons1(m,:));
%         hold on;
% %             axis([70 280 0 .1]);
%                   line(X,Y);        line(X,Y2); line(X,Y3);
%             
%         subplot(423);hold off;
%         bar(Sneurons2(m,:));hold on;
% %         axis([70 280 0 .1]);
%         line(X,Y);        line(X,Y2); line(X,Y3);
% 
%         subplot(425)
%         bar(Sneurons3(m,:));hold off;
%         hold on;
% %         axis([70 280 0 .1]);
%         line(X,Y);                line(X,Y2);    line(X,Y3);
% %         
%         subplot(427);hold off;
%         bar(Sneurons4(m,:));
%         hold on;
% %         axis([70 280 0 .1]);
%         line(X,Y);                line(X,Y2); line(X,Y3);
        
        
% %         
                         
end





      