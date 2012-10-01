% -------------------------------------------------
% Timing.m
% -------------------------------------------------
% 
% Evaluates computational complexity of watermarking techniques.
% Discussed in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
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
WMLength = 80; % Number of bits to embed
%inputVideo = '~/Media2/SHM.mov';
inputVideo = '~/Media3/xiph/Aspen_8bit.avi';
blockLength = 16;
runNumbers = 15;
offset = 0; %to start watermarking at offset frames instead of frame 1

% SS Setup
seed = rng;
SSIntensity = 0.86;
%SSIntensity = 0.7;

% SVD setup
smallestS = 9;
%smallestS = 2;
SVDIntensity = 0.3;

% DFT setup
rmin = 0.3;
rmax = 0.6;
padInner = 2;
padOuter = 2;
DFTintensity = 8.8;
%DFTintensity = 270000;

% DWT Setup
T = 100;
Q = 60;
%Q = 9000;

outputFile = 'TimingResults.csv';

%% Start first run
runNumber = 1;
dlmwrite (outputFile, 'Results');
currentFrameInVideo = 1;

%% Embedding

while(runNumber <= runNumbers)
    fprintf ('Run number %d of %d.\n',runNumber, runNumbers);
    
    %% Make video block
    fprintf ('Creating video block starting at frame %d.\n', currentFrameInVideo);
    [YBlock ~] = MakeVideoBlock(inputVideo,blockLength,currentFrameInVideo); % Make block
    currentFrameInVideo = currentFrameInVideo + blockLength;
    WMInput = round(rand(1,WMLength)); 
   
    % Embed all the watermarks for timing purposes
    tic;
    SSWMYBlock = Hartung1998Embed(YBlock, WMInput, SSIntensity, seed);
    SSToc(runNumber) = toc;
    tic;
    SVDWMYBlock = Kong2006Embed(YBlock, WMInput, smallestS, SVDIntensity);
    SVDToc(runNumber) = toc;
    tic
    [DFTWMYBlock, G] = Deguillaume1999Embed(YBlock, WMInput, rmin, rmax, padInner, padOuter, DFTintensity);
    DFTToc(runNumber) = toc;
    tic;
    DWTWMYBlock = Inoue2000Embed(YBlock(1:1072, 1:1920, 1:end), WMInput, T, Q );
    DWTToc(runNumber) = toc;
    
    runNumber = runNumber + 1;
end

  % Write timing results to file
    dlmwrite (outputFile, 'TEmbed', '-append');
    dlmwrite (outputFile, 'M-+', '-append');
    dlmwrite (outputFile, [mean(SSToc) min(SSToc) max(SSToc)], '-append');
    dlmwrite (outputFile, [mean(DFTToc) min(DFTToc) max(DFTToc)], '-append');
    dlmwrite (outputFile, [mean(SVDToc), min(SVDToc) max(SVDToc)], '-append');
    dlmwrite (outputFile, [mean(DWTToc), min(DWTToc) max(DWTToc)], '-append');
 
%% Extraction
runNumber = 1;
while(runNumber <= runNumbers)    
    % Extract all the watermarks for timing purposes
    tic;
    extractedWM = Hartung1998Extract(SSWMYBlock, WMLength, seed);
    SSToc(runNumber) = toc;
    tic;
    extractedWM = Kong2006Extract(SVDWMYBlock,WMLength, smallestS);
    SVDToc(runNumber) = toc;
    tic
    extractedWM = Deguillaume1999Extract(DFTWMYBlock, WMLength, rmin, rmax, padInner, padOuter, G);
    DFTToc(runNumber) = toc;
    tic;
    extractedWM = Inoue2000Extract(DWTWMYBlock, WMLength, T, Q);
    DWTToc(runNumber) = toc;
    
    runNumber = runNumber + 1;
end

  % Write timing results to file
    dlmwrite (outputFile, 'TExract', '-append');
    dlmwrite (outputFile, 'M-+', '-append');
    dlmwrite (outputFile, [mean(SSToc) min(SSToc) max(SSToc)], '-append');
    dlmwrite (outputFile, [mean(DFTToc) min(DFTToc) max(DFTToc)], '-append');
    dlmwrite (outputFile, [mean(SVDToc), min(SVDToc) max(SVDToc)], '-append');
    dlmwrite (outputFile, [mean(DWTToc), min(DWTToc) max(DWTToc)], '-append');
