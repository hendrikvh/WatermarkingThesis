% -------------------------------------------------
% Padblock
% -------------------------------------------------
% 
% Support function for Testbed.m
% Used for evaluation in Chapter 5 of thesis available at http://ml.sun.ac.za/~hendrikvh/HendrikvhThesis.pdf
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [paddedBlock] = PadBlock(YBlock)

i =1;

while (i<=size(YBlock,3))

    neededX = (1920 - size(YBlock,2))/2;
    neededY = (1080 - size(YBlock,1))/2;
    horz = zeros(size(YBlock,1), neededX);
    C = horzcat(horz,YBlock(:,:,i),horz);
    vert = zeros(neededY, size(C,2));
    C = vertcat(vert,C,vert);

    
    % Check if correct size
    neededX = 1920 - size(C,2);
    neededY = 1080 - size(C,1);
    
    if (neededX > 0 || neededY > 0)
        C = vertcat(C,zeros(neededY, size(C,2)));
        C = horzcat(C,zeros(size(C,1),neededX));
    end
    
    
    paddedBlock(:,:,i) = C;
    i = i + 1;

end

end