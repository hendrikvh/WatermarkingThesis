% -------------------------------------------------
% TimeFast.m
% -------------------------------------------------
% 
% Evaluates computational complexity of Fast Discrete Fourier Transform Technique.
% Discussed in Chapter 6 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

i = 1;

while (i<=15)

    tic
    [Fast, G] = FastDeguillaume1999Embed(YBlock, WMInput, rmin, rmax, padInner, padOuter, DFTintensity);
    embedTime(i) = toc

    tic
    extractedWM = FastDeguillaume1999Extract(Fast, WMLength, rmin, rmax, padInner, padOuter, G);
    extractTime(i) = toc
    
    i = i+1;
end