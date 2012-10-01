% -------------------------------------------------
% Kong2006Embed
% -------------------------------------------------
% 
% Embedding stage of SVD watermarking technique. 
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

function [WMYBlock] = Kong2006Embed(YBlock, WMInput, smallestS, intensity)

%% Determine parameters
bitsPerFrame = length(WMInput) / size(YBlock,3);
biggestS = smallestS + bitsPerFrame*2 - 1;

if (biggestS > (size(YBlock,1) - 1)) % If more bits than coeffs
    biggestS = size(YBlock,1) - 1;
    fprintf ('Too many bits for SVD.\n');
end

fprintf ('Embedding %3.2f bits per frame at coeff %3.2f to %3.2f with intensity %3.2f.\n', bitsPerFrame,smallestS,biggestS,intensity);

% Embedding positions and intensity
alpha = intensity;   %WM intensity

%% Setup & prealloc
WMYBlock = zeros (size(YBlock)) * 50;
currentFrameInBlock = 1;
WMInput = WMInput * 2 - 1;
WMBitIndex = 1;

%% Embed
while (currentFrameInBlock <= size(YBlock, 3))
    
    %SVD
    [U, S, V] = svd (YBlock(:,:,currentFrameInBlock));

    i = smallestS;
    while (i <= biggestS)
        S(i,i) = 0.5*(     (S(i-1,i-1) + S(i+1, i+1)) + alpha*WMInput(WMBitIndex)*(S(i-1,i-1) - S(i+1, i+1))     );
        i = i + 2;
        WMBitIndex = WMBitIndex + 1;
    end

    WMYBlock (:,:,currentFrameInBlock) = U*S*V';
    
    currentFrameInBlock = currentFrameInBlock + 1;
    
end

%% Clip values
WMYBlock(WMYBlock < 0) = 0;
WMYBlock(WMYBlock > 1) = 1;

%WMYBlock = im2double(im2uint8(WMYBlock));