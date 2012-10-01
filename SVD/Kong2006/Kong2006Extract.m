% -------------------------------------------------
% Kong2006Extract
% -------------------------------------------------
% 
% Extraction stage of SVD watermarking technique. 
% See
% Kong, W., Yang, B., Wu, D. and Niu, X.: SVD Based Blind Video Watermark- ing Algorithm.
% In: First International Conference on Innovative Computing, Information and Control - Volume I (ICICIC?06),
% vol. 1, pp. 265?268. IEEE, 2006
% ISBN 0-7695-2616-0.
% Available at: http://ieeexplore.ieee.org/lpdocs/epic03/wrapper.htm? arnumber=1691791
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [extractedWM] = Kong2006Extract(WMYBlock, WMLength, smallestS)

bitsPerFrame = WMLength / size(WMYBlock,3);
biggestS = smallestS + bitsPerFrame*2 - 1;

if (biggestS > (size(WMYBlock,1) - 1)) % If more bits than coeffs
    biggestS = size(WMYBlock,1) - 1;
end

currentFrame = 1;
WMBitPos = 1;
extractedWM = zeros (1,WMLength);

%Extract WM
while (currentFrame <= size(WMYBlock,3))
    [~, S, ~] = svd (WMYBlock(:,:,currentFrame));
    
    i = smallestS;
    while (i <= biggestS)
        if (S(i,i) > (0.5 * ( S(i-1, i-1) + S(i+1, i+1)) ))
            extractedWM (WMBitPos) = 1;
        elseif (S(i,i) < 0.5 * ( S(i-1, i-1) + S(i+1, i+1) ))
        extractedWM (WMBitPos) = 0;
        end

    i = i+2;
    WMBitPos = WMBitPos + 1;
    end
    currentFrame = currentFrame + 1;
end