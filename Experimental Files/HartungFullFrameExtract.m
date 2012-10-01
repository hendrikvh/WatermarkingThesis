clear all;
close all;
clc;

%%
%Recover WM
load ('PN.mat');
%PN = [1 1 PN(1:end-2)];

currentFrame = 1;
WMIndex = 1;
lumaLeftOver = [];
WMBitIndex = 1;
WMExtracted = 0;
bits = 5;

inputVideo = 'Hartung1998Embed.avi';
inputVideo0 = 'HartungVideo0.avi';
inputVideo1 = 'HartungVideo1.avi';

%Get attributes of inputVideo, video0 and video1
videoObj = VideoReader(inputVideo);
video0Obj = VideoReader(inputVideo0);
video1Obj = VideoReader(inputVideo1);

frameRate = videoObj.frameRate;
frameHeight = videoObj.height;
frameWidth = videoObj.width;
frameCount = videoObj.numberOfFrames;

pixelsInFrame = frameHeight * frameWidth;
cr = pixelsInFrame;

extractedWM = 5*ones(1,bits);
framesRequired = bits;

WMLength = bits * cr;
WMLeftOver = WMLength;

%Extract WM
while (currentFrame <= framesRequired)
    %Determine how much WM is left to extract
    %WMLeftOver = WMLength - (WMBitIndex-1)*cr;
    WMLeftOver = WMLength - WMExtracted;
    
    
    %How much WM is left in THIS FRAME
    WMLeftOver (WMLeftOver > pixelsInFrame) = pixelsInFrame;
    WMExtracted = WMExtracted + WMLeftOver;
       
    RGBFrame = read(VideoReader(inputVideo), currentFrame);
    
    frame0 = im2double(read(VideoReader(inputVideo0), 1));
   
    %Colour space conversion
    frame0 = rgb2ycbcr(frame0);
    YCFrame0 = frame0(:,:,1);
    WMFrame = rgb2ycbcr(RGBFrame);
    WMFrame = WMFrame(:,:,1);
    imshow (WMFrame);
    figure;
    
    %Attack!
    %WMFrame = imrotate(WMFrame, 15,'bilinear','crop');
    %WMFrame = imresize (WMFrame, [500 500], 'nearest');
    %imshow (WMFrame);
    
    %tic
    %WMFrame = correctImage(YCFrame0, WMFrame);
    %toc
    %figure
    %imshow (WMFrame);
    
    fprintf ('Extracting frame %d with ',currentFrame);
    %imshow(RGBFrame);

    %Filter
    h= fspecial('average',3);
    filteredFrame = imfilter (WMFrame, h, 'replicate');
    HPFrame = WMFrame - filteredFrame;
    %imshow (HPFrame);

    %Line scan WM'd frame
    currentLine = 1;
    beginIndex = 1;

    lineLength = frameWidth;
    
    while (currentLine <= size(HPFrame,1))
        lumaLine (beginIndex: beginIndex + lineLength - 1)  = HPFrame (currentLine, :, 1);
        currentLine = currentLine + 1;
        beginIndex = beginIndex + lineLength;
    end
    
    %Multiply concatlumaline with PN sequence
    lumaDemod = 0;
%    lumaDemod(1:WMLeftOver) = double(lumaLine(1:WMLeftOver)).*PN((WMBitIndex-1)*cr + 1:(WMBitIndex-1)*cr + WMLeftOver);
    lumaDemod(1:WMLeftOver) = double(lumaLine(1:WMLeftOver)).*PN((currentFrame-1)*pixelsInFrame + 1:(currentFrame-1)*pixelsInFrame + WMLeftOver);

    
    %Concat lumaLeftOver
    lumaDemod = [ lumaLeftOver,lumaDemod ];
    
    WMBitsInFrame = floor (length(lumaDemod)/cr);
    WMBitIndexForFrame = 1;
    
    %Recover bits
    while (WMBitIndexForFrame <= WMBitsInFrame)
        extractedWM(WMBitIndex) = sum(lumaDemod((WMBitIndexForFrame-1)*cr + 1:( (WMBitIndexForFrame) * cr ) ));
        confidence = abs(extractedWM(WMBitIndex));
        WMBitIndex = WMBitIndex + 1;
        WMBitIndexForFrame = WMBitIndexForFrame + 1;
    end
    
    lumaLeftOver = lumaDemod ((WMBitIndexForFrame - 1) * cr + 1:length(lumaDemod));
    fprintf ('confidence = %d.\n', confidence);
    
    currentFrame = currentFrame + 1;
   
end

extractedWM( extractedWM>=0 )=1;
extractedWM( extractedWM<0 )=0;

% problemSpot = find (error > 0);
% if sum(error) > 1
%     problemSpot
% end

extractedWM