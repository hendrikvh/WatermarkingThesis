% -------------------------------------------------
% GetAnnalus
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

function [annalusIndices] = GetAnnalus(radiusInner,radiusOuter, padInner, padOuter, dimensions)

center = ceil (dimensions(3) / 2);
offset = [1 1]; % In our case the 2D offset is [1 1]

I = zeros (dimensions(1:2) - offset); %Create 2D matrix
I1 = zeros (dimensions(1:2) - offset); %Create 2D matrix
I2 = zeros (dimensions(1:2) - offset); %Create 2D matrix
IBlock = zeros(dimensions(1), dimensions(2), dimensions(3) - 1);

[ny nx] = size(I);
x = linspace(-1,1,nx);
y = linspace(-1,1,ny);
[X Y] = meshgrid(x,y);

I(X.^2+Y.^2<=radiusOuter^2)=1; % logical indexing of the circle centered at (0,0)
I(X.^2+Y.^2<=radiusInner^2)=0;

%Now only take half of the analus
middlexy = floor ( (dimensions(2) - offset) / 2 );
I1(:,middlexy+1:end) = I(:,middlexy+1:end);
I2(:,1:middlexy) = I(:,1:middlexy);
I1 = padarray(I1, offset, 0, 'pre');
I2 = padarray(I2, offset, 0, 'pre');

% Make 3D block
for n = (padOuter + 1):(center - padInner - 1)
   IBlock(:,:,n) = I1; %Left halfcircle
   %fprintf ('At frame %d\n',n);
end

for n = (center + padInner + 1: dimensions(3) - padOuter - 1)
    IBlock(:,:,n) = I2; % Right halfcircle
    %fprintf ('At frame %d\n',n);
end

IBlock = cat(3, zeros(dimensions(1:2)), IBlock);

%imshow (I);
annalusIndices = find(IBlock);
%numberOfSuitors = size (annalusIndices, 1);
%fprintf ('%d suitable coeffs found\n', numberOfSuitors);
