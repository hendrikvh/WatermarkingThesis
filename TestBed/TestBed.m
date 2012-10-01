% -------------------------------------------------
% TestBed.m
% -------------------------------------------------
% 
% Used to evaluate robustness of watermarking techniques.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------



%% Start clean
clear all;
close all;
clc;

%% Config
emailMessage = ' Loose Rotation Final';
WMLength = 80; % Number of bits to embed
inputVideo = '~/Media3/xiph/Aspen_8bit.avi';
inputVideo2 = '~/Media3/xiph/WestWindEasy_8bit.avi';
loadNextVideo = 29;
blockLength = 16;
runNumbers = 3;
offset = 60; %to start watermarking at offset frames instead of frame 1

% Tests to run
tRotation = 0;%
tResize = 1;
tScale = 0;
tFilter = 0;
tNoise = 0;%
tShiftX = 0;%
tShiftY = 0;%
tShiftXY = 0;%
tShiftZ = 0;
tCrop = 0;%
tDenoise = 0;
tAmplitude = 0;%
tFlipUD = 0;
tFlipLR = 0;
tQuan = 0;
tQual = 0;
tBlend = 0;
tCascade = 0;

% SS Setup
seed = rng;
SSIntensity = 0.0052;

% SVD setup
smallestS = 13;
smallestS = 3;
SVDIntensity = 0.13;

% DFT setup
rmin = 0.3;
rmax = 0.6;
padInner = 2;
padOuter = 2;
DFTintensity = 8.3;

% DWT Setup
T = 100;
Q = 31;

% Rotation setup
rotationStart = 0;
rotationEnd = 0.75;
rotationStep = 0.025;

% Filter setup
radiusMin = 1;
radiusMax = 25;
radiusStep = 2;

% Resize setup
sizes = [720 1280; 800 800; 768 1024; 480 640; 500 500; 240 320; 200 320; 100 100; 50 50];
scaleStart = 0.5;
scaleEnd = 0.2;
scaleStep = 0.1;

% Noise setup
noiseAlphaStart = 0;
noiseAlphaMax = 1;
noiseAlphaStep = 0.1;

% X Shift setup
XShiftStart = 0;
XShiftEnd = 60;
XShiftStep = 3;

% Y Shift setup
YShiftStart = 0;
YShiftEnd = 60;
YShiftStep = 3;

% XY Shift setup
XYShiftStart = 0;
XYShiftEnd = 60;
XYShiftStep = 3;

% Crop setup
cropStart = 0;
cropEnd = 540;
cropStep = 45;
background = 0;

%ShiftZ setup
shiftZStart = 0;
shiftZEnd = 16;
shiftZStep = 1;

% Wiener denoise setup
wienerWindowStart = 2;
wienerWindowEnd = 26;
wienerWindowStep = 3;

%Amplitude scale setup
amplitudeScaleStep = 0.2;
amplitudeScaleStart = -1;
amplitudeScaleEnd = 1;

%Levels setup
qLevelsStart = 128;
qLevelsEnd = 2;
qLevelsStep = 20;

%Blend setup
blendStart = 16;
blendEnd = 16;

%Cascade Setup
cascadeStart = 1;
cascadeEnd = 10;
cascadeStep = 1;

%Indexing
currentFrameInVideo = offset + 1;

verbose = 0;
outputFile = 'Results';
outputFile = strcat(outputFile, num2str(WMLength), date, '.csv');

%% Start first run
runNumber = 1;

while(runNumber <= runNumbers)
    if (runNumber == loadNextVideo)
        inputVideo = inputVideo2;
        currentFrameInVideo = 61;
    end
    
    
    tic
    dlmwrite (outputFile, runNumbers);
    fprintf ('Run number %d of %d.\n',runNumber, runNumbers);
       
    %% Make video block
    fprintf ('Creating video block starting at frame %d.\n', currentFrameInVideo);
    [YBlock ~] = MakeVideoBlock(inputVideo,blockLength,currentFrameInVideo); % Make block
    currentFrameInVideo = currentFrameInVideo + blockLength;
    
    WMInput = round(rand(1,WMLength)); 
   
   %% Embed all the watermaks
   SSWMYBlock = Hartung1998Embed(YBlock, WMInput, SSIntensity, seed);
   SVDWMYBlock = Kong2006Embed(YBlock, WMInput, smallestS, SVDIntensity);
   [DFTWMYBlock, G] = Deguillaume1999Embed(YBlock, WMInput, rmin, rmax, padInner, padOuter, DFTintensity);
  
   DWTWMYBlock = Inoue2000Embed(YBlock(1:1072, 1:1920, 1:end), WMInput, T, Q );
   DWTWMYBlock(1073:1080, 1:1920, 1:end) = YBlock(1073:1080, 1:1920, 1:end);
   
   dlmwrite (outputFile, WMLength, '-append');

   
   %% Test rotation
   if (tRotation)
    fprintf ('Rotation time!\n');
    rotationIteration = 1;
    rotation = rotationStart;

    % Cropped rotation
    while (rotation <= rotationEnd)
    headings(1,rotationIteration) = rotation; %#ok<*SAGROW>


       %% Rotate SS
       SSAttackedWMYBlock = imrotate(SSWMYBlock,rotation,'loose');
       SSAttackedWMYBlock = imresize(SSAttackedWMYBlock,[size(YBlock,1), size(YBlock,2)]);

        % Extract
       extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f rotation.\n', errorBitCount, BER, rotation);

        % Store results in memory
        SSRotResults(runNumber,rotationIteration) = BER;

        %% Rotate SVD
        SVDAttackedWMYBlock = imrotate(SVDWMYBlock,rotation,'loose');
        SVDAttackedWMYBlock = imresize(SVDAttackedWMYBlock,[size(YBlock,1), size(YBlock,2)]); % Only neccesary for loose rotation

        % Extract
        extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f rotation.\n', errorBitCount, BER, rotation);

        % Store results in memory
        SVDRotResults(runNumber,rotationIteration) = BER;

        %% Rotate DFT
        DFTAttackedWMYBlock = imrotate(DFTWMYBlock,rotation,'loose');
        DFTAttackedWMYBlock = imresize(DFTAttackedWMYBlock,[size(YBlock,1), size(YBlock,2)]);

        % Extract
        extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength, rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f rotation.\n', errorBitCount, BER, rotation);

        % Store results in memory
        DFTRotResults(runNumber,rotationIteration) = BER;

        %% Rotate DWT
        DWTAttackedWMYBlock = imrotate(DWTWMYBlock,rotation,'loose');
        DWTAttackedWMYBlock = imresize(DWTAttackedWMYBlock,[size(YBlock,1), size(YBlock,2)]);

        % Extract
        DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f rotation.\n', errorBitCount, BER, rotation);

        % Store results in memory
        DWTRotResults(runNumber,rotationIteration) = BER;
        
        if (rotation < 0.05)
            rotation = rotation + 0.025;
        else
                rotation = rotation + rotationStep;
        end
        rotationIteration = rotationIteration + 1; 
        
        if (verbose)
        imshow (DFTAttackedWMYBlock(:,:,1));
        pause (0.1);
        end

    end

    % Write rotation results to file
    StoreResults(outputFile,'Rotation', headings, SSRotResults, DFTRotResults, SVDRotResults, DWTRotResults)
    clear headings;
   end
    %% Test resizing
    if (tResize)
        fprintf ('Resize time!\n');   
        i = 1;

        % Resize
        while (i <=  size(sizes,1))

        headings(1 ,i) = sizes(i,1);

        %% Resize SS
        SSAttackedWMYBlock = imresize (SSWMYBlock, sizes (i,:));

        % Extract
        SSAttackedWMYBlock = PadBlock(SSAttackedWMYBlock); % For padding
%         SSAttackedWMYBlock = imresize (SSAttackedWMYBlock, [size(YBlock,1) size(YBlock,2)]);
        extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed); % for not padding

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f at size %3.2f.\n', errorBitCount, BER, sizes(i,1));

        % Store results in memory
        SSSizeResults(runNumber,i) = BER;

        %% Resize SVD
        SVDAttackedWMYBlock = imresize (SVDWMYBlock, sizes (i,:));

        % Extract
        SVDAttackedWMYBlock = PadBlock(SVDAttackedWMYBlock); % For padding
%         SVDAttackedWMYBlock = imresize (SVDAttackedWMYBlock, [size(YBlock,1) size(YBlock,2)]); %for not padding
         extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f at size %3.2f.\n', errorBitCount, BER, sizes(i,1));

        % Store results in memory
        SVDSizeResults(runNumber,i) = BER;

        %% Resize DFT
        DFTAttackedWMYBlock = imresize (DFTWMYBlock, sizes (i,:));

        % Extract
        DFTAttackedWMYBlock = PadBlock(DFTAttackedWMYBlock); % for padding
%         DFTAttackedWMYBlock = imresize (DFTAttackedWMYBlock, [size(YBlock,1) size(YBlock,2)]); %for not padding
         extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f at size %3.2f.\n', errorBitCount, BER, sizes(i,1));

        % Store results in memory
        DFTSizeResults(runNumber,i) = BER;

        %% Resize DWT
        DWTAttackedWMYBlock = imresize (DWTWMYBlock, sizes (i,:));

        % Extract
        DWTAttackedWMYBlock = PadBlock(DWTAttackedWMYBlock); %For padding
%         DWTAttackedWMYBlock = imresize (DWTAttackedWMYBlock, [size(YBlock,1) size(YBlock,2)]);%for not padding

%         DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f at size %3.2f.\n', errorBitCount, BER, sizes(i,1));

        % Store results in memory
        DWTSizeResults(runNumber,i) = BER;

        i = i + 1;

        if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
        end

        end

        % Write rotation results to file
        StoreResults(outputFile,'Resize', headings, SSSizeResults, DFTSizeResults, SVDSizeResults, DWTSizeResults)
        clear headings;

    end

    
    
    %% Test Scaling Size
  if (tScale)
        fprintf ('Scale time!\n');   
        scale = scaleStart;
        
        i = 1;
        % Filter
        while (scale >= scaleEnd )

        headings(1 ,i) = scale;

        %% Scale SS
        SSAttackedWMYBlock = imresize (SSWMYBlock, scale);
        SSAttackedWMYBlock = PadBlock(SSAttackedWMYBlock);

        % Extract
        extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f at scale %3.2f.\n', errorBitCount, BER, scale);

        % Store results in memory
        SSScaleResults(runNumber,i) = BER;

        %% Scale SVD
        SVDAttackedWMYBlock = imresize (SVDWMYBlock, scale);
        SVDAttackedWMYBlock = PadBlock(SVDAttackedWMYBlock);

        % Extract
        extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f at scale %3.2f.\n', errorBitCount, BER, scale);

        % Store results in memory
        SVDScaleResults(runNumber,i) = BER;

        %% Scale DFT
        DFTAttackedWMYBlock = imresize (DFTWMYBlock, scale);
        DFTAttackedWMYBlock = PadBlock(DFTAttackedWMYBlock);


        % Extract
        extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f at scale %3.2f.\n', errorBitCount, BER, scale);

        % Store results in memory
        DFTScaleResults(runNumber,i) = BER;

        %% Scale DWT
        DWTAttackedWMYBlock = imresize (DWTWMYBlock, scale);
        DWTAttackedWMYBlock = PadBlock(DWTAttackedWMYBlock);
        
        % Extract
        DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f at alpha %3.2f.\n', errorBitCount, BER, scale);

        % Store results in memory
        DWTScaleResults(runNumber,i) = BER;

        scale = scale - scaleStep;
        i = i + 1;

        if (verbose)
        imshow (DFTAttackedWMYBlock(:,:,1));
        pause (0.1);

        end

        end

        % Write scale results to file
        StoreResults(outputFile,'Scale', headings, SSScaleResults, DFTScaleResults, SVDScaleResults, DWTScaleResults)
        clear headings;
  end
    

    %% Test filtering
    if (tFilter)
        fprintf ('Filter time!\n');   
        radius = radiusMin;
        i = 1;
        % Filter
        while (radius <=  radiusMax)

        % Filter
        h = fspecial('average',radius);
        %HPFrame = WMFrame - filteredFrame;

        headings(1 ,i) = radius;

        %% Filter SS
        SSAttackedWMYBlock = imfilter (SSWMYBlock, h, 'replicate');

        % Extract
        extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f at radius %3.2f.\n', errorBitCount, BER, radius);

        % Store results in memory
        SSFilterResults(runNumber,i) = BER;

        %% Filter SVD
        SVDAttackedWMYBlock = imfilter (SVDWMYBlock, h, 'replicate');

        % Extract
        extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f at radius %3.2f.\n', errorBitCount, BER, radius);

        % Store results in memory
        SVDFilterResults(runNumber,i) = BER;

        %% Filter DFT
        DFTAttackedWMYBlock = imfilter (DFTWMYBlock, h, 'replicate');

        % Extract
        extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f at radius %3.2f.\n', errorBitCount, BER, radius);

        % Store results in memory
        DFTFilterResults(runNumber,i) = BER;

         %% Filter DWT
        DWTAttackedWMYBlock = imfilter (DWTWMYBlock, h, 'replicate');

        % Extract
        DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f at radius %3.2f.\n', errorBitCount, BER, radius);

        % Store results in memory
        DWTFilterResults(runNumber,i) = BER;

        radius = radius + radiusStep;
        i = i + 1;

        if (verbose)
        imshow (DFTAttackedWMYBlock(:,:,1));
        pause (0.1);

        end

        end


        % Write rotation results to file
        StoreResults(outputFile,'Filter', headings, SSFilterResults, DFTFilterResults, SVDFilterResults, DWTFilterResults)
        clear headings;

    end

  %% Test adding noise
  if (tNoise)
        fprintf ('Noise time!\n');   
        noiseAlpha = noiseAlphaStart;
        noiseBlock = rand(size(YBlock)) - noiseAlpha/2;
        i = 1;
        % Filter
        while (noiseAlpha <= noiseAlphaMax )

        headings(1 ,i) = noiseAlpha;

        %% Add noise to SS
        SSAttackedWMYBlock = SSWMYBlock + noiseBlock*noiseAlpha;
        SSAttackedWMYBlock(SSAttackedWMYBlock>1) = 1;
        SSAttackedWMYBlock(SSAttackedWMYBlock<0) = 0;

        % Extract
        extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f at alpha %3.2f.\n', errorBitCount, BER, noiseAlpha);

        % Store results in memory
        SSNoiseResults(runNumber,i) = BER;

        %% Add noise to SVD
        SVDAttackedWMYBlock = SVDWMYBlock + noiseBlock*noiseAlpha;
        SVDAttackedWMYBlock(SVDAttackedWMYBlock>1) = 1;
        SVDAttackedWMYBlock(SVDAttackedWMYBlock<0) = 0;


        % Extract
        extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f at alpha %3.2f.\n', errorBitCount, BER, noiseAlpha);

        % Store results in memory
        SVDNoiseResults(runNumber,i) = BER;

        %% Add noise to DFT
        DFTAttackedWMYBlock = DFTWMYBlock + noiseBlock*noiseAlpha;
        DFTAttackedWMYBlock(DFTAttackedWMYBlock>1) = 1;
        DFTAttackedWMYBlock(DFTAttackedWMYBlock<0) = 0;


        % Extract
        extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f at alpha %3.2f.\n', errorBitCount, BER, noiseAlpha);

        % Store results in memory
        DFTNoiseResults(runNumber,i) = BER;

        %% Add noise to DWT
        DWTAttackedWMYBlock = DWTWMYBlock + noiseBlock*noiseAlpha;
        DWTAttackedWMYBlock(DWTAttackedWMYBlock>1) = 1;
        DWTAttackedWMYBlock(DWTAttackedWMYBlock<0) = 0;
        
        % Extract
        DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f at alpha %3.2f.\n', errorBitCount, BER, noiseAlpha);

        % Store results in memory
        DWTNoiseResults(runNumber,i) = BER;

        noiseAlpha = noiseAlpha + noiseAlphaStep;
        i = i + 1;

        if (verbose)
        imshow (DFTAttackedWMYBlock(:,:,1));
        pause (0.1);

        end

        end

        % Write rotation results to file
        StoreResults(outputFile,'Noise', headings, SSNoiseResults, DFTNoiseResults, SVDNoiseResults, DWTNoiseResults)
        clear headings;
  end

   %% Test X shift
   if (tShiftX)
        fprintf ('Shift time!\n');
        iteration = 1;
        shift = XShiftStart;

        % Shiftings
        while (shift <= XShiftEnd)
        headings(1,iteration) = shift;


           %% Shift SS
           SSAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) SSWMYBlock(:,1:end - shift, :)];

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SSXShiftResults(runNumber,iteration) = BER;


            %% Shift SVD
           SVDAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) SVDWMYBlock(:,1:end - shift, :)];

            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SVDXShiftResults(runNumber,iteration) = BER;

            %% Shift DFT
           DFTAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) DFTWMYBlock(:,1:end - shift, :)];

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DFTXShiftResults(runNumber,iteration) = BER;

            %% Shift DWT
           DWTAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) DWTWMYBlock(:,1:end - shift, :)];

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DWTXShiftResults(runNumber,iteration) = BER;

            shift = shift + XShiftStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write rotation results to file
        StoreResults(outputFile,'XShift', headings, SSXShiftResults, DFTXShiftResults, SVDXShiftResults, DWTXShiftResults)
        clear headings;
   end
    
    %% Test Y shift
    if (tShiftY)
        fprintf ('Y Shift time!\n');
        iteration = 1;
        shift = YShiftStart;

        % Shiftings
        while (shift <= YShiftEnd)
        headings(1,iteration) = shift;


           %% Shift SS
           SSAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (SSWMYBlock(1:end - shift,:, :)));

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SSYShiftResults(runNumber,iteration) = BER;


            %% Shift SVD
           SVDAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (SVDWMYBlock(1:end - shift,:, :)));

            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SVDYShiftResults(runNumber,iteration) = BER;

            %% Shift DFT
           DFTAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (DFTWMYBlock(1:end - shift,:, :)));

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DFTYShiftResults(runNumber,iteration) = BER;

            %% Shift DWT
           DWTAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (DWTWMYBlock(1:end - shift,:, :)));

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DWTYShiftResults(runNumber,iteration) = BER;

            shift = shift + YShiftStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write rotation results to file
        StoreResults(outputFile,'YShift', headings, SSYShiftResults, DFTYShiftResults, SVDYShiftResults, DWTYShiftResults)
        clear headings;
    end
    
   %% Shift Z
   if (tShiftZ)
        fprintf ('Shift Z time!\n');
        iteration = 1;
        shift = shiftZStart;

        while (shift <= shiftZEnd)
        headings(1,iteration) = shift;


           %% Crop SS
           SSAttackedWMYBlock = circshift(SSWMYBlock,[0 0 shift]);

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SSShiftZResults(runNumber,iteration) = BER;



           %% Crop SVD
           SVDAttackedWMYBlock = circshift(SVDWMYBlock,[0 0 shift]);


            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SVDShiftZResults(runNumber,iteration) = BER;

            %% Crop DFT
           DFTAttackedWMYBlock = circshift(DFTWMYBlock,[0 0 shift]);

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);


            % Store results in memory
            DFTShiftZResults(runNumber,iteration) = BER;

            %% Crop DWT
            DWTAttackedWMYBlock = circshift(DWTWMYBlock,[0 0 shift]);

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);


            % Store results in memory
            DWTShiftZResults(runNumber,iteration) = BER;

            shift = shift + shiftZStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write rotation results to file
        StoreResults(outputFile,'ZShift', headings, SSShiftZResults, DFTShiftZResults, SVDShiftZResults, DWTShiftZResults)
        clear headings;
   end
   
   %% Test XY shift
    if (tShiftXY)
        fprintf ('XY Shift time!\n');
        iteration = 1;
        shift = XYShiftStart;

        % Shiftings
        while (shift <= XYShiftEnd)
        headings(1,iteration) = shift;


           %% Shift SS
           SSAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (SSWMYBlock(1:end - shift,:, :)));
           SSAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) SSAttackedWMYBlock(:,1:end - shift, :)];

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SSYShiftResults(runNumber,iteration) = BER;


            %% Shift SVD
           SVDAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (SVDWMYBlock(1:end - shift,:, :)));
           SVDAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) SVDAttackedWMYBlock(:,1:end - shift, :)];

            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            SVDYShiftResults(runNumber,iteration) = BER;

            %% Shift DFT
           DFTAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (DFTWMYBlock(1:end - shift,:, :)));
           DFTAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) DFTAttackedWMYBlock(:,1:end - shift, :)];

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DFTYShiftResults(runNumber,iteration) = BER;

            %% Shift DWT
           DWTAttackedWMYBlock = vertcat(zeros(shift,size(YBlock,2),size(YBlock,3)), (DWTWMYBlock(1:end - shift,:, :)));
           DWTAttackedWMYBlock = [zeros(size(YBlock,1), shift,size(YBlock,3)) DWTAttackedWMYBlock(:,1:end - shift, :)];

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f shift.\n', errorBitCount, BER, shift);

            % Store results in memory
            DWTYShiftResults(runNumber,iteration) = BER;

            shift = shift + XYShiftStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write rotation results to file
        StoreResults(outputFile,'XYShift', headings, SSYShiftResults, DFTYShiftResults, SVDYShiftResults, DWTYShiftResults)
        clear headings;
    end
   

%% Cropping
    if (tCrop)
        fprintf ('Y Crop time!\n');
        iteration = 1;
        crop = cropStart;


        % Test cropping
        while (crop <= cropEnd)
        headings(1,iteration) = crop;


           %% Crop SS
           SSAttackedWMYBlock = SSWMYBlock;
           SSAttackedWMYBlock (1:end,1:crop-1,:) = background;
           SSAttackedWMYBlock(1:end, end-crop:end,:) = background;
           % bottoms and the tops
           SSAttackedWMYBlock(1:crop-1,1:end,:) = background;
           SSAttackedWMYBlock(end-crop:end,:,:) = background;

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f crop.\n', errorBitCount, BER, crop);

            % Store results in memory
            SSCropResults(runNumber,iteration) = BER;



           %% Crop SVD
           SVDAttackedWMYBlock = SVDWMYBlock;
           SVDAttackedWMYBlock (1:end,1:crop-1,:) = background;
           SVDAttackedWMYBlock(1:end, end-crop:end,:) = background;
           % bottoms and the tops
           SVDAttackedWMYBlock(1:crop-1,1:end,:) = background;
           SVDAttackedWMYBlock(end-crop:end,:,:) = background;


            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f crop.\n', errorBitCount, BER, crop);


            % Store results in memory
            SVDCropResults(runNumber,iteration) = BER;

            %% Crop DFT
           DFTAttackedWMYBlock = DFTWMYBlock;
           DFTAttackedWMYBlock (1:end,1:crop-1,:) = background;
           DFTAttackedWMYBlock(1:end, end-crop:end,:) = background;
           % bottoms and the tops
           DFTAttackedWMYBlock(1:crop-1,1:end,:) = background;
           DFTAttackedWMYBlock(end-crop:end,:,:) = background;

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f crop.\n', errorBitCount, BER, crop);


            % Store results in memory
            DFTCropResults(runNumber,iteration) = BER;

            %% Crop DWT
           DWTAttackedWMYBlock = DWTWMYBlock;
           DWTAttackedWMYBlock (1:end,1:crop-1,:) = background;
           DWTAttackedWMYBlock(1:end, end-crop:end,:) = background;
           % bottoms and the tops
           DWTAttackedWMYBlock(1:crop-1,1:end,:) = background;
           DWTAttackedWMYBlock(end-crop:end,:,:) = background;

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f crop.\n', errorBitCount, BER, crop);


            % Store results in memory
            DWTCropResults(runNumber,iteration) = BER;

            crop = crop + cropStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write rotation results to file
        StoreResults(outputFile,'Crop', headings, SSCropResults, DFTCropResults, SVDCropResults, DWTCropResults)
        clear headings;
    end
    
    %% Wiener denoise
        if (tDenoise)
        fprintf ('Denoise time!\n');
        iteration = 1;
        window = wienerWindowStart;

        while (window <= wienerWindowEnd)
        headings(1,iteration) = window;


           %% Denoise SS
           for F = 1:blockLength
            SSAttackedWMYBlock(:,:,F) = wiener2(SSWMYBlock(:,:,F),[window window]);
           end

            % Extract
           extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f window.\n', errorBitCount, BER, window);

            % Store results in memory
            SSWienerResults(runNumber,iteration) = BER;


           %% Denoise SVD
           for F = 1:blockLength
            SVDAttackedWMYBlock(:,:,F) = wiener2(SVDWMYBlock(:,:,F),[window window]);
           end


            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f window.\n', errorBitCount, BER, window);

            % Store results in memory
            SVDWienerResults(runNumber,iteration) = BER;

            %% Crop DFT
            for F = 1:blockLength
            DFTAttackedWMYBlock(:,:,F) = wiener2(DFTWMYBlock(:,:,F),[window window]);
            end

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f window.\n', errorBitCount, BER, window);


            % Store results in memory
            DFTWienerResults(runNumber,iteration) = BER;

            %% Denoise DWT
            DWTAttackedWMYBlock = ones (size(YBlock));
            for F = 1:blockLength
            DWTAttackedWMYBlock(:,:,F) = wiener2(DWTWMYBlock(:,:,F),[window window]);
            end

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f window.\n', errorBitCount, BER, window);


            % Store results in memory
            DWTWienerResults(runNumber,iteration) = BER;

            window = window + wienerWindowStep;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write denoise results to file
        StoreResults(outputFile,'Wiener', headings, SSWienerResults, DFTWienerResults, SVDWienerResults, DWTWienerResults)
        clear headings;
        end
    
   %% Apmlitude scaling
   if (tAmplitude)
            fprintf ('Amplitude scale time!\n');
            amplitudeScale = amplitudeScaleStart;
            iteration = 1;

            while (amplitudeScale <= amplitudeScaleEnd)
            headings(1,iteration) = amplitudeScale;


               %% Scale A SS
                SSAttackedWMYBlock = SSWMYBlock + amplitudeScale;
                SSAttackedWMYBlock(SSAttackedWMYBlock>1) = 1;
                SSAttackedWMYBlock(SSAttackedWMYBlock<0) = 0;

                % Extract
               extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('SS:\t%d bit errors with BER of %3.2f after %3.2f AS.\n', errorBitCount, BER, amplitudeScale);

                % Store results in memory
                SSASResults(runNumber,iteration) = BER;


               %% Scale A SVD
               SVDAttackedWMYBlock = SVDWMYBlock + amplitudeScale;
               SVDAttackedWMYBlock(SVDAttackedWMYBlock>1) = 1;
               SVDAttackedWMYBlock(SVDAttackedWMYBlock<0) = 0;

                % Extract
                extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('SVD:\t%d bit errors with BER of %3.2f after %3.2f AS.\n', errorBitCount, BER, amplitudeScale);

                % Store results in memory
                SVDASResults(runNumber,iteration) = BER;

                %% Scale A DFT
                DFTAttackedWMYBlock = DFTWMYBlock + amplitudeScale;
                DFTAttackedWMYBlock(DFTAttackedWMYBlock>1) = 1;
                DFTAttackedWMYBlock(DFTAttackedWMYBlock<0) = 0;

                % Extract
                extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('DFT:\t%d bit errors with BER of %3.2f after %3.2f AS.\n', errorBitCount, BER, amplitudeScale);


                % Store results in memory
                DFTASResults(runNumber,iteration) = BER;

                %% Scale A DWT
                DWTAttackedWMYBlock = DWTWMYBlock + amplitudeScale;
                DWTAttackedWMYBlock(DWTAttackedWMYBlock>1) = 1;
                DWTAttackedWMYBlock(DWTAttackedWMYBlock<0) = 0;

                % Extract
                DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
                extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('DWT:\t%d bit errors with BER of %3.2f after %3.2f AS.\n', errorBitCount, BER, amplitudeScale);


                % Store results in memory
                DWTASResults(runNumber,iteration) = BER;

                amplitudeScale = amplitudeScale + amplitudeScaleStep;
                iteration = iteration + 1;

                if (verbose)
                imshow (DFTAttackedWMYBlock(:,:,1));
                pause (0.1);
                end

            end

            % Write Scale A results to file
            StoreResults(outputFile,'Amplitude', headings, SSASResults, DFTASResults, SVDASResults, DWTASResults)
            clear headings;
   end
    
 %% Flip LR
    if (tFlipLR)
        fprintf ('Flip LR time!\n');


           %% Flip SS
            for k = 1:size(YBlock,3)
            SSAttackedWMYBlock(:,:,k) = fliplr(SSWMYBlock(:,:,k));
            end

            % Extract
            extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

            % Store results in memory
            SSFlipLRResults(runNumber,1) = BER;


           %% Flip SVD
            for k = 1:size(YBlock,3)
            SVDAttackedWMYBlock(:,:,k) = fliplr(SVDWMYBlock(:,:,k));
            end

            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

            % Store results in memory
            SVDFlipLRResults(runNumber,1) = BER;

            %% Flip DFT
            for k = 1:size(YBlock,3)
                DFTAttackedWMYBlock(:,:,k) = fliplr(DFTWMYBlock(:,:,k));
            end

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);


            % Store results in memory
            DFTFlipLRResults(runNumber,1) = BER;

            %% Scale A DWT
            for k = 1:size(YBlock,3)
                DWTAttackedWMYBlock(1:1072, 1:1920,k) = fliplr(DWTWMYBlock(1:1072, 1:1920,k));
            end

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

            % Store results in memory
            DWTFlipLRResults(runNumber,1) = BER;

            if (1)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end


        % Write Scale A results to file
        StoreResults(outputFile,'FlipLR', 'LR', SSFlipLRResults, DFTFlipLRResults, SVDFlipLRResults, DWTFlipLRResults)
    end
   
   %% Flip UD
   if (tFlipUD)
            fprintf ('Flip UD time!\n');


               %% Flip SS
                for k = 1:size(YBlock,3)
                SSAttackedWMYBlock(:,:,k) = flipud(SSWMYBlock(:,:,k));
                end

                % Extract
                extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('SS:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

                % Store results in memory
                SSFlipUDResults(runNumber,1) = BER;


               %% Flip SVD
                for k = 1:size(YBlock,3)
                SVDAttackedWMYBlock(:,:,k) = flipud(SVDWMYBlock(:,:,k));
                end

                % Extract
                extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('SVD:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

                % Store results in memory
                SVDFlipUDResults(runNumber,1) = BER;

                %% Flip DFT
                for k = 1:size(YBlock,3)
                    DFTAttackedWMYBlock(:,:,k) = flipud(DFTWMYBlock(:,:,k));
                end

                % Extract
                extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('DFT:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);


                % Store results in memory
                DFTFlipUDResults(runNumber,1) = BER;

                %% Flip DWT
                for k = 1:size(YBlock,3)
                    DWTAttackedWMYBlock(1:1072, 1:1920,k) = flipud(DWTWMYBlock(1:1072, 1:1920,k));
                end

                % Extract
                DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
                extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

                % Evaluate
                [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                fprintf ('DWT:\t%d bit errors with BER of %3.2f after LR flip.\n', errorBitCount, BER);

                % Store results in memory
                DWTFlipUDResults(runNumber,1) = BER;

                if (verbose)
                imshow (DFTAttackedWMYBlock(:,:,1));
                pause (0.1);
                end


            % Write flip UD results to file
            StoreResults(outputFile,'FlipUD', 'FlipUD', SSFlipUDResults, DFTFlipUDResults, SVDFlipUDResults, DWTFlipUDResults)
   end
   
    %% Quantisation
    if (tQuan)
        fprintf ('Quantisation time!\n');
        levels = qLevelsStart;
        iteration = 1;

        while (levels >= qLevelsEnd)
        headings(1,iteration) = levels;

           %% Quantise SS
            SSAttackedWMYBlock = round(SSWMYBlock * (levels-1))/(levels-1);

            % Extract
            extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f with %3.2f levels.\n', errorBitCount, BER, levels);

            % Store results in memory
            SSQResults(runNumber,iteration) = BER;


           %% Q SVD
           SVDAttackedWMYBlock = round(SVDWMYBlock * (levels-1))/(levels-1);
            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f with %3.2f levels.\n', errorBitCount, BER, levels);

            % Store results in memory
            SVDQResults(runNumber,iteration) = BER;

            %% Q DFT
            DFTAttackedWMYBlock = round(DFTWMYBlock * (levels-1))/(levels-1);
            DFTAttackedWMYBlock(DFTAttackedWMYBlock>1) = 1;

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f with %3.2f levels.\n', errorBitCount, BER, levels);


            % Store results in memory
            DFTQResults(runNumber,iteration) = BER;

            %% Scale A DWT
            DWTAttackedWMYBlock = round(DWTWMYBlock * (levels-1))/(levels-1);
            DWTAttackedWMYBlock(DWTAttackedWMYBlock>1) = 1;

            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f with %3.2f levels.\n', errorBitCount, BER, levels);


            % Store results in memory
            DWTQResults(runNumber,iteration) = BER;

            if (levels > 64)
                levels = levels - qLevelsStep;
            elseif ( (levels <= 64) && (levels > 8))
                levels = levels - 10;
            else
                levels = levels - 5;
            end
            
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write Scale A results to file
        StoreResults(outputFile,'Quan', headings, SSQResults, DFTQResults, SVDQResults, DWTQResults)
        clear headings;
    end
    
        %% Frame Blending
    if (tBlend)
        fprintf ('Blend time!\n');
        blend = blendStart;
        iteration = 1;

        while (blend <= blendEnd)
        headings(1,iteration) = blend;
        
        clear H
        H(:,:,1:blend) = (1/blend);

           %% Blend SS
            SSAttackedWMYBlock = imfilter(SSWMYBlock,H,'circular');

            % Extract
            extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SS:\t%d bit errors with BER of %3.2f with %3.2f blend.\n', errorBitCount, BER, blend);

            % Store results in memory
            SSBlendResults(runNumber,iteration) = BER;


           %% Blend SVD
           SVDAttackedWMYBlock = imfilter(SVDWMYBlock,H,'circular');
            % Extract
            extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('SVD:\t%d bit errors with BER of %3.2f with %3.2f blend.\n', errorBitCount, BER, blend);

            % Store results in memory
            SVDBlendResults(runNumber,iteration) = BER;

            %% Blend DFT
            DFTAttackedWMYBlock = imfilter(DFTWMYBlock,H,'circular');

            % Extract
            extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DFT:\t%d bit errors with BER of %3.2f with %3.2f blend.\n', errorBitCount, BER, blend);


            % Store results in memory
            DFTBlendResults(runNumber,iteration) = BER;

            %% Blend DWT
            DWTAttackedWMYBlock = imfilter(DWTWMYBlock,H,'circular');
            
            % Extract
            DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
            extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

            % Evaluate
            [errorBitCount, BER] = GetBER(WMInput,extractedWM);
            fprintf ('DWT:\t%d bit errors with BER of %3.2f with %3.2f blend.\n', errorBitCount, BER, blend);


            % Store results in memory
            DWTBlendResults(runNumber,iteration) = BER;

            blend = blend + 1;
            iteration = iteration + 1;

            if (verbose)
            imshow (DFTAttackedWMYBlock(:,:,1));
            pause (0.1);
            end

        end

        % Write Scale A results to file
        StoreResults(outputFile,'Blend', headings, SSBlendResults, DFTBlendResults, SVDBlendResults, DWTBlendResults)
        clear headings;
    end
    
    %% Test Cascading
    %% Create a function to embed a 3D DFT watermark using the alternative Gold code.
    if (tCascade)
        fprintf ('Cascade time!\n');   
        i = 1;
        cascade = cascadeStart;
        
        SSAttackedWMYBlock = SSWMYBlock;
        DFTAttackedWMYBlock = DFTWMYBlock;
        SVDAttackedWMYBlock = SVDWMYBlock;
        DWTAttackedWMYBlock = DWTWMYBlock;
        
        
        
        %% Generate Gold code
        GoldLength = 657744;
        G2 = int8(ones(GoldLength,length(WMInput)));

        
        seed2 = rng;
        
        % Filter
        while (cascade <=  cascadeEnd)

        WMInput2 = round(rand(1,WMLength)); 
        WMInput2 = round(rand(1,WMLength)); 
        
        
        %% Generate Gold code
        j = length (WMInput);
        i = 1;
        GoldObject = comm.GoldSequence('Index', 1, 'SamplesPerFrame', GoldLength, 'FirstPolynomial', [20 18 14 13 8 2 0], 'FirstInitialConditions', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'SecondPolynomial', [20 16 11 6 2 0], 'SecondInitialConditions', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);                   

        while (i <= j)   
            G2(:,i) = int8(step(GoldObject));
            i = i+1;
        end
     
   
        %% Embed all the watermaks
        SSAttackedWMYBlock = Hartung1998Embed(SSAttackedWMYBlock, WMInput2, SSIntensity, seed2);
        SVDAttackedWMYBlock = Kong2006Embed(SVDAttackedWMYBlock, WMInput2, smallestS, SVDIntensity);
        [DFTAttackedWMYBlock, G2] = Deguillaume1999Embed2(DFTAttackedWMYBlock, WMInput2, rmin, rmax, padInner, padOuter, DFTintensity,G2);
  
        DWTAttackedWMYBlock = Inoue2000Embed(DWTAttackedWMYBlock(1:1072, 1:1920, 1:end), WMInput2, T, Q );
        DWTAttackedWMYBlock(1073:1080, 1:1920, 1:end) = YBlock(1073:1080, 1:1920, 1:end);

        headings(1 ,i) = cascade;

        % Extract SS
        extractedWM = Hartung1998Extract(SSAttackedWMYBlock, WMLength, seed);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SS:\t%d bit errors with BER of %3.2f at cascade %3.2f.\n', errorBitCount, BER, cascade);

        % Store results in memory
        SSCascadeResults(runNumber,i) = BER;

        % Extract SVD
        extractedWM = Kong2006Extract(SVDAttackedWMYBlock,WMLength, smallestS);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('SVD:\t%d bit errors with BER of %3.2f at cascade %3.2f.\n', errorBitCount, BER, cascade);

        % Store results in memory
        SVDCascadeResults(runNumber,i) = BER;

        % Extract
        extractedWM = Deguillaume1999Extract(DFTAttackedWMYBlock, WMLength,rmin, rmax, padInner, padOuter, G);

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DFT:\t%d bit errors with BER of %3.2f at cascade %3.2f.\n', errorBitCount, BER, cascade);

        % Store results in memory
        DFTCascadeResults(runNumber,i) = BER;

        % Extract
        DWTAttackedWMYBlock = DWTAttackedWMYBlock(1:1072, 1:1920, 1:end);
        extractedWM = Inoue2000Extract(DWTAttackedWMYBlock, WMLength, T, Q); 

        % Evaluate
        [errorBitCount, BER] = GetBER(WMInput,extractedWM);
        fprintf ('DWT:\t%d bit errors with BER of %3.2f at cascade %3.2f.\n', errorBitCount, BER, cascade);

        % Store results in memory
        DWTCascadeResults(runNumber,i) = BER;

        cascade = cascade + cascadeStep;
        i = i + 1;

        if (verbose)
        imshow (DFTAttackedWMYBlock(:,:,1));
        pause (0.1);

        end

        end


        % Write cascade results to file
        StoreResults(outputFile,'Cascade', headings, SSCascadeResults, DFTCascadeResults, SVDCascadeResults, DWTCascadeResults)
        clear headings;

    end
    
    

    %% Evaluate Quality
    if (tQual)
        % SS
        PSNR = GetPSNR(YBlock, SSWMYBlock);
        bottomSSIM = BottomSSIM (YBlock, SSWMYBlock, 400);
        flicker = FlickerMetric(YBlock, SSWMYBlock);

        SSQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength ,1) = PSNR;
        SSQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,2) = bottomSSIM;
        SSQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,3) = bottomSSIM;
        SSQualResults((runNumber - 1)*(blockLength-1) + 1:runNumber*(blockLength-1),4)= flicker;

        %% DFT
        PSNR = GetPSNR(YBlock, DFTWMYBlock);
        bottomSSIM = BottomSSIM (YBlock, DFTWMYBlock, 400);
        flicker = FlickerMetric(YBlock, DFTWMYBlock);

        DFTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength ,1) = PSNR;
        DFTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,2) = bottomSSIM;
        DFTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,3) = bottomSSIM;
        DFTQualResults((runNumber - 1)*(blockLength-1) + 1:runNumber*(blockLength-1),4)= flicker;


        %% SVD
        PSNR = GetPSNR(YBlock, SVDWMYBlock);
        bottomSSIM = BottomSSIM (YBlock, SVDWMYBlock, 400);
        flicker = FlickerMetric(YBlock, SVDWMYBlock);

        SVDQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength ,1) = PSNR;
        SVDQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,2) = bottomSSIM;
        SVDQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,3) = bottomSSIM;
        SVDQualResults((runNumber - 1)*(blockLength-1) + 1:runNumber*(blockLength-1),4)= flicker;


        %% DWT
        PSNR = GetPSNR(YBlock, DWTWMYBlock);
        bottomSSIM = BottomSSIM (YBlock, DWTWMYBlock, 400);
        flicker = FlickerMetric(YBlock, DWTWMYBlock);
        
        DWTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength ,1) = PSNR;
        DWTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,2) = bottomSSIM;
        DWTQualResults((runNumber - 1)*blockLength + 1:runNumber*blockLength,3) = bottomSSIM;
        DWTQualResults((runNumber - 1)*(blockLength-1) + 1:runNumber*(blockLength-1),4)= flicker;

        StoreResults(outputFile,'Quality', 'PSSF', SSQualResults, DFTQualResults, SVDQualResults, DWTQualResults)
        
        dlmwrite (outputFile, 'SS Qual', '-append');
        dlmwrite (outputFile, SSQualResults, '-append');
        dlmwrite (outputFile, 'DFT Qual', '-append');
        dlmwrite (outputFile, DFTQualResults, '-append');
        dlmwrite (outputFile, 'SVD Qual', '-append');
        dlmwrite (outputFile, SVDQualResults, '-append');
        dlmwrite (outputFile, 'DWT Qual', '-append');
        dlmwrite (outputFile, DWTQualResults, '-append');
        
        dlmwrite (outputFile, '-------------', '-append');
        
        

        clear headings;
    end
    
    %% Increment stuff
    runNumber = runNumber + 1;

toc
end
%To email results
% [~, machineID] = system('hostname');
% setpref('Internet','SMTP_Server','<your mailserver>');
% setpref('Internet','E_mail',strcat(machineID,'<your domain>'));
% sendmail('<FromAddress>', 'Results are ready!',strcat('Here are your results for ',emailMessage), outputFile);