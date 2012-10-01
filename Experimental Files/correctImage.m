function [correctedImage] = correctImage(refImage,inputImage)

%Attack
%inputImage = imrotate (refImage, 20,'bilinear', 'loose');
%
%Resize
inputImage = imresize(inputImage, [size(refImage)],'nearest');


%%
%Rotation detection

%Send center chunks of 500x500
centerY = size(refImage,1)/2;
centerX = size(refImage,2)/2;
refImageToSend = refImage ( floor((centerY - 249)) : floor((centerY + 250)), floor((centerX - 249)) : floor((centerX + 250)) );
inputImageToSend = inputImage ( floor((centerY - 249)) : floor((centerY + 250)), floor((centerX - 249)) : floor((centerX + 250)) );

rotation = round(RegisterImage(refImageToSend, inputImageToSend));
fprintf ('Rotation = %d.\n', rotation);
if (rotation > 0)
    correctedImage = imrotate(inputImage, -rotation, 'bilinear', 'loose');

    %angle = RadonRotate(refImageToSend, inputImageToSend);

    % translatedImage = TranslateImage(correctedImage, 4, 2);
    % imshow (correctedImage);
    % imshow (translatedImage);

    %%
    %Find center
    centerY = size(correctedImage,1)/2;
    centerX = size(correctedImage,2)/2;

    %Crop image
    requiredSize = size (refImage);
    correctedImage = correctedImage( floor((centerY - requiredSize(1)/2 +1)) : floor((centerY + requiredSize(1)/2)), floor((centerX - requiredSize(2)/2 +1)) : floor((centerX + requiredSize(2)/2)) );

else
    correctedImage = inputImage;
end