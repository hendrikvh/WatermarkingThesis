% -------------------------------------------------
% SSIMCalc
% -------------------------------------------------
% 
% Forms part of spatial quality metric.
% Discussed in Chapter 4 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [SSIM] = SSIMCalc(input)

X = input(:,:,1);
Y = input(:,:,2);

% Get mean intensity
uX = mean(mean(X));
uY = mean(mean(Y));

sigmaSqX = (var(var(X)));
sigmaSqY = (var(var(Y)));

%sigmaXY = cov(cov(X,Y));

sigmaXY = sum(sum((X - uX).*(Y - uY))) / (size(X,1)*size(X,2));

k1 = 0.01;
k2 = 0.03;

L = 1;

C1 = (k1 * L)^2;
C2 = (k2 * L)^2;

SSIM = ( ( (2*uX*uY + C1)*(2*sigmaXY + C2) ) / ( (uX^2 + uY^2 + C1)*(sigmaSqX + sigmaSqY + C2) ) );
