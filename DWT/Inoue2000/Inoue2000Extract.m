% -------------------------------------------------
% Inoue2000Extract
% -------------------------------------------------
% 
% Extraction stage of DWT watermarking technique. 
% See
% Inoue, H., Miyazaki, A., Araki, T. and Katsura, T.:
% A digital watermark method using the wavelet transform for video data.
% In: ISCAS?99. Proceed- ings of the 1999 IEEE International Symposium on Circuits and Systems VLSI,
% vol. 4, pp. 247?250. IEEE, 2000. ISBN 0-7803-5471-0.
% Available at: http://ieeexplore.ieee.org/lpdocs/epic03/wrapper.htm? arnumber=779988
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [extractedWM] = Inoue2000Extract(WMYBlock, WMLength, T, Q)

%% Setup & initialisation
waveletType = 'db4';

R = size(WMYBlock,1)/2^4 * size(WMYBlock,2)/2^4;
S = 2;

WMYBlock = WMYBlock*255;
currentFrame = 1;

bitsPerFrame = WMLength / size(WMYBlock,3);
WMBitIndex = 1;

extractedWM = ones(1,WMLength); %Preallocate
debugCount = 1;

while (currentFrame <= size(WMYBlock,3))
    
    k = 1;
    ri = k;
    tryNumber = 1;

    %% Deconstruct image
    YFrame = WMYBlock(:,:,currentFrame);

    [LL1,~,~, ~] = dwt2(YFrame, waveletType);
    [LL2,~,~,~] = dwt2(LL1, waveletType);
    [LL3,HL3,LH3,~] = dwt2(LL2, waveletType);
    [LL4,HL4,LH4,~] = dwt2(LL3, waveletType);
    
    previousRis = zeros(1);

    %% Extraction start
    while (k <= bitsPerFrame)
        doStep2 = 1;

        %% step 1
        while (doStep2 == 1 && tryNumber <= R)
            %% Step 2
            % We generate the random number ri from Eq. (1) and compute E from Eq. (2).
            
            %% Generate random number
            rng(ri); % Seed
            ri = int32(R * rand(1,1)); % Generate
            
            riDuplicate = find(previousRis(previousRis==ri));
            while (riDuplicate >= 1)
                %fprintf ('E: Duplicate found! %d k = %d\n',ri, k);
                ri = randi(R,1);
                riDuplicate = find(previousRis(previousRis==ri));
            end
            
            previousRis(k) = ri; % Store current value 
            tryNumber = tryNumber + 1;

            E = norm(LH3(ri),1) + norm(HL3(ri),1) + norm(LH4(ri),1) + norm(HL4(ri),1);
            %fprintf ('E = %f\n',E);

            %% Step 3
            % If E >=T then go to step 4, else return to step 2.
            if (E < T)
                doStep2 = 1; % Does nothing, just for readability
            else
                 doStep2 = 0;
            end
            
            % Escape after max number of tries
            if (tryNumber > R)
                fprintf ('!!!! DWT: Max tries reached in extraction.\n')
                WMBitIndex = currentFrame * bitsPerFrame;
                k = bitsPerFrame + 1;
            end
        end

        %% Step 4
        % Extract
        MPrimeri = mean(LL4(ri));
        qiPrime = int16(MPrimeri/Q);
        extractedWM(WMBitIndex) = double(mod(qiPrime,S));
        WMBitIndex = WMBitIndex + 1;
        debugCount = debugCount + 1;
        k = k + 1;
    end
    
    currentFrame = currentFrame + 1;
end