function [] = Interleave(video0,video1, WMInput, framesToMark)
%%
%Get input video properties. Assume video1 & video is the same
tic
%Get attributes of video0
video0Obj = VideoReader(video0);

frameRate = video0Obj.frameRate;
frameHeight = video0Obj.height;
frameWidth = video0Obj.width;
frameCount = video0Obj.numberOfFrames;

%Create video1 object
video1Obj = VideoReader(video1);

%Preallocate structs for videos
video0Data(1:framesToMark) = struct('cdata', zeros(frameHeight, frameWidth, 3, 'uint8'),'colormap', []);
video1Data(1:framesToMark) = struct('cdata', zeros(frameHeight, frameWidth, 3, 'uint8'),'colormap', []);

% Read one frame at a time.
for k = 1 : framesToMark
    fprintf ('Reading frame %d.\n',k);
    video0Data(k).cdata = read(video0Obj, k);
    video1Data(k).cdata = read(video1Obj, k);
end


outObj = VideoWriter('Interleaved.avi', 'Uncompressed AVI');
outObj.FrameRate = frameRate;

open(outObj);

%%
%Start interleaving
currentFrame = 1;
while (currentFrame <= framesToMark)
    fprintf ('Current frame %d.\n', currentFrame);
    if (WMInput(currentFrame) == 0)
        writeVideo(outObj,video0Data(currentFrame).cdata);
    else
        writeVideo(outObj,video1Data(currentFrame).cdata);
    end
    currentFrame = currentFrame + 1;
end

% Close the file.
close(outObj);
toc



end