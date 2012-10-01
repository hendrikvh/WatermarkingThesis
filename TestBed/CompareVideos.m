% -------------------------------------------------
% CompareVideos
% -------------------------------------------------
% 
% Determine if two video files are identical. To ensure that compression
% was done correctly.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


clear all
close all
clc

%% Read the two video blocks from file

%Define your two files here
video1 = '~/Media2/xiph/Aspen_8bit.avi';
video2 = '~/Media2/xiph/ControlledBurn_8bit.avi';


% Find out how many frames there are
obj1 = VideoReader(video1);
obj2 = VideoReader(video2);

nFrames1 = obj1.NumberOfFrames;
nFrames2 = obj2.NumberOfFrames;

if (nFrames1 == nFrames2)
    fprintf ('Number of frames are the same at %3.0f each. Great!\n',nFrames1);
else
    fprintf ('Number of frames are not the same. Something is wrong\n.')
end

% How many frames do we want to compare?
numberOfFramesToCheck = 10;

%% Now compare it

currentFrameInVideo = 1;
diff = 0;
while (currentFrameInVideo <= numberOfFramesToCheck)
 
    RGBFrame1 = read(VideoReader(video1),currentFrameInVideo);
    RGBFrame2 = read(VideoReader(video2),currentFrameInVideo);

    diff = sum(sum(sum(abs(RGBFrame1 - RGBFrame2)))) + diff;
    
    fprintf ('At frame %d there is a total diff of %3.2f.\n', currentFrameInVideo, diff);

    currentFrameInVideo = currentFrameInVideo + 1;
end
 
if (diff == 0)
    fprintf ('The files are identical. Well done.\n');
else
    fprintf ('The files are not identical. Something is wrong.\n');
end