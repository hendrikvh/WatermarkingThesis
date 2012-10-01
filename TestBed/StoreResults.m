% -------------------------------------------------
% StoreResults
% -------------------------------------------------
% 
% Writes results obtained by Testbed.m to .csv file.
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [] = StoreResults(outputFile,name,headings,SS,DFT,SVD,DWT)

dlmwrite (outputFile, strcat(name,'Mean'), '-append');
dlmwrite (outputFile, headings, '-append');
dlmwrite (outputFile, mean(SS), '-append');
dlmwrite (outputFile, mean(DFT), '-append');
dlmwrite (outputFile, mean(SVD), '-append');
dlmwrite (outputFile, mean(DWT), '-append');
dlmwrite (outputFile, '-------------', '-append');

dlmwrite (outputFile, strcat(name,'Min'), '-append');
dlmwrite (outputFile, headings, '-append');
dlmwrite (outputFile, min(SS), '-append');
dlmwrite (outputFile, min(DFT), '-append');
dlmwrite (outputFile, min(SVD), '-append');
dlmwrite (outputFile, min(DWT), '-append');
dlmwrite (outputFile, '-------------', '-append');

dlmwrite (outputFile, strcat(name,'Max'), '-append');
dlmwrite (outputFile, headings, '-append');
dlmwrite (outputFile, max(SS), '-append');
dlmwrite (outputFile, max(DFT), '-append');
dlmwrite (outputFile, max(SVD), '-append');
dlmwrite (outputFile, max(DWT), '-append');
dlmwrite (outputFile, '-------------', '-append');

dlmwrite (outputFile, strcat(name,'StdDev'), '-append');
dlmwrite (outputFile, headings, '-append');
dlmwrite (outputFile, std(SS), '-append');
dlmwrite (outputFile, std(DFT), '-append');
dlmwrite (outputFile, std(SVD), '-append');
dlmwrite (outputFile, std(DWT), '-append');
dlmwrite (outputFile, '-------------', '-append');