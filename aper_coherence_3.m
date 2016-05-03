function [locs_movement, data_interp, data_filt, dx3] = aper_coherence_3(Aper, Stim, startTime, endTime)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

%% aper_coherence determines the time lagged coherence between the stimulations and the hand motion
addpath('C:\Users\jcronin\Code\Matlab\Numerical_Differentiation');
addpath('C:\Users\jcronin\Code\Matlab\SigAnal');
addpath('C:\Users\jcronin\Code\Matlab\Experiments\Aperture_Analysis\postprunedx3code');

Fs = Aper.info.SamplingRateHz;
T = 1/Fs;
startSampAper = floor(startTime*Fs);
endSampAper = floor(endTime*Fs);

data = Aper.data(startSampAper:endSampAper,1);
N=length(data);
Aper_time = ((0:length(data)-1)/Fs)';

%% Downsampling
% The following 'downsamples' by only selecting points of change (i.e., it
% doesn't include values where the diff == 0):
data_resamp = data([1; find(diff(data)~=0)+1]);
t2 = Aper_time([1; find(diff(data)~=0)+1])';
% Interpolate the values at the original sampling points in Aper_time:
data_interp = interp1(t2, data_resamp, Aper_time, 'pchip'); 

% figure
% plot(Aper_time, data)
% hold on
% plot(Aper_time, data_interp, 'r')
% xlabel('Time (s)')
% ylabel('Signal')
% legend('Original','Resampled and interpolated', 'Location','NorthWest')

data_filt = glove_smooth(data_interp, Fs, 0.1, 20);
dx1 = diff(glove_smooth(data_filt, Fs, 0.05, 3));
dx2 = diff(glove_smooth(dx1, Fs, 0.15, 10));
dx3 = diff(glove_smooth(dx2, Fs, 0.15, 10));

% figure
% subplot(3,1,1); plot(Aper_time(2:end), dx1); title('dx1')
% subplot(3,1,2); plot(Aper_time(3:end), dx2); title('dx2')
% subplot(3,1,3); plot(Aper_time(4:end), dx3); title('dx3')

%% Movement threshold
% Zero-crossings of dx1 and dx2
dx1_locs = find(dx1(1:end-1)<0&dx1(2:end)>0 | dx1(1:end-1)>0&dx1(2:end)<0);
dx2_locs = find(dx2(1:end-1)<0&dx2(2:end)>0 | dx2(1:end-1)>0&dx2(2:end)<0);
dx3_locs = find(dx3(1:end-1)<0&dx3(2:end)>0 | dx3(1:end-1)>0&dx3(2:end)<0);

dx3_locsp = removeifnot(dx2_locs, dx3_locs);
locs_movement=[dx1_locs; dx3_locsp];

% figure
% plot(Aper_time, data_interp, 'b'); title('data')
% hold on
% plot(Aper_time, data_filt, 'r');
% % scatter(Aper_time(locs_movementj), data_filtj(locs_movementj),'g')
% % legend('data interpolated', 'filtered')
% % plot(Aper_time(2:end), dx1j, 'r'); title('dx1')
% % legend('derivatives filtered', 'zeros')
% hold on
% scatter(Aper_time(dx1_locs), data_interp(dx1_locs), 'r')
% % plot(Aper_time(3:end), dx2j, 'darkgreen'); title('dx2')
% % hold on
% % scatter(Aper_time(dx2_locsjp), data_interp(dx2_locsjp), 'k')
% % % plot(Aper_time(4:end), dx3j, 'm'); title('dx3')
% % % hold on
% scatter(Aper_time(dx3_locsp), data_interp(dx3_locsp), 'm')


end

