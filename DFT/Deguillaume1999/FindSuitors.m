% -------------------------------------------------
% FindSuitor
% -------------------------------------------------
% 
% Support function for Deguillaume1999Embed and Deguillaume1999Embed
%
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012

% -------------------------------------------------

function [suitors] = FindSuitors(dimensions)

%% For now we just return half of the coeffs in 2D
coeffNumbers = dimensions(1) * dimensions(2);
suitors = (1:coeffNumbers/2)';
%suitors = suitors(mod(suitors,2)~=0);
numberOfSuitors = size (suitors, 1);
fprintf ('%d suitable coeffs found\n', numberOfSuitors);
