%clc
close all;
%refImage = imread ('Lena.png');
refImage = imread ('Sony.png');

%To YCbCr
refImage = im2uint8(rgb2ycbcr (refImage));
refImage = refImage(:,:,1);

%Attack
testImage = imrotate (refImage, 20,'bilinear', 'loose');


%%
%Rotation detection

%Send center chunks of 500x500
centerY = size(refImage,1)/2;
centerX = size(refImage,2)/2;
refImageToSend = refImage ( floor((centerY - 249)) : floor((centerY + 250)), floor((centerX - 249)) : floor((centerX + 250)) );
testImageToSend = testImage ( floor((centerY - 249)) : floor((centerY + 250)), floor((centerX - 249)) : floor((centerX + 250)) );

rotation = round(RegisterImage(refImageToSend, testImageToSend))
correctedImage = imrotate(testImage, -rotation, 'bilinear', 'loose');
imshow (correctedImage);
figure;

%angle = RadonRotate(refImageToSend, testImageToSend);

% translatedImage = TranslateImage(correctedImage, 4, 2);
% imshow (correctedImage);
% imshow (translatedImage);

%%
%Find center
centerY = size(correctedImage,1)/2;
centerX = size(correctedImage,2)/2;

%Crop image
requiredSize = size (refImage);
croppedImage = correctedImage( floor((centerY - requiredSize(1)/2 +1)) : floor((centerY + requiredSize(1)/2)), floor((centerX - requiredSize(2)/2 +1)) : floor((centerX + requiredSize(2)/2)) );
imshow (croppedImage);