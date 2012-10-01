% -------------------------------------------------
% GetSSIM
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

function [SSIM SSIMMap minSSIM] = GetSSIM(YBlock,WMYBlock)

K = [0.01 0.03];
window = fspecial('gaussian', 11, 1.5);
L = 1;

i = 1;

while (i <= size(YBlock,3))
    [SSIM(i) SSIMMap(:,:,i)] = ssim(YBlock(:,:,i), WMYBlock(:,:,i),K, window, L);
    minSSIM(:,:,i) = min(min(SSIMMap(:,:,i)));
    i = i + 1;
end

%SSIM = min(SSIM);
SSIM = mean(SSIM);

minSSIM = min(min(min(SSIMMap)));