% -------------------------------------------------
% Hartung1998Extract
% -------------------------------------------------
% 
% Extraction stage of spatial domain watermarking technique. 
% See
% Hartung, F. and Girod, B.: Watermarking of uncompressed and compressed video.
% Signal Processing, vol. 66, no. 3, pp. 283?301, May 1998. ISSN 01651684.
% Available at: http://linkinghub.elsevier.com/retrieve/pii/ S0165168498000115
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [extractedWM] = Hartung1998Extract(WMYBlock, WMLength, seed)

%Recover WM
currentFrame = 1;
lumaLeftOver = [];
WMBitIndex = 1;
WMExtracted = 0;

pixelsInFrame = size(WMYBlock,1) * size (WMYBlock,2);

extractedWM = 5*ones(1,WMLength);

cr = floor(( size(WMYBlock,1) * size(WMYBlock,2) * size(WMYBlock,3) ) / WMLength);
chippedWMLength = cr * WMLength; %Get length of complete WM
b = ones(1,chippedWMLength);

WMChippedLength = WMLength * cr;

rng(seed);
PN = randi([0 2],[1 size(b, 2)]) - 1;
PN = double(PN);

%Extract WM
while (currentFrame <= size(WMYBlock,3))
    %Determine how much WM is left to extract
    %WMLeftOver = WMLength - (WMBitIndex-1)*cr;
    WMLeftOver = WMChippedLength - WMExtracted;
    
    %How much WM is left in THIS FRAME
    WMLeftOver (WMLeftOver > pixelsInFrame) = pixelsInFrame;
    WMExtracted = WMExtracted + WMLeftOver;
       
    WMFrame = WMYBlock(:,:,currentFrame);
    %fprintf ('Extracting frame %d\n',currentFrame);

    % Filter
    h= fspecial('average',3);
    filteredFrame = imfilter (WMFrame, h, 'replicate');
    HPFrame = WMFrame - filteredFrame;
    
    lumaLine = reshape (HPFrame',1, []);
    
    %Multiply concatlumaline with PN sequence
    lumaDemod(1:WMLeftOver) = double(lumaLine(1:WMLeftOver)).*PN((currentFrame-1)*pixelsInFrame + 1:(currentFrame-1)*pixelsInFrame + WMLeftOver);
    
    %Concat lumaLeftOver
    lumaDemodConcat = [ lumaLeftOver,lumaDemod ];
    
    WMBitsInFrame = floor (length(lumaDemod)/cr);
    WMBitIndexForFrame = 1;
    
    %Recover bits
    while (WMBitIndexForFrame <= WMBitsInFrame)
        extractedWM(WMBitIndex) = sum(lumaDemodConcat((WMBitIndexForFrame-1)*cr + 1:( (WMBitIndexForFrame) * cr ) ));
        WMBitIndex = WMBitIndex + 1;
        WMBitIndexForFrame = WMBitIndexForFrame + 1;
    end
    
    lumaLeftOver = lumaDemodConcat ((WMBitIndexForFrame - 1) * cr + 1:length(lumaDemodConcat));
        
    currentFrame = currentFrame + 1;
end
%extractedWM
extractedWM( extractedWM>=0 ) = 1;
extractedWM( extractedWM<0 ) = 0;


end
