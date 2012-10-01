clc;
clear all;
close all;

%%
%For video input
% inputVideo = 'Interleaved.avi';
% inputVideo0 = 'Video0.avi';
% inputVideo1 = 'Video1.avi';

% %%
%Get attributes of video0
% videoObj = VideoReader(inputVideo);
% video0Obj = VideoReader(inputVideo0);
% video1Obj = VideoReader(inputVideo1);
% 
% %Get Video0 and Video1
% frame0 = im2double(read(VideoReader(inputVideo0), 1));
% frame = im2double(read(VideoReader(inputVideo1), 1));

%%
%Read directly from Matlab variables
%Get WM frames
load ('KongFrame0.mat');
frame0 = im2double(WMRGBFrame);
load ('KongFrame1.mat');
frame1 = im2double(WMRGBFrame);
%load ('FrameOrig.mat');
%frameOrig = im2double(RGBFrame);

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
%Try SVD extraction
fprintf ('--------------------------\nSVD Extract:\n');
WMBitPos = 1;
% Embedding positions and intensity
smallestS = 3;
biggestS = 9;

[U, S, V] = svd (im2double(frameReceived));

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

extracted = extractedWM * 2 - 1
confidence = sum(abs(extracted))*25;
if (extracted > 0)
    extractedBit = 1;
else
    extractedBit = 0;
end

fprintf ('Bit = %d. Confidence = %d.\n', extractedBit, confidence);


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

