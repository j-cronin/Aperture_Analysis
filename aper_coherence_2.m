%% aper_coherence determines the time lagged coherence between the stimulations and the hand motion
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\Numerical_Differentiation');
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\SigAnal');
load('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-13');

% addpath('/Users/jcronin/Box Sync/Code/Matlab/Numerical_Differentiation');
% addpath('/Users/jcronin/Box Sync/Code/Matlab/SigAnal');
% load('/Users/jcronin/Box Sync/Lab/Temp data/Aperture_ecb43e-13');

startTime = 19;
endTime = 138;
Fs = Aper.info.SamplingRateHz;
T = 1/Fs;
startSampAper = floor(startTime*Fs);
endSampAper = floor(endTime*Fs);
Fs2 = 20;
T2=1/Fs2;

data = Aper.data(startSampAper:endSampAper,1);
N=length(data);
Aper_time = (0:length(data)-1)/Fs;

%% Downsampling
% The following 'downsamples' by only selecting points of change (i.e., it
% doesn't include values where the diff == 0):
data_resamp = data([1; find(diff(data)~=0)+1]);
t2 = Aper_time([1; find(diff(data)~=0)+1])';
% Interpolate the values at the original sampling points in Aper_time:
data_interp = interp1(t2, data_resamp, Aper_time, 'pchip'); 
% data_interp = interp1(t2, data_resamp, Aper_time); 

figure
plot(Aper_time, data)
hold on
plot(Aper_time, data_interp, 'r')
xlabel('Time (s)')
ylabel('Signal')

cutoff = 2; %Hz
[b, a] = butter(1, [cutoff/Fs*2], 'low');
data_filt = filtfilt(b, a, data_interp);
plot(Aper_time, data_filt, 'g')
legend('Original','Resampled and interpolated', 'Filtered','Location','NorthWest')

% cutoff = 2; %Hz
% [b, a] = butter(1, [cutoff/Fs*2], 'low');
% dx1 = filtfilt(b, a, diff(data_filt));
% dx2 = filtfilt(b, a, diff(dx1));
% % cutoff = 0.5; %Hz
% % [b, a] = butter(1, [cutoff/Fs*2], 'low');
% % dx2_extraFilt = filtfilt(b, a, diff(dx1));
% dx2_extraFilt = dx2;
% dx3 = filtfilt(b, a, diff(dx2_extraFilt));

dx1 = diff(data_filt);
dx2 = diff(dx1);
dx3 = diff(dx2);

cutoff = 2; %Hz
[b, a] = butter(1, [cutoff/Fs*2], 'low');
dx1 = filtfilt(b, a, dx1);
dx2 = filtfilt(b, a, dx2);
dx3 = filtfilt(b, a, dx3);

figure
subplot(3,1,1); plot(Aper_time(2:end), dx1); title('dx1')
subplot(3,1,2); plot(Aper_time(3:end), dx2); title('dx2')
subplot(3,1,3); plot(Aper_time(4:end), dx3); title('dx3')

%% Check the smoothed data, dx, AND dx2 against the un-smoothed
figure
subplot(3,1,1)
plot(Aper_time, data); hold on; plot(Aper_time, data_interp, 'r'); title('data')
subplot(3,1,2)
plot(Aper_time(2:end), diff(data)); hold on; plot(Aper_time(2:end), dx1, 'r'); title('dx1')
subplot(3,1,3)
plot(Aper_time(3:end), diff(diff(data))); hold on; plot(Aper_time(3:end), dx2, 'r'); title('dx2')
legend('data, dx1, and dx2', 'interpolated data versions')

%% Plot just all of the smoothed
figure
subplot(3,1,1)
plot(Aper_time, data_interp, 'r'); title('data')
subplot(3,1,2)
plot(Aper_time(2:end), dx1, 'r'); title('dx1')
subplot(3,1,3)
plot(Aper_time(3:end), dx2, 'r'); title('dx2')
legend('data, dx1, and dx2', 'interpolated data versions')

%% Movement threshold
% Zero-crossings of dx1 and dx2
dx1_locs = find(dx1(1:end-1)<0&dx1(2:end)>0 | dx1(1:end-1)>0&dx1(2:end)<0);
dx2_locs = find(dx2(1:end-1)<0&dx2(2:end)>0 | dx2(1:end-1)>0&dx2(2:end)<0);
dx3_locs = find(dx3(1:end-1)<0&dx3(2:end)>0 | dx3(1:end-1)>0&dx3(2:end)<0);

% dx2_locs = dx2_locs(abs(dx1(dx2_locs))>1.7*10^-6);
% dx3_locs = dx3_locs(abs(dx2(dx3_locs))>1.65*10^-8);

dx3_keep = abs(abs(dx2(dx3_locs-floor(T2*Fs))-dx2(dx3_locs)) - abs(dx2(dx3_locs+floor(T2*Fs))-dx2(dx3_locs)))>1*10^-8;
dx3_locs = dx3_locs(dx3_keep);

% locs_movement=[dx1_locs, dx2_locs dx3_locs];
locs_movement=[dx3_locs];

figure
subplot(4,1,1)
plot(Aper_time, data_interp, 'b'); title('data')
hold on
plot(Aper_time, data_filt, 'r');
scatter(Aper_time(locs_movement), data_filt(locs_movement),'g')
legend('data interpolated', 'filtered')
subplot(4,1,2)
plot(Aper_time(2:end), dx1, 'r'); title('dx1')
legend('derivatives filtered', 'zeros')
hold on
scatter(Aper_time(dx1_locs), dx1(dx1_locs))
subplot(4,1,3)
plot(Aper_time(3:end), dx2, 'r'); title('dx2')
hold on
scatter(Aper_time(dx2_locs), dx2(dx2_locs))
subplot(4,1,4)
plot(Aper_time(4:end), dx3, 'r'); title('dx3')
hold on
scatter(Aper_time(dx3_locs), dx3(dx3_locs))


% locs_movement=locs_movement+1; 
% Add 1 in order to show that the significant point of motion change occurs
% at the middle point that the second derivative considers (e.g., signal
% sampled at index: 1, 2, 3. diff(signal) = [(2-1) (3-2)];
% diff(diff(signal)) = [(3-2)-(2-1)]: if this dx2 value is considered
% significant, then the significant change is centered around index 2

%%
figure
plot(Aper_time, data_interp, 'b'); title('data')
hold on
plot(Aper_time, data_filt, 'r');
scatter(Aper_time(locs_movement), data_filt(locs_movement),'g')
legend('data interpolated', 'filtered')

figure
subplot(3,1,1)
plot(Aper_time(2:end), dx1, 'r'); title('dx1')
legend('derivatives filtered', 'zeros')
hold on
scatter(Aper_time(dx1_locs), dx1(dx1_locs))
subplot(3,1,2)
plot(Aper_time(3:end), dx2, 'r'); title('dx2')
hold on
scatter(Aper_time(dx2_locs), dx2(dx2_locs))
subplot(3,1,3)
plot(Aper_time(4:end), dx3, 'r'); title('dx3')
hold on
scatter(Aper_time(dx3_locs), dx3(dx3_locs))
%% Establish where the stim changes state (i.e., times when the subject should respond)
ITI = max(Stm0.data(:,11));
PTD = max(Stm0.data(:,8));
IPI = max(Stm0.data(:,5));

Fs_stim = Stim.info.SamplingRateHz;
T_stim = 1/Fs_stim;
Stim_time = (0:length(Stim.data(:,1))-1)/Fs_stim;
startSampStim = floor(startTime*Fs_stim);
endSampStim = floor(endTime*Fs_stim);

% change so it considers different stim lengths
figure
% [starts, ends, startsPks, endsPks, startsTime] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI, PTD, IPI, 'on');
[stimChanges, stimPks] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI, PTD, IPI, 'on');
% Missing some state changes -- fix this!!

% Binary: movement, significant change or not
movement = zeros(size(data_interp));
movement(locs_movement) = 1; % locs_movement corresponds to the new sampling frequency

% Binary: stim on or off
% starts_aper_samps = [floor(startsTime*Fs2); floor(ends/Fs_stim*Fs2)];
% stimChange = zeros(size(data_smoothed));
% stimChange(starts_aper_samps) = 1;
% starts is in samples of the Stim.data starting from the startSampStim

% Plot it all:
figure 
plot(Aper_time, data, 'b'); hold on
plot(Aper_time, data_filt, 'g')
plot(Aper_time, Aper.data(startSampAper:endSampAper,2), 'r')
plot(Aper_time, Aper.data(startSampAper:endSampAper,3), 'r')
% scatter(t2(movement==1), data_smoothed(movement==1), 8, 'filled', 'm');

% starts_aper_samps = [floor(starts/Fs_stim*Fs); floor(ends/Fs_stim*Fs)];
starts_aper_samps = [floor(stimChanges/Fs_stim*Fs)];
stimChange = zeros(size(data));
stimChange(starts_aper_samps) = 1;
scatter(Aper_time(movement==1), data_filt(movement==1), 8, 'filled', 'm');
scatter(Aper_time(stimChange==1), data(stimChange==1), 8, 'filled', 'k');
legend('data', 'filtered data', 'target boundary', 'target boundary', 'Significant movement changes', 'Stim state changes');

ylabel('Aperture value'); xlabel('time (s)');



