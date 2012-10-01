function [completeFeatures] = GetFeatures(inputImage)

%Split the colour image into an intensity + colour space 

YCFrame = rgb2ycbcr (inputImage);

%Get histogram & normalise
pixelcount = size(inputImage,1)*size(inputImage,2);
hist1 = imhist(YCFrame(:,:,1),16)/pixelcount;
hist2 = imhist(YCFrame(:,:,2),16)/pixelcount;
hist3 = imhist(YCFrame(:,:,3),16)/pixelcount;

%Get features with Laws
featuresY = laws (YCFrame (:,:,1));
featuresCb = laws (YCFrame (:,:,2));
featuresCr = laws (YCFrame (:,:,3));

%Concat all features
completeFeatures = [hist1 hist2 hist3 featuresY featuresCb featuresCr];

%Euclidian distance

end