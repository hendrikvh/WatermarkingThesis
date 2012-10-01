%-----------------------------------------------------------------
% Hartung1998Embed.m
%-----------------------------------------------------------------
% Embed single bit watermark into each frame
%
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
inputVideo = '/Users/Hendrik/Dropbox/Medialab/Matlab/Videos/TestSony.mov';       %video used for watermarking

load ('PN.mat');
tic
WMInput = zeros(1,60);
%WMInput = [ 1 0 1 0 1];
WMInput = WMInput * 2 - 1;

% Get attributes of inputvideo and set chiprate for that
%Get attributes of video0
inObj = VideoReader(inputVideo);

frameRate = inObj.frameRate;
frameHeight = inObj.height;
frameWidth = inObj.width;
frameCount = inObj.numberOfFrames;

cr = frameHeight * frameWidth;
alphai = 1;

%Initialise objects
%Indexing
offset = 30; %to start watermarking at offset frames instead of frame 1
currentFrame = offset + 1;
%vidObj = VideoWriter('Hartung1998Embed.mj2', 'Archival');
vidObj = VideoWriter('Hartung1998Embed.avi', 'Uncompressed AVI');
vidObj.FrameRate = 30;
open(vidObj);

%Initial Calculations
RGBFrame = read(VideoReader(inputVideo),1);
WMLength = cr * size(WMInput,2); %Get length of complete WM
framesRequired = ceil (  WMLength  / (size(RGBFrame,1)*size(RGBFrame,2) ) )

%%
% Generate Watermark
%Chip
[~,inputLength] = size (WMInput); %Get length of WM
j = 0;
i = 0;
b = ones(1,WMLength);
while (j<inputLength) %step deur WM
    i = j*cr;
    while (  (i >= (j*cr)) && (i < (j+1)*cr ) )
        b(i+1) = WMInput(j+1);
        i = i+1;
    end
    j = j+1;
end

% Amplify & Modulate with PN sequence
% seed = rng;
% PN = rand (1, size (b, 2));
% PN = int8(PN);
% PN = PN * 2 - 1;
% PN = double(PN);
% save ('PN.mat', 'PN');
w = alphai * b .* PN;

%%
%%Get frames and start WM'ing
WMIndex = 1;

%Watermark each frame
while (currentFrame - offset <= framesRequired)
    
    %Get video frame & line scan video frame
    fprintf ('Frame number %d\n', currentFrame);
    %Read single frame & display original frame
    RGBFrame = read(VideoReader(inputVideo),currentFrame);
    %save ('FrameOrig.mat', 'RGBFrame');
    %save ('RGBFrame');
    %subplot (1,2,1);
    %imshow (RGBFrame);

    %Colour space conversion
    YCFrame = rgb2ycbcr(RGBFrame);

    %Line scan luma frame
    lineLength = size (YCFrame, 2);
    currentLine = 1;
    beginIndex = 1;

    while (currentLine <= size(YCFrame,1))
        lumaLine (beginIndex: beginIndex + lineLength - 1)  = YCFrame (currentLine, :, 1);
        currentLine = currentLine + 1;
        beginIndex = beginIndex + lineLength;
    end

    %%
    %Add wm
    
    %How much WM needs to be added to this lumaline of frame?
    WMLeftToEmbed = length(w) - WMIndex + 1;
    if (WMLeftToEmbed > (size(RGBFrame,1)*size(RGBFrame,2)) )
        WMLeftToEmbed = (size(RGBFrame,1)*size(RGBFrame,2)); %We can only embed a full frame
    end
     
    %Add that to lumaline
    lumaLine(1: WMLeftToEmbed) = double (lumaLine(1: WMLeftToEmbed)) + w(WMIndex: WMIndex + WMLeftToEmbed-1);
    WMIndex = WMIndex + WMLeftToEmbed;

    %unscan WM
    currentLine = 1;
    beginIndex = 1;
    while (currentLine <= size(YCFrame,1))
        WMFrame(currentLine,:)  = lumaLine(beginIndex:beginIndex + lineLength - 1); %%%%Prealloc later!!
        currentLine = currentLine + 1;
        beginIndex = beginIndex + lineLength;
    end

    %Back to RGB
    YCFrame(:,:,1) = WMFrame; 
    WMRGBFrame = ycbcr2rgb(YCFrame);
    WMRGBFrame = im2uint8(WMRGBFrame);
    %subplot (1,2,2);
    %imshow (WMRGBFrame); 
    
    %Write frame to video file
    writeVideo(vidObj,WMRGBFrame);
    %save ('Frame1.mat', 'WMRGBFrame');

    currentFrame = currentFrame + 1 ;
      
end
toc
% Close the file.
close(vidObj);
