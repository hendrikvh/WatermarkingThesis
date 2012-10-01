function [features]=laws(inputImage)
%%
%Law's texture measures
L5  =  [  1   4   6   4   1  ];
E5  =  [ -1  -2   0   2   1  ];
S5  =  [ -1   0   2   0  -1  ];
W5  =  [ -1   2   0  -2   1  ];
R5  =  [  1  -4   6  -4   1  ];

%Generate 2D convoluion kernels
 L5L5 = L5'*L5;
 E5L5 = E5'*L5;
 S5L5 = S5'*L5;
 W5L5 = W5'*L5;
 R5L5 = R5'*L5;  
 L5E5 = L5'*E5;
 E5E5 = E5'*E5;
 S5E5 = S5'*E5;
 W5E5 = W5'*E5;
 R5E5 = R5'*E5;  
 L5S5 = L5'*S5;
 E5S5 = E5'*S5;
 S5S5 = S5'*S5;
 W5S5 = W5'*S5;
 R5S5 = R5'*S5; 
 L5W5 = L5'*W5;
 E5W5 = E5'*W5;
 S5W5 = S5'*W5;
 W5W5 = W5'*W5;
 R5W5 = R5'*W5;  
 L5R5 = L5'*R5;
 E5R5 = E5'*R5;
 S5R5 = S5'*R5;
 W5R5 = W5'*R5;
 R5R5 = R5'*R5;
 
 %Apply convolution kernels & abs already for next step
 L5L5 = abs(conv2(inputImage, L5L5));
 E5L5 = abs(conv2(inputImage, E5L5));
 S5L5 = abs(conv2(inputImage, S5L5));
 W5L5 = abs(conv2(inputImage, W5L5));
 R5L5 = abs(conv2(inputImage, R5L5)); 
 L5E5 = abs(conv2(inputImage, L5E5));
 E5E5 = abs(conv2(inputImage, E5E5));
 S5E5 = abs(conv2(inputImage, S5E5));
 W5E5 = abs(conv2(inputImage, W5E5));
 R5E5 = abs(conv2(inputImage, R5E5));  
 L5S5 = abs(conv2(inputImage, L5S5));
 E5S5 = abs(conv2(inputImage, E5S5));
 S5S5 = abs(conv2(inputImage, S5S5));
 W5S5 = abs(conv2(inputImage, W5S5));
 R5S5 = abs(conv2(inputImage, R5S5)); 
 L5W5 = abs(conv2(inputImage, L5W5));
 E5W5 = abs(conv2(inputImage, E5W5));
 S5W5 = abs(conv2(inputImage, S5W5));
 W5W5 = abs(conv2(inputImage, W5W5));
 R5W5 = abs(conv2(inputImage, R5W5));  
 L5R5 = abs(conv2(inputImage, L5R5));
 E5R5 = abs(conv2(inputImage, E5R5));
 S5R5 = abs(conv2(inputImage, S5R5));
 W5R5 = abs(conv2(inputImage, W5R5));
 R5R5 = abs(conv2(inputImage, R5R5));
 
 %Windowing operation
%  FIRFilt = ones (15,15);
%  
%  L5L5 = filter2(FIRFilt, L5L5);
%  E5L5 = filter2(FIRFilt, E5L5);
%  S5L5 = filter2(FIRFilt, S5L5);
%  W5L5 = filter2(FIRFilt, W5L5);
%  R5L5 = filter2(FIRFilt, R5L5);  
%  L5E5 = filter2(FIRFilt, L5E5);
%  E5E5 = filter2(FIRFilt, E5E5);
%  S5E5 = filter2(FIRFilt, S5E5);
%  W5E5 = filter2(FIRFilt, W5E5);
%  R5E5 = filter2(FIRFilt, R5E5); 
%  L5S5 = filter2(FIRFilt, L5S5);
%  E5S5 = filter2(FIRFilt, E5S5);
%  S5S5 = filter2(FIRFilt, S5S5);
%  W5S5 = filter2(FIRFilt, W5S5);
%  R5S5 = filter2(FIRFilt, R5S5);
%  L5W5 = filter2(FIRFilt, L5W5);
%  E5W5 = filter2(FIRFilt, E5W5);
%  S5W5 = filter2(FIRFilt, S5W5);
%  W5W5 = filter2(FIRFilt, W5W5);
%  R5W5 = filter2(FIRFilt, R5W5);  
%  L5R5 = filter2(FIRFilt, L5R5);
%  E5R5 = filter2(FIRFilt, E5R5);
%  S5R5 = filter2(FIRFilt, S5R5);
%  W5R5 = filter2(FIRFilt, W5R5);
%  R5R5 = filter2(FIRFilt, R5R5);
 
% %Normalisation with L5L5
maxL5L5 = max(max(L5L5));

L5L5 = L5L5 / maxL5L5;
E5L5 = E5L5 / maxL5L5;
S5L5 = S5L5 / maxL5L5;
W5L5 = W5L5 / maxL5L5;
R5L5 = R5L5 / maxL5L5; 
L5E5 = L5E5 / maxL5L5;
E5E5 = E5E5 / maxL5L5;
S5E5 = S5E5 / maxL5L5;
W5E5 = W5E5 / maxL5L5;
R5E5 = R5E5 / maxL5L5;
L5S5 = L5S5 / maxL5L5;
E5S5 = E5S5 / maxL5L5;
S5S5 = S5S5 / maxL5L5;
W5S5 = W5S5 / maxL5L5;
R5S5 = R5S5 / maxL5L5;
L5W5 = L5W5 / maxL5L5;
E5W5 = E5W5 / maxL5L5;
S5W5 = S5W5 / maxL5L5;
W5W5 = W5W5 / maxL5L5;
R5W5 = R5W5 / maxL5L5;  
L5R5 = L5R5 / maxL5L5;
E5R5 = E5R5 / maxL5L5;
S5R5 = S5R5 / maxL5L5;
W5R5 = W5R5 / maxL5L5;
R5R5 = R5R5 / maxL5L5;


% %Normalisation only with self to get between 0 & 1
% maxL5L5 = max(max(L5L5));
% 
% L5L5 = L5L5 / max(max(L5L5));
% E5L5 = E5L5 / max(max(E5L5));
% S5L5 = S5L5 / max(max(S5L5));
% W5L5 = W5L5 / max(max(W5L5));
% R5L5 = R5L5 / max(max(R5L5)); 
% L5E5 = L5E5 / max(max(L5E5));
% E5E5 = E5E5 / max(max(E5E5));
% S5E5 = S5E5 / max(max(S5E5));
% W5E5 = W5E5 / max(max(W5E5));
% R5E5 = R5E5 / max(max(R5E5));
% L5S5 = L5S5 / max(max(L5S5));
% E5S5 = E5S5 / max(max(E5S5));
% S5S5 = S5S5 / max(max(S5S5));
% W5S5 = W5S5 / max(max(W5S5));
% R5S5 = R5S5 / max(max(R5S5));
% L5W5 = L5W5 / max(max(L5W5));
% E5W5 = E5W5 / max(max(E5W5));
% S5W5 = S5W5 / max(max(S5W5));
% W5W5 = W5W5 / max(max(W5W5));
% R5W5 = R5W5 / max(max(R5W5));  
% L5R5 = L5R5 / max(max(L5R5));
% E5R5 = E5R5 / max(max(E5R5));
% S5R5 = S5R5 / max(max(S5R5));
% W5R5 = W5R5 / max(max(W5R5));
% R5R5 = R5R5 / max(max(R5R5));

%Combine similar features
E5L5TR   =   E5L5  +  L5E5;
S5L5TR   =   S5L5  +  L5S5;
W5L5TR   =   W5L5  +  L5W5;
R5L5TR   =   R5L5  +  L5R5;
S5E5TR   =   S5E5  +  E5S5;
W5E5TR   =   W5E5  +  E5W5;
R5E5TR   =   R5E5  +  E5R5;
W5S5TR   =   W5S5  +  S5W5;
R5S5TR   =   R5S5  +  S5R5;
R5W5TR   =   R5W5  +  W5R5;

E5E5TR   =   E5E5  *  2;
S5S5TR   =   S5S5  *  2;
W5W5TR   =   W5W5  *  2;
R5R5TR   =   R5R5  *  2;

%Get histograms
pixelcount = (size(E5E5TR,1) * size(E5E5TR,2)); 

E5L5TRHist   =   imhist(E5L5TR,16)/pixelcount;
S5L5TRHist   =   imhist(S5L5TR,16)/pixelcount;
W5L5TRHist   =   imhist(W5L5TR,16)/pixelcount;
R5L5TRHist   =   imhist(R5L5TR,16)/pixelcount;
S5E5TRHist   =   imhist(S5E5TR,16)/pixelcount;
W5E5TRHist   =   imhist(W5E5TR,16)/pixelcount;
R5E5TRHist   =   imhist(R5E5TR,16)/pixelcount;
W5S5TRHist   =   imhist(W5S5TR,16)/pixelcount;
R5S5TRHist   =   imhist(R5S5TR,16)/pixelcount;
R5W5TRHist   =   imhist(R5W5TR,16)/pixelcount;

E5E5TRHist   =   imhist(E5E5TR,16)/pixelcount;
S5S5TRHist   =   imhist(S5S5TR,16)/pixelcount;
W5W5TRHist   =   imhist(W5W5TR,16)/pixelcount;
R5R5TRHist   =   imhist(R5R5TR,16)/pixelcount;

features = [E5L5TRHist S5L5TRHist W5L5TRHist R5L5TRHist  S5E5TRHist  W5E5TRHist R5E5TRHist W5S5TRHist R5S5TRHist R5W5TRHist E5E5TRHist S5S5TRHist W5W5TRHist R5R5TRHist];

end