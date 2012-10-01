% -------------------------------------------------
% FlickerMetric
% -------------------------------------------------
% 
% Newly developed function to evaluaue interframe flicker in watermarked
% video sequences.
% Discussed in Chapter 4 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [flickerValues flickerBlock] = FlickerMetric (YBlock, WMYBlock) 

steps = size(YBlock,3) - 1;
i = 1;

%flickerValues = 100*ones(1,size(YBlock,3) - 1);
%flickerBlock = 100*ones(size(YBlock,1),size(YBlock,2),steps*3,steps);

h = fspecial('average',2);
%j = 1;

while (i <= steps)
    
    deltaClean = abs (YBlock (:,:,i) - YBlock (:,:,i+1));
    deltaWM = abs (WMYBlock (:,:,i) - WMYBlock (:,:,i+1));
    flickerFrame = abs(deltaWM - (deltaClean));

    % Cluster storie
    C = edge(flickerFrame,'roberts');
    %C = bwmorph (C,'thin');
    
    C = im2double(C);
    C = imfilter (C,h);
    D = imfill(C);
    %D (D>0) = 1;
    %noE = D - C;
    %noE(noE>0) = 1;
    noE = D;
    noE = medfilt2(noE,[5 5]);
    noE(noE>0) = 1;


    % Som
    flickerValues(i) = sum(sum(flickerFrame.*noE));
    %flickerBlock(:,:,i) = (flickerFrame/max(max(flickerFrame))) + 2*noE;
    
    RGBFrame(:,:,1) = flickerFrame/max(max(flickerFrame));
    RGBFrame(:,:,2) = noE;
    RGBFrame(:,:,3) = 0;
    
    flickerBlock(:,:,:,i) = RGBFrame;

    fprintf ('Flicker in frame %d to %d is\t%3.2f\n',i, i+1,flickerValues(i));

    i = i + 1;
     
end
