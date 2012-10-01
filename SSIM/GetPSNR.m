% -------------------------------------------------
% GetPSNR
% -------------------------------------------------
% 
% Forms part of spatial quality metric.
% Discussed in Chapter 4 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [PSNR] = GetPSNR(YBlock, WMYBlock)

i = 1;
%psnrAvg = 0;

while (i <= size(YBlock,3))
     hpsnr = vision.PSNR;
     PSNR(i) = step(hpsnr, YBlock(:,:,i), WMYBlock(:,:,i));
     %psnrAvg = psnrAvg + psnr;
     %fprintf ('PSNR of frame %d is %2fdB.\n', i, psnr);
     i = i + 1;
end

%psnrAvg = psnrAvg / size(YBlock, 3);
