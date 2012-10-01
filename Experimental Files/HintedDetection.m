clear all
clc

%%Hinted extraction of watermark
inputVideo = 'Interleaved.avi';
inputVideo0 = 'Video0.avi';
inputVideo1 = 'Video1.avi';

% %%
%Get attributes of video0
videoObj = VideoReader(inputVideo);
video0Obj = VideoReader(inputVideo0);
video1Obj = VideoReader(inputVideo1);

%Get Video0 and Video1
frame0 = im2double(read(VideoReader(inputVideo0), 1));
frame1 = im2double(read(VideoReader(inputVideo1), 1));
frameWM = im2double(read(VideoReader(inputVideo), 1));

% %Get WM frames
% load ('Frame0.mat');
% frame0 = im2double(WMRGBFrame);
% load ('Frame1.mat');
% frame1 = im2double(WMRGBFrame);
% load ('FrameOrig.mat');
% frameOrig = im2double(RGBFrame);

%To YCbCr
frame0 = rgb2ycbcr(frame0);
frame1 = rgb2ycbcr(frame1);
frameReceived = rgb2ycbcr(frameWM);

frame0 = frame0(:,:,1);
frame1 = frame1(:,:,1);
frameReceived = frameReceived(:,:,1);

%%
% Image registration & correction
frameReceived = correctImage(frame0, frameReceived);

%Correlation
corrReceived1 = sum(sum(frameReceived.*frame1));
corrReceived0 = sum(sum(frameReceived.*frame0));
corr10 = sum(sum(frame1.*frame0));

dist0 = sqrt(sum(sum((frame0 - frameReceived).^2)));
dist1 = sqrt(sum(sum((frame1 - frameReceived).^2)));

%Diff
chanceOf1 = abs(corrReceived1 - corr10);
chanceOf0 = abs(corrReceived0 - corr10);

if (chanceOf1 > chanceOf0)
    WM = 1
else
    WM = 0
end

