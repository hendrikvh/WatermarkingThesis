% -------------------------------------------------
% WMFromVideo
% -------------------------------------------------
% 
% Extracts watmermark from video and calculates the BER
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


% %Start clean
% clear all;
% close all;
 clc;

%% Config
inputVideo = '~/Media2/Compression/500/';
offset = 0; %to start reading at offset+1 frames instead of frame 1
WMLength = 80; % Number of bits to extract

emailMessage = '500  2 pass';

outputFile = 'CompressionResults';
outputFile = strcat(outputFile, num2str(WMLength), date, '.csv');

blockLength = 16;
framesToWM = blockLength*28;

% SS Setup
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
DFTintensity = 8.3;
%DFTintensity = 270000;

% DWT Setup
T = 100;
Q = 31;
%Q = 9000;



%% Housekeeping
currentFrameInVideo = offset + 1;
seed = rng;
techniqueRun = 1;
runNumber = 1;

% load ('~/Media3/WMInputs', 'WMInputs');
% load ('~/Media3/seeds', 'seeds');
% load ('~/Media3/G', 'G');
% load ('~/Media3/SSWMInputs', 'SSWMInputs');
% load ('~/Media3/SVDWMInputs', 'SVDWMInputs');
% load ('~/Media3/DFTWMInputs', 'DFTWMInputs');
% load ('~/Media3/DWTWMInputs', 'DWTWMInputs');
dlmwrite (outputFile, runNumber);
fprintf ('Run number %d for technique %d.\n',runNumber,techniqueRun);

load ('WMInput.mat');

    while (techniqueRun <= 4)
        specificInputVideo = strcat(inputVideo, num2str(techniqueRun), '.m4v');
        
        while (currentFrameInVideo <= framesToWM)
            
       
           [WMYBlock2 ~] = MakeVideoBlock(specificInputVideo,blockLength,currentFrameInVideo);

            % Extract WM
            switch techniqueRun
               case 1
                    %WMInput(1,1:80) = SSWMInputs(runNumber,:);
                    seed = seeds(runNumber);
                    extractedWM = Hartung1998Extract(WMYBlock2, WMLength, seed);
                    [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                    SSResults(runNumber,1) = BER;
                    fprintf ('SS:\t%d bit errors with BER of %3.2f.\n', errorBitCount, BER);

               case 2
                   % WMInput(1,1:80) = SVDWMInputs(runNumber,:);
                    extractedWM = Kong2006Extract(WMYBlock2,WMLength, smallestS);
                    [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                    SVDResults(runNumber,1) = BER;
                    fprintf ('SVD:\t%d bit errors with BER of %3.2f.\n', errorBitCount, BER);

               case 3
                   % WMInput(1,1:80) = DFTWMInputs(runNumber,:);
                    extractedWM = Deguillaume1999Extract(WMYBlock2, WMLength, rmin, rmax, padInner, padOuter, G);
                    [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                    DFTResults(runNumber,1) = BER; %#ok<*SAGROW>
                    fprintf ('DFT:\t%d bit errors with BER of %3.2f.\n', errorBitCount, BER);

               case 4
                   % WMInput(1,1:80) = DWTWMInputs(runNumber,:);
                    extractedWM = Inoue2000Extract(WMYBlock2(1:1072, 1:1920, 1:end), WMLength, T, Q);
                    [errorBitCount, BER] = GetBER(WMInput,extractedWM);
                    DWTResults(runNumber,1) = BER;
                    fprintf ('DWT:\t%d bit errors with BER of %3.2f.\n', errorBitCount, BER);
            end
            currentFrameInVideo = currentFrameInVideo + blockLength;
            runNumber = runNumber + 1;
        end
        techniqueRun = techniqueRun + 1;
        currentFrameInVideo = offset + 1;
        runNumber = 1;
    end
    
 headings = 'N';
 StoreResults(outputFile,'Comp', headings, SSResults, DFTResults, SVDResults, DWTResults)
 
 
% To email results 
% [~, machineID] = system('hostname');
% setpref('Internet','SMTP_Server','<your mailserver>');
% setpref('Internet','E_mail',strcat(machineID,'<your domain>'));
% sendmail('<fromAddress>', 'Results are ready!',strcat('Here are your results for ',emailMessage), outputFile);
