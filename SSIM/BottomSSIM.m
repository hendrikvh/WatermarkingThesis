% -------------------------------------------------
% BottomSSIM
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

function [bottomSSIM] = BottomSSIM (YBlock, WMYBlock, number)

K = [0.01 0.03];
window = fspecial('gaussian', 11, 1.5);
L = 1;
i = 1;

%% Work frame by frame
while (i <= size(YBlock,3))
    %Get SSIM for frame
    [~, SSIMMap] = ssim(YBlock(:,:,i), WMYBlock(:,:,i),K, window, L);
    % [~, SSIMMap] = ssim_index(YBlock(:,:,i), WMYBlock(:,:,i),K, window, L);
    
    % Sort and take bottom few SSIM windows
    B = reshape (SSIMMap, 1, []);
    B = sort (B,'ascend');
    bottomSSIM(i) = mean(B(1:number));
    
%     weights = ones(size(B));
%     weights(1:number) = 8000;
    
%    bottomSSIM(i) = wmean(B,weights);
    
    
    %Increment
    i = i + 1;
end