%% aper_coherence determines the time lagged coherence between the stimulations and the hand motion
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\Numerical_Differentiation');
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\SigAnal');

load('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-13');
startTime = 19;
endTime = 138;
Fs = Aper.info.SamplingRateHz;
T = 1/Fs;
startSampAper = floor(startTime*Fs);
endSampAper = floor(endTime*Fs);

data = Aper.data(startSampAper:endSampAper,1);
N=length(data);
Aper_time = (0:length(data)-1)/Fs;

%% Run the subsection for the smoothing function to use
% This 'smoothing' function determines the moments in the dataglove signal
% when there is a significant change in the hand's motion

%Add:
% kriging
% curvature
% bin into stim and no stim

%% Downsampling
% Want new sampling rate of 20 Hz
Fs2 = 20;

% The following changes the sampling rate using matlab's resample:
% [data_resamp, Fs2] = aper_downsampleGlove(data, Fs, Fs2);
% t2 = (0:length(data_resamp)-1)/Fs2; % New time array

% The following 'downsamples' by only selecting points of change (i.e., it
% doesn't include values where the diff == 0):
data_resamp = data([1; find(diff(data)~=0)+1]);
t2 = Aper_time([1; find(diff(data)~=0)+1]);

figure
plot(Aper_time, data, '*', t2, data_resamp, 'o')
xlabel('Time (s)')
ylabel('Signal')
legend('Original','Resampled', 'Location','NorthWest')

figure
plot(Aper_time, data)
hold on
plot(t2, data_resamp, 'r')

data_smoothed = data_resamp;
dx1 = diff(data_smoothed);
dx2 = diff(dx1);

% If we use the method of only taking the points in data that don't have a
% diff equal to zero, then there will be unequal spacing between points in
% the data_resamp, so we need to consider this when computing the diff. The
% diff function will not do this on it's own, so we need to do it:
% dx1 = [data_smoothed(2:end)-data_smoothed(1:end-1)]./[t2(2:end)-t2(1:end-1)]';
% dx2 = diff(dx1);

locs_movement=find(abs(dx2)>0.33);
locs_movement=locs_movement+1; 
% Add 1 in order to show that the significant point of motion change occurs
% at the middle point that the second derivative considers (e.g., signal
% sampled at index: 1, 2, 3. diff(signal) = [(2-1) (3-2)];
% diff(diff(signal)) = [(3-2)-(2-1)]: if this dx2 value is considered
% significant, then the significant change is centered around index 2

Fs2 = Fs*L/M;

%% Convolve with gaussian window
width_sec = 1; 
% windowWidth = int16(Fs*width_sec);
windowWidth = int16(Fs2*width_sec);
halfWidth = windowWidth/2;
gauss = gausswin(windowWidth);
gauss = gauss/sum(gauss); % Normalize
% data_smoothed = conv(data, gauss, 'same');
data_smoothed = conv(data_resamp, gauss, 'same');

dx1 = diff(data_smoothed);
dx2 = diff(dx1);
dx1_smoothed = conv(dx1, gauss, 'same');
dx2 = diff(dx1_smoothed);
dx2_smoothed = conv(dx2, gauss, 'same');
locs_movement=find(abs(dx2_smoothed)>0.5*10^-7);
locs_movement=locs_movement+1; % CHECK THIS!
% t2 = Aper_time;
% Fs2=Fs;

dx1 = dx1_smoothed;
dx2 = dx2_smoothed;

%% Remove high frequency noise from data
high_freq = 4; %Hz - get rid of frequencies above this value (~300ms reaction time...)
[data_smoothed] = aper_removeHighFreqNoise(data, Fs, high_freq);
dx1 = diff(data_smoothed);
dx2 = diff(diff(data_smoothed));
locs_movement=find(abs(dx2)>1.5*10^-7);
t2 = Aper_time;
Fs2=Fs;

%% Thresholding dx2 only
dx2 = diff(diff(data));
locs_movement=find(abs(dx2_smoothed)>0.4*10^-7);
t2 = Aper_time;

%% Numerical differentiation of noisy, nonsmooth data (total-variation regularization) 
iter = 40;
alph = 1e-1;
% alph = 100;
u0 = [];
scale = 'large';
ep = 1e-8;
dx = [];
plotflag = 0;
diagflag = 0;
[dx1_smoothed, relativeChange, gradientNorm] = TVRegDiff( data, iter, alph, u0, scale, ep, dx, plotflag, diagflag );
dx2 = diff(abs(u(:,5)));

%% Plot the data, resampled data, and the smoothed data
figure
plot(Aper_time, data)
hold on
plot(t2,data_resamp,'g')
plot(t2, data_smoothed, 'r')
legend('data', 'resampled data', 'smoothed data')
xlabel('time (sec)')

%% Check the smoothed DATA against the un-smoothed
figure
plot(Aper_time, data); hold on; plot(Aper_time, data_smoothed, 'r');
xlabel('Time (s)');

%% Check the smoothed data, dx, AND dx2 against the un-smoothed
figure
subplot(3,1,1)
plot(Aper_time, data); hold on; plot(t2, data_smoothed, 'r'); title('data')
subplot(3,1,2)
plot(Aper_time(2:end), diff(data)); hold on; plot(t2(2:end), dx1, 'r'); title('dx1')
subplot(3,1,3)
plot(Aper_time(3:end), diff(diff(data))); hold on; plot(t2(3:end), dx2, 'r'); title('dx2')
legend('data, dx1, and dx2', 'smoothed versions')

%% Plot the resulting points of significant motion change to check
figure
plot(Aper_time, data);
hold on
plot(t2, data_smoothed, 'g')
scatter((locs_movement-1)/Fs2, data_smoothed(locs_movement), 5, 'filled', 'r')
ylabel('Aperture value'); xlabel('time (s)');

%% dx2 threshold

width_sec = 3; 
windowWidth = floor(Fs2*width_sec);
halfWidth = windowWidth/2;
rect = repmat(1/windowWidth, 1, windowWidth); % Normalize
moving_avg_dx2 = conv(abs(dx2), rect, 'same');

% if mod(samps,2)==0 % if samps is even
%     samps = samps + 1; % add 1 to samps to make it odd, so that the moving average is symmetric
% end
% wts = repmat(1/samps,samps,1);

thresh = moving_avg_dx2;

locs_movement=find(abs(dx2)>thresh);
locs_movement=locs_movement+1; 

figure
plot(t2(3:end), abs(dx2), 'b')
hold on
plot(t2(3:end), thresh, 'r')

dx2_norm = zeros(size(dx2));
dx2_norm(find((abs(dx2)>thresh)==1)) = abs(dx2)-thresh;

figure
plot(t2(3:end), dx2_norm)

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
[starts, ends, startsPks, startsTime] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI, PTD, IPI, 'on');
% Missing some state changes -- fix this!!

% Binary: movement, significant change or not
movement = zeros(size(data_smoothed));
movement(locs_movement) = 1; % locs_movement corresponds to the new sampling frequency

% Binary: stim on or off
% starts_aper_samps = [floor(startsTime*Fs2); floor(ends/Fs_stim*Fs2)];
% stimChange = zeros(size(data_smoothed));
% stimChange(starts_aper_samps) = 1;
% starts is in samples of the Stim.data starting from the startSampStim

% Plot it all:
figure 
plot(Aper_time, data, 'b'); hold on
plot(t2, data_smoothed, 'g')
plot(Aper_time, Aper.data(startSampAper:endSampAper,2), 'r')
plot(Aper_time, Aper.data(startSampAper:endSampAper,3), 'r')
% scatter(t2(movement==1), data_smoothed(movement==1), 8, 'filled', 'm');

starts_aper_samps = [floor(starts/Fs_stim*Fs); floor(ends/Fs_stim*Fs)];
stimChange = zeros(size(data));
stimChange(starts_aper_samps) = 1;
scatter(Aper_time(stimChange==1), data(stimChange==1), 8, 'filled', 'k');

% scatter(t2(stimChange==1), data_smoothed(stimChange==1), 8, 'filled', 'k');
legend('data', 'smoothed data', 'target boundary', 'target boundary', 'Significant movement changes', 'Stim state changes');

ylabel('Aperture value'); xlabel('time (s)');



