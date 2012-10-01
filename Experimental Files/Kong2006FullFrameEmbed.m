%-----------------------------------------------------------------
% Kong2006Embed.m
%-----------------------------------------------------------------
% Embed watermark into video file.
%
% Set inputVideo to desired inputvideo
% Generates Kong2006WM.mj2
% Not yielding desireable results yet
%-----------------------------------------------------------------
% Hendrik van Huyssteen
% Stellenbosch University
% Hendrikvh@ml.sun.ac.za
% May 2011
%-----------------------------------------------------------------

%Start clean
clear all;
close all;
clc;

%Inputs
inputVideo = '~/Dropbox/Medialab/Matlab/Videos/TestSony.mov';       %video used for watermarking
%WMInput = [0 0 0 0]; %bits to embed
WMInput = int8(rand(1,240));
tic
input = WMInput;                %store wm for later evaluation
WMInput = (WMInput * 2) - 1;    %Convert watermark to 1 & -1

% Embedding positions and intensity
smallestS = 3;
biggestS = 9;
alpha = 0.48;   %WM intensity

%Indexing
offset = 0; %to start watermarking at offset frames instead of frame 1
currentFrame = offset + 1;
WMBitIndex = 1;

%Determine number of frames required, open video object etc.
WMInputSize = size(WMInput);
framesRequired = floor( WMInputSize (2)/( (biggestS - smallestS - 2)) )
% vidObj = VideoWriter('Kong2006WM.mj2', 'Archival');
% open(vidObj);

vidObj = VideoWriter('Kong2006Embed.avi', 'Uncompressed AVI');
vidObj.FrameRate = 25;
open(vidObj);

%figure ('Position', [100, 100, 1800, 600]);

%Watermark each frame
while (currentFrame - offset <= framesRequired)
    
    %Read single frame & display original frame
    RGBFrame = read(VideoReader(inputVideo),currentFrame);
    RGBFrame = im2double(RGBFrame);
    %RGBOrig = RGBFrame; %Only needed if PSNR is to be evaluated directly here
    subplot (1,2,1);
    %imshow (RGBFrame);

    %Colour space conversion
    YCFrame = rgb2ycbcr(RGBFrame);
    YCOrig = (YCFrame (:,:,1)); %only interested in luma #############################################################

    %SVD
    [U, S, V] = svd (YCFrame(:,:,1));
    SSize = size (S);

    %############################
    % Embed WM bits
    %############################
    i = smallestS;

    while (i <= biggestS)
        S(i,i) = 0.5*(     (S(i-1,i-1) + S(i+1, i+1)) + alpha*WMInput(WMBitIndex)*(S(i-1,i-1) - S(i+1, i+1))     );
        i = i + 2;
        WMBitIndex = WMBitIndex + 1;

    end

    %-----------------------------------
    %Back to RGB
    %-----------------------------------
    YCFrame (:,:,1) = U*S*V';

    WMRGBFrame = ycbcr2rgb(YCFrame);
    WMRGBFrame = im2uint8(WMRGBFrame);
    subplot (1,2,2);
    %imshow (WMRGBFrame); 
    
    %Write frame to video file
    writeVideo(vidObj,WMRGBFrame);

    currentFrame = currentFrame + 1 
    
    %PSNR (im2double(WMRGBFrame), im2double(RGBOrig)); %Send to PSNR to
    %evalaute PSNR of luma frame - handled by PSNR function
end

%save WMRGBFrame
save ('Frame0.mat', 'WMRGBFrame');

% Close the file.
close(vidObj);
toc
