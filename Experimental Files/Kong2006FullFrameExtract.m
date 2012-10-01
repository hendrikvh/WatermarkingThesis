
%-----------------------------------------------------------------
% Kong2006Extract.m
%-----------------------------------------------------------------
% Extract watermark embedded in video by Kong2006Embed.m
%
% Not to be used standalone yet - uses variables from
% embedding process. Run Kong2006Embed first.
%-----------------------------------------------------------------
% Hendrik van Huyssteen
% Stellenbosch University
% Hendrikvh@ml.sun.ac.za
% May 2011
%-----------------------------------------------------------------

clc;
clear all;

WMInput = [1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0];

% Embedding positions and intensity
smallestS = 3;
biggestS = 9;

%Determine number of frames required, open video object etc.
WMInputSize = size(WMInput);
framesRequired = floor( WMInputSize (2)/( (biggestS - smallestS - 2)) )

currentFrame = 1;
WMBitPos = 1;
inputSize = size(WMInput);
extractedWM = zeros (1,inputSize(2) );

%Extract WM
while (currentFrame <= framesRequired)
    fprintf ('Current Frame %d.', currentFrame);
    RGBFrame = read(VideoReader('Kong2006Embed.avi'), currentFrame);
    RGBFrame = im2double (RGBFrame);
    
    %Colour space conversion
    YCFrame = rgb2ycbcr(RGBFrame);

    [U, S, V] = svd (im2double(YCFrame(:,:,1)));
    
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

% Check if watermark extracted correctly
error1 = WMInput - extractedWM;
error2 = extractedWM - WMInput
bitError = sum(abs(error2))

