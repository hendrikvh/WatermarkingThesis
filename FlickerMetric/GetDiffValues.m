% -------------------------------------------------
% GetDiffValues
% -------------------------------------------------
% 
% Support function for FlickerMetric
% Discussed in Chapter 4 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

diff = abs(DWTWMYBlock(:,:,1) - YBlock(:,:,1));
diffdValues = reshape(diff,1,[]);
count = size(diffdValues,1);
meanVals = mean(diffdValues);
minVals = min(diffdValues);
maxVals = max(diffdValues);

results = [meanVals minVals maxVals]