function [Neurons,bin_matr,PEHMClass] = PEHMbinselect(options,Duration,PEHMClass1 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here



Neurons=size(PEHMClass1,2)/Duration;
 %derives a PEHM of any bin size from a PEHM made
                            %using a 1ms binsize
                            bin_matr=create_binmatr(options.bin*1000,Duration,Neurons);
                            
                            
                            %PEHM with user-defined bin size
                            PEHMClass=PEHMClass1*bin_matr;
                            
                            
                            
                            
                            
                            
                            
                            
                            
                             

end

