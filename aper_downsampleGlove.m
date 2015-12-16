function [ data_resamp, Fs_new ] = aper_downsampleGlove( data, Fs, Fs_new)
%Aper_downsampleGlove changes the sampling rate of the glove data from the
%Fs sampling rate to the new sampling rate, Fs_new. 
%   This is specifically designed to only change the sampling rate from
%   3487.7 Hz to 20 Hz!!!!!! It cannot be used with any other sampling
%   rates currently!
T = 1/Fs;
T2 = 1/Fs_new;

T11=round(T*10^8); % Create an integer number from the original sampling period
T22=round(T2*10^8);
m=factor(T22); % factor those integer numbers
l=factor(T11);

% After looking at the factored numbers, you can see that M and L should be
% the product of the last few values. This is not automatic yet, must look
% at the m and l factors first.
M=cumprod(m(7:end)); 
L=cumprod(l(7:end));
M=M(end); % M and L just equal the final product
L=L(end);

data_resamp = resample(data, L, M, 100);
% data_resamp = resample(data, [0:1/20:120-1/20], Fs2, L, M);

end

