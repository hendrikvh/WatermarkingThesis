clc

video0 = 'HartungVideo0.avi';
video1 = 'HartungVideo1.avi';

%WMInput = [1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1];
WMInput = int8(rand(1,60));
tic
%%
%Get input video properties. Assume video1 & video is the same

%Get attributes of video0
video0Obj = VideoReader(video0);

frameRate = video0Obj.frameRate
frameSize = [video0Obj.height video0Obj.width] %height * width
frameCount = video0Obj.numberOfFrames

%Create video1 object
video1Obj = VideoReader(video1);

outObj = VideoWriter('Interleaved.avi', 'Uncompressed AVI');
outObj.FrameRate = frameRate;

get(video0Obj);
get(video1Obj);
open(outObj);

%%
%Start interleaving
currentFrame = 1;
while (currentFrame < 60)
    if (WMInput(currentFrame) == 0)
        writeVideo(outObj,read(VideoReader(video0),currentFrame));
    else
        writeVideo(outObj,read(VideoReader(video1),currentFrame));
    end
    currentFrame = currentFrame + 1
end

% Close the file.
close(outObj);
toc
