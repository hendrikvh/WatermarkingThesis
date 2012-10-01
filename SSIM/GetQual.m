% -------------------------------------------------
% GetQual
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

function [badPixelsBlock meanVal meanThresSSIM minSSIM] = GetQual(YBlock,WMYBlock, threshold)

badPixelsBlock = ones(size(YBlock));

[~, SSIMBlock, ~] = GetSSIM(YBlock,WMYBlock);

for i=1:size(WMYBlock,3)

    % Get pixels below certain value
    badPixelsFrame = (SSIMBlock(:,:,i) < threshold);
    SSIMFrame = SSIMBlock(:,:,i);
    badPixelsBlock(:,:,i) = (imresize(badPixelsFrame, [size(WMYBlock,1) size(WMYBlock,2)])* 0.5 + WMYBlock(:,:,i));

    % Count pixels below certain value
    
    meanVal(i) = mean(SSIMFrame(SSIMFrame < threshold));

    %invalidNumbers = isnan(meanVal);
    %meanVal(invalidNumbers) = 1;   
    
end

meanThresSSIM = mean(meanVal);
minSSIM = min(min(min(SSIMBlock)));