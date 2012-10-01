% -------------------------------------------------
% BareTiming
% -------------------------------------------------
% 
% Evaluates computational complexity of mathematical transdorms.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


clear all;
close all;

runNumbers = 15;
inputVideo = '~/Media3/xiph/Aspen_8bit.avi';
blockLength = 16;
WMLength = 80;

%% Start first run
runNumber = 1;
outputFile = 'BareTiming.csv';
dlmwrite (outputFile, 'BareTiming');
currentFrameInVideo = 1;
waveletType = 'db4';

%% Embedding

dlmwrite (outputFile, 'Results');

while(runNumber <= runNumbers)
    fprintf ('Run number %d of %d.\n',runNumber, runNumbers);
    
    %% Make video block
    fprintf ('Creating video block starting at frame %d.\n', currentFrameInVideo);
    [YBlock ~] = MakeVideoBlock(inputVideo,blockLength,currentFrameInVideo); % Make block
    currentFrameInVideo = currentFrameInVideo + blockLength;
    WMInput = round(rand(1,WMLength)); 
   
    % Embed all the watermarks for timing purposes
    SSToc(runNumber) = 0;
    tic;
    [U] = ones(size(YBlock,1),size(YBlock,1),size(YBlock,3));
    [S] = ones(size(YBlock,1),size(YBlock,2),size(YBlock,3));
    [V] = ones(size(YBlock,2),size(YBlock,2),size(YBlock,3));
    
    for (currentFrameInBlock = 1: size(YBlock,3))
        [U(:,:,currentFrameInBlock), S(:,:,currentFrameInBlock), V(:,:,currentFrameInBlock)] = svd (YBlock(:,:,currentFrameInBlock));
    end
    SVDToc(runNumber) = toc;
    tic
    YFFT = fftn(YBlock,size(YBlock));
    DFTToc(runNumber) = toc;
    tic;
      for currentFrameInBlock = 1: size(YBlock,3)
        [LL1,HL1,LH1, HH1] = dwt2(YBlock(1:1072, 1:1920, currentFrameInBlock), waveletType);
        [LL2,HL2,LH2,HH2] = dwt2(LL1, waveletType);
        [LL3,HL3,LH3,HH3] = dwt2(LL2, waveletType);
        [LL4,HL4,LH4,HH4] = dwt2(LL3, waveletType);
      end
        DWTToc(runNumber) = toc;
    
    runNumber = runNumber + 1;
end

  % Write timing results to file
    dlmwrite (outputFile, 'TEmbed', '-append');
    dlmwrite (outputFile, 'AM', '-append');
    dlmwrite (outputFile, [mean(SSToc) max(SSToc)], '-append');
    dlmwrite (outputFile, [mean(DFTToc) max(DFTToc)], '-append');
    dlmwrite (outputFile, [mean(SVDToc), max(SVDToc)], '-append');
    dlmwrite (outputFile, [mean(DWTToc), max(DWTToc)], '-append');
 
%% Extraction
runNumber = 1;
WMYBlock = ones(1072, 1920,size(YBlock,3)); 
while(runNumber <= runNumbers)    
    % Extract all the watermarks for timing purposes
    SSToc(runNumber) = 0;
    tic;
    for (currentFrameInBlock = 1: size(YBlock,3))
        A = U(currentFrameInBlock)*S(currentFrameInBlock)*V(currentFrameInBlock)';
    end
    SVDToc(runNumber) = toc;
    tic
    A = ifftn(YFFT);
    DFTToc(runNumber) = toc;
    tic;
    for currentFrameInBlock = 1: size(YBlock,3)
    LL3 = idwt2(LL4,HL4,LH4,HH4, waveletType);
    LL2 = idwt2(LL3,HL3,LH3,HH3, waveletType);
    LL1 = idwt2(LL2,HL2,LH2,HH2, waveletType);
    WMYBlock(:,:,currentFrameInBlock) = idwt2(LL1,HL1,LH1,HH1, waveletType);
    DWTToc(runNumber) = toc;
    
    end
    runNumber = runNumber + 1;
end

  % Write timing results to file
    dlmwrite (outputFile, 'TExract', '-append');
    dlmwrite (outputFile, 'AM', '-append');
    dlmwrite (outputFile, [mean(SSToc) max(SSToc)], '-append');
    dlmwrite (outputFile, [mean(DFTToc) max(DFTToc)], '-append');
    dlmwrite (outputFile, [mean(SVDToc), max(SVDToc)], '-append');
    dlmwrite (outputFile, [mean(DWTToc), max(DWTToc)], '-append');
