% -------------------------------------------------
% WMToVideo.m
% -------------------------------------------------
% 
% Embeds a watermark into video and writes file to disk.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


%Start clean
clear all;
close all;
clc;

%% Config
inputVideo = '~/Media3/xiph/Aspen_8bit.avi';
outputVideo = '~/Media2/WMVideoFinal2';
offset = 60; %to start watermarking at offset frames instead of frame 1
WMLength = 80; % Number of bits to embed

blockLength = 16;
framesToWM = blockLength*28;

% SS Setup
seed = rng;
SSIntensity = 0.0052;
%SSIntensity = 0.7;

% SVD setup
smallestS = 13;
%smallestS = 2;
SVDIntensity = 0.13;

% DFT setup
rmin = 0.3;
rmax = 0.6;
padInner = 2;
padOuter = 2;
DFTIntensity = 8.3;
%DFTintensity = 270000;

% DWT Setup
T = 100;
Q = 31;
%Q = 9000;

%% Housekeeping
currentFrameInVideo = offset + 1;
techniqueRun = 1;
WMYBlock = 0;
runNumber = 1;

WMInput = round(rand(1,WMLength)); 

while (techniqueRun <= 4)
    
    outputVideoWithNum = strcat(outputVideo, num2str(techniqueRun), '.avi');
    
    %% Make, WM & write back video block
    % Make & open video object
    writerObj = VideoWriter(outputVideoWithNum, 'Uncompressed AVI');
    writerObj.FrameRate = 30;
    open(writerObj);


    while(currentFrameInVideo <= framesToWM + offset)
       fprintf ('Creating video block starting at frame %d.\n', currentFrameInVideo);

       [YBlock YCbCrBlock] = MakeVideoBlock(inputVideo,blockLength,currentFrameInVideo); % Make block
       
        blockBegin = (currentFrameInVideo - 1)*3 + 1;
        blockEnd = (currentFrameInVideo + blockLength - 1) * 3;

       % WM block
       switch techniqueRun
           case 1
                seed = rng;
                WMYBlock = Hartung1998Embed(YBlock, WMInput, SSIntensity , seed);
                seeds(runNumber) = seed; %#ok<*SAGROW>
                SSWMInputs(runNumber,:) = WMInput;
               
           case 2
                WMYBlock = Kong2006Embed(YBlock, WMInput, smallestS, SVDIntensity);
                SVDWMInputs(runNumber,:) = WMInput;
                
           case 3
                [WMYBlock, G] = Deguillaume1999Embed(YBlock, WMInput, rmin, rmax, padInner, padOuter, DFTIntensity);
                DFTWMInputs(runNumber,:) = WMInput;
               
           case 4
               WMInputs(runNumber,:) = WMInput;
               WMYBlock = Inoue2000Embed(YBlock(1:1072, 1:1920, 1:end), WMInput, T, Q );
               WMYBlock(1073:1080, 1:1920, 1:end) = YBlock(1073:1080, 1:1920, 1:end);
       end

      WMRGBBlock = BlocksToRGB(WMYBlock,YCbCrBlock); %Combine blocks to get WMRGBBlock
       
      for i = 1:blockLength
        WMRGBFrame(:,:,1) = im2uint8(WMRGBBlock(:,:,(i - 1) * 3 + 1));
        WMRGBFrame(:,:,2) = im2uint8(WMRGBBlock(:,:,(i - 1) * 3 + 2));
        WMRGBFrame(:,:,3) = im2uint8(WMRGBBlock(:,:,(i - 1) * 3 + 3));
        
        writeVideo(writerObj,WMRGBFrame);
        
      end
      
      currentFrameInVideo = currentFrameInVideo + blockLength;
      runNumber = runNumber + 1;
    end

    %Close the file.
    close(writerObj);


    techniqueRun = techniqueRun + 1;
    currentFrameInVideo = offset + 1;

end

save ('WMInput','WMInput','seeds', 'G');

%save ('~/Media3/EmbedWorkspace', '-v7.3');

% setpref('Internet','SMTP_Server','mail.sun.ac.za');
% setpref('Internet','E_mail','hendrik@hendrikvh.com');
% sendmail ('hendrik@hendrikvh.com','Watermarking finished.','Watermarking finished.')