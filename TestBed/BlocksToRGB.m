% -------------------------------------------------
% BlocksToRGB
% -------------------------------------------------
% 
% Support function for TestBed.m
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


function [WMRGBBlock] = BlocksToRGB(WMYBlock, YCbCrBlock)

currentFrameInBlock = 1;
blockLength = size (WMYBlock,3);
WMRGBBlock = zeros (size (YCbCrBlock));

while (currentFrameInBlock <= blockLength) % was (currentFrameInBlock - offset <= blockLength)
            
    %Create video blocks
    WMYFrame(:,:,1) = WMYBlock(:,:,currentFrameInBlock);
    WMYFrame(:,:,2) = YCbCrBlock(:,:,(currentFrameInBlock - 1) * 3 + 2);
    WMYFrame(:,:,3) = YCbCrBlock(:,:,(currentFrameInBlock - 1) * 3 + 3);
    
    %Colour space conversion
    WMRGBFrame = ycbcr2rgb(WMYFrame);
        
    WMRGBBlock(:,:,(currentFrameInBlock - 1) * 3 + 1) = WMRGBFrame(:,:,1);
    WMRGBBlock(:,:,(currentFrameInBlock - 1) * 3 + 2) = WMRGBFrame(:,:,2);
    WMRGBBlock(:,:,(currentFrameInBlock - 1) * 3 + 3) = WMRGBFrame(:,:,3);
    
    currentFrameInBlock = currentFrameInBlock + 1;
      
end