% -------------------------------------------------
% GetParameters.m
% -------------------------------------------------
% 
% Find parameters for watermarking in order to obtain specified visual
% quality. Not fully automated for large variations in visual targets.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


%clear all;
close all;
clc;

%% Setup
currentFrameInVideo = 61;
inputVideo = '~/Media3/xiph/Aspen_8bit.avi';
inputVideo2 = '~/Media3/xiph/WestWindEasy_8bit.avi';
WMLength = 40;
blockLength = 2;

SSIMTarget = 0.999;
flickerTarget = 200000;

%SSIMTarget = 40;

seed = rng;

if (~exist('YBlock','var'))
    fprintf ('Creating video block starting at frame %d.\n', currentFrameInVideo);
    [YBlock ~] = MakeVideoBlock(inputVideo,blockLength,currentFrameInVideo); % Make block
    currentFrameInVideo = currentFrameInVideo + blockLength;
end

WMInput = round(rand(1,WMLength)); 


%SVD
intensity = 0.19;
spottySSIM = 1;
flicker = 0;
smallestS = 13;
minSpottySSIM = 1;
meanSSIM = 1;

while ( (meanSSIM > SSIMTarget) && (flicker < flickerTarget))

    intensity = intensity + 0.01;
    WMInput = round(rand(1,WMLength)); 
    
    WMYBlock = Kong2006Embed(YBlock, WMInput, smallestS, intensity);
    
    %[badPixelsFrame spottySSIM minSpottySSIM meanSSIM] = GetQual(YBlock,WMYBlock, 0.9995);
%     frameFlicker = FlickerMetric(YBlock, WMYBlock);
%     flicker = max(frameFlicker);      
    
    bottomSSIM = BottomSSIM (YBlock, WMYBlock, 100);
    %meanSSIM = mean(bottomSSIM);
    meanSSIM = mean(bottomSSIM);
    
    if (meanSSIM >= SSIMTarget) && (flicker < flickerTarget)
        fprintf ('SVD: SmallestS = %3.1f alpha = %3.4f for SSIM of %3.5f and flicker of %3.4f\n', smallestS, intensity, meanSSIM, flicker) 
    end
end

 fprintf ('---------------------------------\n') 


SS
intensity = 0.004;
meanSSIM = 1;
flicker = 0;

while ( (meanSSIM > SSIMTarget) && (flicker <= flickerTarget))
    
    intensity = intensity + 0.0001;
    WMInput = round(rand(1,WMLength)); 


    WMYBlock = Hartung1998Embed(YBlock, WMInput, intensity , seed); 

    
    bottomSSIM = BottomSSIM (YBlock, WMYBlock, 100);
    meanSSIM = mean(bottomSSIM);
    
    frameFlicker = FlickerMetric(YBlock, WMYBlock);
    flicker = max(frameFlicker);
       
     if (meanSSIM >= SSIMTarget) && (flicker <= flickerTarget)
        fprintf ('SS: Alpha = %3.4f for SSIM of %3.4f and flicker of %3.4f.\n', intensity, meanSSIM, flicker) 
     end
end

 fprintf ('---------------------------------\n') 



%DWT
intensity = 22;
meanSSIM = 1;
flicker = 0;

while ( (meanSSIM > SSIMTarget) && (flicker < flickerTarget))
    
    intensity = intensity + 1;
    WMInput = round(rand(1,WMLength)); 


    WMYBlock = Inoue2000Embed(YBlock(1:1072, 1:1920, 1:end), WMInput, 120, intensity );
    WMYBlock(1073:1080, 1:1920, 1:end) = YBlock(1073:1080, 1:1920, 1:end);
    
    frameFlicker = FlickerMetric(YBlock, WMYBlock);
    flicker = max(frameFlicker);
  
    bottomSSIM = BottomSSIM (YBlock, WMYBlock, 100);
    meanSSIM = mean(bottomSSIM);
    meanSSIM = mean(bottomSSIM);
       
    if (meanSSIM >= SSIMTarget) && (flicker <= flickerTarget)
        fprintf ('DWT: Alpha = %3.4f for SSIM of %3.5f and flicker of %3.4f\n', intensity, meanSSIM, flicker)  
     end
    
    
end

 fprintf ('---------------------------------\n') 

% DFT 
 
intensity = 7.5;
minSpottySSIM = 1;
meanSSIM = 1;
flicker = 0;
flickerTarget = 2000000;

while ( (meanSSIM > SSIMTarget) && (flicker < flickerTarget))
    
    intensity = intensity + 0.3;
    WMInput = round(rand(1,WMLength)); 
    
    WMYBlock = Deguillaume1999Embed(YBlock, WMInput, 0.3, 0.6, 2, 2, intensity);    
%     frameFlicker = FlickerMetric(YBlock, WMYBlock);
%     flicker = max(frameFlicker);
    
    bottomSSIM = BottomSSIM (YBlock, WMYBlock, 100);
    meanSSIM = mean(bottomSSIM);
      
    if (meanSSIM >= SSIMTarget) && (flicker < flickerTarget)
        fprintf ('DFT: Alpha = %3.4f for SSIM of %3.5f and flicker of %3.5f\n', intensity, meanSSIM, flicker) 
    end
    
end

        fprintf ('---------------------------------\n') 
