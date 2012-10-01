% -------------------------------------------------
% Hartung1998Embed
% -------------------------------------------------
% 
% Embedding stage of spatial domain watermarking technique. 
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

function [WMYBlock] = Hartung1998Embed(YBlock, WMInput, alphai, seed)

% Convert WM to correct format
WMInput = WMInput * 2 - 1;

% Determine CR
WMLength = length(WMInput);
cr = floor(( size(YBlock,1) * size(YBlock,2) * size(YBlock,3) ) / WMLength);

%Indexing
currentFrame = 1;

%Initial Calculations
chippedWMLength = cr * size(WMInput,2); %Get length of complete WM
framesRequired = size(YBlock, 3);
WMYBlock = ones(size(YBlock));

%%
% Generate Watermark
%Chip
inputLength = size (WMInput , 2); %Get length of WM
j = 0;
b = ones(1,chippedWMLength);
while (j<inputLength) %step deur WM
    i = j*cr;
    while (  (i >= (j*cr)) && (i < (j+1)*cr ) )
        b(i+1) = WMInput(j+1);
        i = i+1;
    end
    j = j+1;
end

% Amplify & Modulate with PN sequence
rng(seed);
%PN = randi([0 2],[1 size(b, 2)]) - 1;
PN = rand([1 size(b, 2)]) * 2 - 1;
PN = double(PN);

w = alphai * b .* PN;

%%
%%Get frames and start WM'ing
WMIndex = 1;

%Watermark each frame
while (currentFrame <= framesRequired)
    
    %Get video frame & line scan video frame
    %fprintf ('Frame number %d\n', currentFrame);
    %Read single frame & display original frame
    
    YFrame = YBlock(:,:,currentFrame);

    %Line scan luma frame
    lumaLine = reshape (YFrame',1, []);

    %%
    %Add wm
    
    % Pre-allocate
    %How much WM needs to be added to this lumaline of frame?
    WMLeftToEmbed = length(w) - WMIndex + 1;
    if (WMLeftToEmbed > (size(YFrame,1)*size(YFrame,2)) )
        WMLeftToEmbed = (size(YFrame,1)*size(YFrame,2)); %We can only embed a full frame
    end
     
    %Add that to lumaline
    lumaLine(1: WMLeftToEmbed) = double (lumaLine(1: WMLeftToEmbed)) + w(WMIndex: WMIndex + WMLeftToEmbed-1);
    WMIndex = WMIndex + WMLeftToEmbed;

    %unscan WM 
    WMFrame = reshape (lumaLine,size(YBlock,2),size(YBlock,1))';
    
    WMYBlock(:,:,currentFrame)= WMFrame;
  
    currentFrame = currentFrame + 1 ;
      
end

WMYBlock(WMYBlock < 0) = 0;
WMYBlock(WMYBlock > 1) = 1;
