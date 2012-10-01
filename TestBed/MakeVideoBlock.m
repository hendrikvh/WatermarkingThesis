% -------------------------------------------------
% MakeVideoBlock
% -------------------------------------------------
% 
% Created a video block for use by TestBed.m
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


function [YBlock, YCbCrBlock] = MakeVideoBlock(inputVideo, blockLength, currentFrameInVideo)

currentFrameInBlock = 1;

while (currentFrameInBlock <= blockLength) % was (currentFrameInBlock - offset <= blockLength)
    
    %Colour space conversion
    RGBFrame = read(VideoReader(inputVideo),currentFrameInVideo);
    YCFrame = rgb2ycbcr(RGBFrame);
    YCFrame = im2double (YCFrame);
    
    %Create YCbCr block
    YCbCrBlock(:,:,(currentFrameInBlock - 1) * 3 + 1) = YCFrame(:,:,1);
    YCbCrBlock(:,:,(currentFrameInBlock - 1) * 3 + 2) = YCFrame(:,:,2);
    YCbCrBlock(:,:,(currentFrameInBlock - 1) * 3 + 3) = YCFrame(:,:,3);
    
    
    %Make Y block
    YBlock(:,:,currentFrameInBlock) = YCFrame(:,:,1);

    currentFrameInBlock = currentFrameInBlock + 1;
    currentFrameInVideo = currentFrameInVideo + 1;
end