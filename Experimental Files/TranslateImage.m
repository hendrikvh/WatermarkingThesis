function [translatedImage] = TranslateImage(inputImage, x, y)

%xform(3,1) = horizontal shift & xform(3,2) = vertical shift
xform = [ 1  0  0
          0  1  0
          x  y  1 ];
     
tform_translate = maketform('affine',xform);

[translatedImage xdata ydata]= imtransform(inputImage, tform_translate);

cb_trans2 = imtransform(inputImage, tform_translate,...
                        'XData', [1 (size(inputImage,2)+ xform(3,1))],...
                        'YData', [1 (size(inputImage,1)+ xform(3,2))]);
figure, imshow(cb_trans2)



figure, imshow(translatedImage);