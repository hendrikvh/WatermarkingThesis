% -------------------------------------------------
% Inoue2000Embed
% -------------------------------------------------
% 
% Embedding stage of DWT watermarking technique. 
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

function [WMYBlock] = Inoue2000Embed(YBlock, WMInput, T, Q)

%% Setup
waveletType = 'db4';

%%Paramenters
N = 4;
S = 2;
R = size(YBlock,1)/2^4 * size(YBlock,2)/2^4;

%% Initialisation
currentFrame = 1;
YBlock = im2uint8(YBlock);
WMYBlock = 50 * ones(size(YBlock));

% Determine bits per frame
bitsPerFrame = length(WMInput) / size(YBlock,3);
fprintf ('DWT: Embedding %3.2f bits per frame.\n', bitsPerFrame);

%%  Step 0
%   We set two threshold values T1, T2 for a given threshold value T,
%   where T2 <T <T1. We prepare the function F(·) that generates random numbers
T1 = T + 5;
T2 = T - 5;

U = 1.2;
L = 0.8;
    
WMBitIndex = 1;

while (currentFrame <= size(YBlock,3))
   
    %Get Frame
    YFrame = YBlock(:,:,currentFrame);
   
    %% Deconstruct image
    [LL1,HL1,LH1, HH1] = dwt2(YFrame, waveletType);
    [LL2,HL2,LH2,HH2] = dwt2(LL1, waveletType);
    [LL3,HL3,LH3,HH3] = dwt2(LL2, waveletType);
    [LL4,HL4,LH4,HH4] = dwt2(LL3, waveletType);

    %% Step 1
    % We put i := 1 and set the initial value r0 de- pending on k.
    k = 1;
    ri = 1;

    %% Embed bits in frame

    previousRis = zeros(1);
    while (k <= bitsPerFrame)
        tryNumber = 1;
        doStep2 = 1;

        %% Step 2
        % We generate the random number ri from Eq. (1) and calculate E
        while (doStep2 == 1 && tryNumber <= R)
            
            %% Generate random number
            rng(ri); % Seed
            ri = int32(R * rand(1,1)); % Generate
            
            %Determine if random number has been selected previously
            riDuplicate = find(previousRis(previousRis==ri));
            while (riDuplicate >= 1)
                %fprintf ('Duplicate found! %d at bit %d\n',ri, WMBitIndex);
                ri = randi(R,1);
                riDuplicate = find(previousRis(previousRis==ri));
            end
            
            E = norm(LH3(ri),1) + norm(HL3(ri),1) + norm(LH4(ri),1) + norm(HL4(ri),1);
            %fprintf ('E  = %3.2f\n', E);

            %% Step 3
            if (E < T1);
                % If T ? E< T1, then we multiply the wavelet coefficients * U>1 and goto step4.
                if (E >= T && E < T1)
                    %fprintf ('E >= T && E < T1\n');
                    LH3(ri) = LH3(ri) * U;
                    HL3(ri) = HL3(ri) * U;
                    doStep2 = 0;
                    
                % If T2 ? E< T, then we multiply the same coeffs with L < 1 return to step2.
                elseif (E >= T2 && E < T)
                    LH3(ri) = LH3(ri) * L;
                    HL3(ri) = HL3(ri) * L;
                    %fprintf ('E between T2 and T. Do step2 again\n');
                    doStep2 = 1;
                    
                % If E< T2, then i := i+1 and return to step2.
                elseif (E < T2)
                    %fprintf ('E < T2. Do step2 again.\n');
                    doStep2 = 1;
                end
            % If E ? T1, then goto step4.
            elseif (E > T1)
                doStep2 = 0;  
            end
            tryNumber = tryNumber + 1;
        end

            %% Step 4
            Mri = mean (LL4(ri));
           % fprintf ('Mean = %f ', Mri);
            qi = int16(Mri/Q);

            %% Step 5
            qiPrime = GetqiPrime (qi, WMInput(WMBitIndex));
            %fprintf ('Embedded bit %d.\n', WMBitIndex);
            WMBitIndex = WMBitIndex + 1;

            %% Step 6
            MriPrime = qiPrime * Q;
            deltaMri = MriPrime - Mri;
            LL4 (ri) = LL4(ri) + deltaMri;

            k = k + 1; %bit number
            previousRis(k) = ri; % Store current value 
            %Escape after too many tries
            if (tryNumber >= R)
                fprintf ('!!!! DWT: Max tries reached in embedding.\n');
                k = bitsPerFrame + 1;
                WMBitIndex = currentFrame * bitsPerFrame + 1;
            end
            
    end
   
    %% Reconstruct image
    %%Inverse DWT 1
    LL3 = idwt2(LL4,HL4,LH4,HH4, waveletType);
    LL2 = idwt2(LL3,HL3,LH3,HH3, waveletType);
    LL1 = idwt2(LL2,HL2,LH2,HH2, waveletType);

    WMYBlock(:,:,currentFrame) = idwt2(LL1,HL1,LH1,HH1, waveletType);
    currentFrame = currentFrame + 1;
end

WMYBlock = im2double(WMYBlock/255);
