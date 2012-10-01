% -------------------------------------------------
% GetBER
% -------------------------------------------------
% 
% Calculated BER for use by TestBed.m
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


function [errorBitCount, BER] = GetBER(WMInput, extractedWM)
errorBitCount = sum(abs(extractedWM - WMInput));
%errorBits = (abs(extractedWM - WMInput));
BER = errorBitCount / length(WMInput);
BER(BER>0.5) = 1 - BER;