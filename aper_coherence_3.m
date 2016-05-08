function [locs_movement, aper_interp, aper_filt, dx3] = aper_coherence_3(aper_data, fs_aper)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

%% aper_coherence determines the time lagged coherence between the stimulations and the hand motion
%addpath('C:\Users\jcronin\Code\Matlab\Other\Numerical_Differentiation');
%addpath('C:\Users\jcronin\Code\Matlab\SigAnal');
addpath('C:\Users\jcronin\Code\Matlab\Experiments\Aperture_Analysis\postprunedx3code');

%fs_aper = Aper.info.SamplingRateHz;
% T = 1/fs_aper;
% 
% N=length(aper_data);
Aper_time = ((0:length(aper_data)-1)/fs_aper)';

%% Downsampling
% The following 'downsamples' by only selecting points of change (i.e., it
% doesn't include values where the diff == 0):
aper_resamp = aper_data([1; find(diff(aper_data)~=0)+1]);
t2 = Aper_time([1; find(diff(aper_data)~=0)+1])';
% Interpolate the values at the original sampling points in Aper_time:
aper_interp = interp1(t2, aper_resamp, Aper_time, 'pchip'); 

% figure
% plot(Aper_time, aper_data)
% hold on
% plot(Aper_time, aper_interp, 'r')
% xlabel('Time (s)')
% ylabel('Signal')
% legend('Original','Resampled and interpolated', 'Location','NorthWest')

% 3rd value is the minimum feature size:
aper_filt = glove_smooth(aper_interp, fs_aper, 0.1, 20);
dx1 = diff(glove_smooth(aper_filt, fs_aper, 0.05, 3));
dx2 = diff(glove_smooth(dx1, fs_aper, 0.15, 10));
dx3 = diff(glove_smooth(dx2, fs_aper, 0.15, 10));

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
% plot(Aper_time, aper_interp, 'b'); title('aper_data')
% hold on
% plot(Aper_time, aper_filt, 'r');
% % scatter(Aper_time(locs_movementj), aper_filtj(locs_movementj),'g')
% % legend('aper_data interpolated', 'filtered')
% % plot(Aper_time(2:end), dx1j, 'r'); title('dx1')
% % legend('derivatives filtered', 'zeros')
% hold on
% scatter(Aper_time(dx1_locs), aper_interp(dx1_locs), 'r')
% % plot(Aper_time(3:end), dx2j, 'darkgreen'); title('dx2')
% % hold on
% % scatter(Aper_time(dx2_locsjp), aper_interp(dx2_locsjp), 'k')
% % % plot(Aper_time(4:end), dx3j, 'm'); title('dx3')
% % % hold on
% scatter(Aper_time(dx3_locsp), aper_interp(dx3_locsp), 'm')


end

