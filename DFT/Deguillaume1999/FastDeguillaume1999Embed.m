% -------------------------------------------------
% FastDeguillaume1999Embed
% -------------------------------------------------
% 
% Fast implementation of embedding stage of 3D DFT watermarking technique. 
% See
% Deguillaume, F.: Robust 3D DFT video watermarking. In: Proceedings of SPIE, vol. 3657, pp. 113?124. SPIE, 1999. ISSN 0277786X.
% Available at: http://link.aip.org/link/?PSI/3657/113/1&Agg=doi
%
% Fast technique is described in Chapter 6 of the thesis at: http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------


function [WMYBlockFast, G] = FastDeguillaume1999Embed(YBlock, WMInput, rmin, rmax, padInner, padOuter, intensity)
tic
% Convert WM to correct format
WMInput = (WMInput * 2 - 1)';

%Indexing
%% Read frame to get dimensions etc
dims = size(YBlock);

targetSize = [size(YBlock,1)/2 size(YBlock,2)/2 16]; %Target size for WM embedding. 16 frames hardcoded.
YBlockSmall = imresize(YBlock,[targetSize(1), targetSize(2)]);


%% Generate Gold code
%%Find out what goldLength should be
selectedIndexes = GetAnnalus(rmin,rmax,padInner,padOuter,targetSize);
GoldLength = length(selectedIndexes)/2;
G = int8(ones(GoldLength,length(WMInput)));

%% Generate Gold code
j = length (WMInput);
i = 1;
GoldObject = comm.GoldSequence('Index', 1, 'SamplesPerFrame', GoldLength, 'FirstPolynomial', [20 16 14 13 8 2 0], 'FirstInitialConditions', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'SecondPolynomial', [20 14 11 6 2 0], 'SecondInitialConditions', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);                

while (i <= j)   
    G(:,i) = int8(step(GoldObject));
    i = i+1;
end


%% Generate watermark
w = double(G * 2 - 1) * WMInput;

%Noramlise the watermark magnitude so it is independent of WMLength
%w = w/max(abs(w));

%% Generate pair-wise watermark sequence
i = 1;
p = w;
while (i <= GoldLength)
    if (p(i) >= 0)
        p(i,1) = p(i);
        p(i,2) = 0;
    else
        p(i,2) = p(i,1) * -1;
        p(i,1) = 0;
        
    end
    i = i + 1;
end

%Get coeffs to add to
%selectedIndexes = GetAnnalus(rmin,rmax,dmin,dims);
selectedMirrorIndexes = FindMirror(targetSize , selectedIndexes);

%% FFT
YFFT = fftn(YBlockSmall,targetSize);
YFFT = fftshift(YFFT);


%% Add watermark to coeffs
% Now p WM to YFFT
i = 1;
k = 1;
j = size(p,1);

while (k < j)
    
    % Embed original
    v = YFFT(selectedIndexes(i));
    u = v / abs(v);
    vprime = v + p(k,1) * u * intensity;
    YFFT(selectedIndexes(i)) = vprime; %embed original
    
    % Embed mirror
    v = YFFT(selectedMirrorIndexes(i));
    u = v / abs(v);
    vprime = v + p(k,1) * u * intensity;
    YFFT(selectedMirrorIndexes(i)) = vprime; %embed mirror
    
    % Embed second part of pair
    v = YFFT(selectedIndexes(i+1));
    u = v / abs(v);
    vprime = v + p(k,2) * u * intensity;
    YFFT(selectedIndexes(i+1)) = vprime;
    
    % Embed second part of pair mirror
    v = YFFT(selectedMirrorIndexes(i+1));
    u = v / abs(v);
    vprime = v + p(k,2)*u * intensity;
    YFFT(selectedMirrorIndexes(i+1)) = vprime;

    i = i + 2;
    k = k + 1;
end


%% Inverse FFT
YFFT = ifftshift(YFFT);
WMYBlock = ifftn(YFFT);

diffBlock = WMYBlock - YBlockSmall;

WMYBlockFast = YBlock + imresize(diffBlock,[size(YBlock,1) size(YBlock,2)]);

toc

%% Now add this to the original




