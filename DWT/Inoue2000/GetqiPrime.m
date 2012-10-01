% -------------------------------------------------
% GetqiPrime
% -------------------------------------------------
% 
% Support function for Inoue2000Embed and Inoue2000Extract
% 
% Hendrik van Huyssteen
% Hendrikvh@ml.sun.ac.za
% http://ml.sun.ac.za/~hendrikvh
% 2012
% 
% -------------------------------------------------

function [qiPrime] = GetqiPrime(qi, WMBitToEmbed)
S = 2;
qi = double(qi);
%fprintf ('\nqi = %d, embedding %d. ', qi, WMBitToEmbed);
 j = floor(qi/S);

if ( (qi >= j*S) && (qi < (j+1)*S))
    if (WMBitToEmbed == 0)
        qiPrime = j*S; 
        
    elseif (WMBitToEmbed == 1)
        qiPrime = j*S + 1;
    end
    %fprintf ('1\n');

elseif ( (qi >= (j+1)*S) && (qi < (j+2)*S))
    if (WMBitToEmbed == 0)
        qiPrime = (j+1)*S; 
        
    elseif (WMBitToEmbed == 1)
        qiPrime = (j+1)*S + 1;
    end
      %fprintf ('2\n');
    
elseif ( (qi >= (j-1)*S) && (qi < (j)*S))
     if (WMBitToEmbed == 0)
        qiPrime = (j-1)*S; 
        
    elseif (WMBitToEmbed == 1)
         qiPrime = j*S;
     end
      % fprintf ('3\n');
else
    error ('Niks werk nie.')
end
%fprintf ('j = %d and qiPrime = %f\n', j, qiPrime);