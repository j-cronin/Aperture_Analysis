function [ data_smoothed ] = aper_removeHighFreqNoise(data, Fs, high_freq)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

N=length(data);
fft_data = fft(data);
dF = Fs/N;
f = 0:dF:Fs-dF;

% To plot two-sided spectrum, shifted to around 0
% fft_data = fftshift(fft_data);
% f = -Fs/2:dF:Fs/2-dF; % to plot it 

figure; subplot(2,1,1); title('FFT');
plot(f, abs(fft_data));
title('Double-Sided Freq. Spectrum of X(t)'); xlabel('freq (Hz)')

i=find(abs(f)>high_freq,1); 
fft_data(i:end-i+2) = 0; % Set high frequencies to 0; Why does this have to be +2 not just +1??

subplot(2,1,2); plot(f, abs(fft_data)); title('FFT with zeroed frequencies');

data_smoothed = ifft(fft_data); 

end