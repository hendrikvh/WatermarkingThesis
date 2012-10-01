% -------------------------------------------------
% FastDeguillaume1999Extract
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

function [extractedWM] = FastDeguillaume1999Extract(WMYBlock, WMLength, rmin, rmax, padInner, padOuter, G)

targetSize = [size(WMYBlock,1)/2 size(WMYBlock,2)/2 16]; %Target size for WM embedding. 16 frames hardcoded.
WMYBlock = imresize(WMYBlock,[targetSize(1) targetSize(2)]);

%% FFT
YFFT = fftn(WMYBlock,targetSize);
YFFT = fftshift(YFFT);

dims = size (WMYBlock);

%% Get N pair-wise coeffs from selectedIndexes
selectedIndexes = GetAnnalus(rmin,rmax,padInner, padOuter,targetSize);

%% Get difference between pair-wise coeffs
wPrime = ones(1,length(selectedIndexes)/2);
j = length(selectedIndexes);
i = 1;
k = 1;

%preallocate wPrime later
while (i < j)
    wPrime(k) = abs(YFFT(selectedIndexes(i))) - abs(YFFT(selectedIndexes(i+1)));
    %wPrime = abs(YFFT(oddIndexes)) - abs(YFFT(evenIndexes));
    i = i + 2;
    k = k + 1;
end

%%Extract bit
i = 1;
j = WMLength;
BPrime = ones(1, WMLength);


while(i <= j)
    GTemp = G(:,i)';
    BPrime(i) = dot(wPrime,double(GTemp));

    i = i + 1;

end

extractedWM = sign(BPrime);
extractedWM(extractedWM<0) = 0;