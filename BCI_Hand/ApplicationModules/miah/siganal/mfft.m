% wrapper for fft to make life easy
function [Y, hz] = mfft(X, dim, fs)       
    if (~exist('dim','var'))
        dim = 1;
    end
    
    if (~exist('fs','var'))
        error('sampling frequency must be supplied');
    end
    
    nfft = size(X,dim);
    
    Y = fft(X, nfft)/nfft;
    
    hz = fs/2*linspace(0,1,nfft/2+1);
    
    Y = 2*Y(1:nfft/2+1);
end