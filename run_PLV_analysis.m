%% PLV analysis
% addpath('C:\Users\jcronin\Box Sync\Code\Matlab\SigAnal');
addpath('/Users/jcronin/Box Sync/Code/Matlab/SigAnal');

sid = fca96e;
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];

for i=1:1 %length(fca96e_trials)
    trialNum = num2str(fca96e_trials(i));
    %     fileName = strcat('C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-', trialNum);
    fileName = strcat('/Users/jcronin/Box Sync/Lab/Temp data/fca96e/Aperture-', trialNum);
    [data, epochs] = removeStim_fast(fileName);
end

%% Filter and common average reference
disp('Beginning filtering')
load(fileName);
fs_wave = Wave.info.SamplingRateHz; % sampling rate of the wave data (Hz)

load('/Users/jcronin/Box Sync/Lab/Temp data/fca96e/montage');
Montage.Montage = 64;
Montage.BadChannels = [4 5];

sig = cell(size(data));
bpsig = cell(size(data));
for i=1:length(data)
    sig{i} = ReferenceCAR(Montage.Montage, Montage.BadChannels, data{i});
    sig{i} = notch(sig{i}, [60 120 180], fs_wave, 4);
    bpsig{i} = highpass(sig{i}, 1, fs_wave, 4);
end

%% Check figure
figure
plot(bpsig{10})

%% Plv analysis
disp('Beginning PLV analysis')
badChans = Montage.BadChannels;
fs = fs_wave;
connectivityRHI_par


