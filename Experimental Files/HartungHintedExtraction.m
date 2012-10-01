clc;
clear all;
close all;

%%
%For video input
inputVideo = 'Interleaved.avi';
inputVideo0 = 'HartungVideo0.avi';
inputVideo1 = 'HartungVideo1.avi';

%Get attributes of video0
videoObj = VideoReader(inputVideo);
video0Obj = VideoReader(inputVideo0);
video1Obj = VideoReader(inputVideo1);

% %Get Video0 and video1
frame0 = im2double(read(VideoReader(inputVideo0), 1));
frame1 = im2double(read(VideoReader(inputVideo1), 1));

%%
% %Read directly from Matlab variables
% %Get WM frames
% load ('KongFrame0.mat');
% frame0 = im2double(WMRGBFrame);
% load ('KongFrame1.mat');
% frame1 = im2double(WMRGBFrame);
% %load ('FrameOrig.mat');
% %frameOrig = im2double(RGBFrame);

%%
%To YCbCr
%Get WM frames
YCFrame0 = rgb2ycbcr(frame0); 
YCFrame1 = rgb2ycbcr(frame1); 

frame0 = YCFrame0(:,:,1);
frame1 = YCFrame1(:,:,1);
frameReceived = frame0;

%Attack
%frameReceived = imnoise(frameReceived, 'gaussian',0,0.01/2);
frameReceived = imrotate(frameReceived, 15,'bilinear','loose');
%frameReceived = imresize(frameReceived, [144 176]);
%imshow (frameReceived)
%imshow (frameReceived);

%%Normalise the images
%frameReceived = imadjust (frameReceived, [min(min(frameReceived)) max(max(frameReceived))],[min(min(frame0)) max(max(frame0))], 1);
%frameReceived = imresize(frameReceived, [size(frame0,1) size(frame0,2)]);

% Image registration & correction
frameReceived = correctImage(frame0, frameReceived);
%%
%Correlation
corrReceived1 = sum(sum(frameReceived.*frame1));
corrReceived0 = sum(sum(frameReceived.*frame0));
corr10 = sum(sum(frame1.*frame0));

%Diff
chanceOf1 = corrReceived1 - corr10;
chanceOf0 = corrReceived0 - corr10;
if (chanceOf1 > chanceOf0)
    timesDiff = abs(chanceOf1 / chanceOf0);
    itIs = 1;
else
    timesDiff = abs(chanceOf0 / chanceOf1);
    itIs = 0;
end

fprintf ('--------------------------\nCorrelation:\n');
fprintf ('It is %d!\nChance of 1 = %d\nChance of 0 = %d.\n', itIs, chanceOf1, chanceOf0);
fprintf ('%d times difference.\n', timesDiff);

%%
%Normal histogram method
pixelcount = size(frame0,1)*size(frame0,2);
hist0 = imhist(frame0,64)/pixelcount;
hist1 = imhist(frame1,64)/pixelcount;
histReceived = imhist(frameReceived,64)/pixelcount;

dist0 = sqrt(sum(sum((frame0 - frameReceived).^2)));
dist1 = sqrt(sum(sum((frame1 - frameReceived).^2)));

if (dist1 > dist0)
    itIs = 0;
    timesDiff = dist1/dist0;
else
    itIs = 1;
    timesDiff = dist0/dist1;

end

fprintf ('--------------------------\nHistogram Compare:\n');
fprintf ('It is %d!\nChance of 1 = %d\nChance of 0 = %d.\n', itIs, 1/dist1, 1/dist0);
fprintf ('%d times difference.\n', timesDiff);

%%
%Try SS extraction
fprintf ('--------------------------\nSS Extraction:\n');
%%
%Recover WM
load ('PN.mat');

currentFrame = 1;
WMIndex = 1;
lumaLeftOver = [];
WMBitIndex = 1;
WMExtracted = 0;
bits = 30;

%Get attributes of video0
videoObj = VideoReader(inputVideo);

frameRate = videoObj.frameRate;
frameHeight = videoObj.height;
frameWidth = videoObj.width;
frameCount = videoObj.numberOfFrames;

pixelsInFrame = frameHeight * frameWidth;

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
    fprintf ('Extracting frame %d with ',currentFrame);
    %imshow(RGBFrame);
    %Colour space conversion
    WMFrame = rgb2ycbcr(RGBFrame);

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

%%
%Laws' Method attempt
% features1 = laws (frame1);
% features0 = laws (frame0);
% featuresReceived = laws (frameReceived);
% 
% dist0 = sqrt(sum(sum((features0 - featuresReceived).^2)));
% dist1 = sqrt(sum(sum((features1 - featuresReceived).^2)));
% 
% if (dist1 > dist0)
%     itIs = 0;
%     timesDiff = dist1/dist0;
% else
%     itIs = 1;
%     timesDiff = dist0/dist1;
% 
% end
% 
% fprintf ('--------------------------\nLaws method:\n');
% fprintf ('It is %d!\nChance of 1 = %d\nChance of 0 = %d.\n', itIs, 1/dist1, 1/dist0);
% fprintf ('%d times difference.\n', timesDiff);

