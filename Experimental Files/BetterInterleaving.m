clc

video0 = 'HartungVideo0.avi';
video1 = 'HartungVideo1.avi';

%WMInput = [1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 ];
WMInput = int8(rand(1,60));

%%
%Get input video properties. Assume video1 & video is the same

%Get attributes of video0
video0Obj = VideoReader(video0);

frameRate = video0Obj.frameRate
frameHeight = video0Obj.height;
frameWidth = video0Obj.width %height * width
frameCount = video0Obj.numberOfFrames

%Create video1 object
video1Obj = VideoReader(video1);

%Preallocate structs for videos
% Preallocate movie structure.
% Preallocate movie structure.
video0Data(1:frameCount) = ...
    struct('cdata', zeros(frameHeight, frameWidth, 3, 'uint8'),...
           'colormap', []);
   video1Data(1:frameCount) = ...
struct('cdata', zeros(frameHeight, frameWidth, 3, 'uint8'),...
       'colormap', []);

% Read one frame at a time.
for k = 1 : frameCount
    video0Data(k).cdata = read(video0Obj, k);
    video1Data(k).cdata = read(video1Obj, k);
    %k
end


outObj = VideoWriter('Interleaved.avi', 'Uncompressed AVI');
outObj.FrameRate = frameRate;

open(outObj);
tic
%%
%Start interleaving
currentFrame = 1;
while (currentFrame < frameCount)
    if (WMInput(currentFrame) == 0)
        writeVideo(outObj,video0Data(currentFrame).cdata);
    else
        writeVideo(outObj,video1Data(currentFrame).cdata);
    end
    currentFrame = currentFrame + 1
end

% Close the file.
close(outObj);
toc
