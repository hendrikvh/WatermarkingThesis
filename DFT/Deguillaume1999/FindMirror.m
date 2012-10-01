% -------------------------------------------------
% FindMirror
% -------------------------------------------------
% 
% Support function for Deguillaume1999Embed and Deguillaume1999Embed
%
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
%
% -------------------------------------------------

function [mirrorCoordinates] = FindMirror(dimensions, originalIndexes)

offset = [1 1 1]; % In our case the offset is [1 1 1] to compensate for DC

newDims = (dimensions - offset);

middle = ceil(newDims / 2);

i = 1;
j = length(originalIndexes);

%% Convert from index to subscript
[I,J,K] = ind2sub(dimensions,originalIndexes);

originalCoordinates = [I J K];

originalCoordinates = originalCoordinates - 1;

mirrorCoordinates = zeros (size(originalCoordinates));

while (i <= j)

    %% Get mirror y
    if (originalCoordinates(i,1) <= middle(1))
        mirrorCoordinates(i,1) = middle(1) + (middle(1) - originalCoordinates(i,1));
    else
        mirrorCoordinates(i,1) = middle(1) - (originalCoordinates(i,1) - middle(1));
    end
% mirrorCoordinates(i,1) = originalCoordinates(i,1);

    %% Get mirror x
    if (originalCoordinates(2) <= middle(2))
        mirrorCoordinates(i,2) = middle(2) + (middle(2) - originalCoordinates(i,2));
    else
        mirrorCoordinates(i,2) = middle(2) - (originalCoordinates(i,2) - middle(2));
    end
    
    %% Get mirror z
    if (originalCoordinates(3) <= middle(3))
        mirrorCoordinates(i,3) = middle(3) + (middle(3) - originalCoordinates(i,3));
    else
        mirrorCoordinates(i,3) = middle(3) - (originalCoordinates(i,3) - middle(3));
    end
    
    i = i + 1;
    
end

 mirrorCoordinates =  mirrorCoordinates + 1;

%%Convert back to linear indexing

mirrorCoordinates = sub2ind(dimensions, mirrorCoordinates(1:size(originalCoordinates,1),1), mirrorCoordinates(1:size(originalCoordinates,1), 2),mirrorCoordinates(1:size(originalCoordinates,1), 3));
    
    