function [data, epochs] = removeStim_fast(fileName, startTime, endTime)
%% Load in the trigger data
% Input subject info (subject ID, file location, and naming scheme of the
% tank streams) -- **** TO-DO: don't hard-code the sid path to file
%sid = fca96e;
% fileName = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-8';
load(fileName);

wave = Wave; % ECoG data
stim = Stim; % Stim data

% Compute the sampling rates of the ECoG data and Stim data
fs_stim = stim.info.SamplingRateHz; % sampling rate of the stim data (Hz)
t_stim = [0:1:length(stim.data(:,1))-1]/fs_stim; % stim timing (s)

fs_wave = wave.info.SamplingRateHz; % sampling rate of the wave data (Hz)
t_wave = [0:1:length(wave.data(:,1))-1]/fs_wave; % wave timing (s)

% Also compute the Aperture sampling rate if analyzign the aper task
fs_aper = Aper.info.SamplingRateHz; % sampling rate of the stim data (Hz)
t_aper = [0:1:length(Aper.data(:,1))-1]/fs_aper; % stim timing (s)

% For aperture task: Cut out the times before the trial began (stim turned
% on)and the last seconds at the end
% startTime = 38; %seconds
% endTime = 134; %seconds

startSampAper = floor(startTime*fs_aper);
endSampAper = floor(endTime*fs_aper);
startSampStim = floor(startTime*fs_stim);
endSampStim = floor(endTime*fs_stim);
startSampWave = floor(startTime*fs_wave);
endSampWave = floor(endTime*fs_wave);


%% find the starts and stops of the stim trains:
ITI_ms = max(Stm0.data(:,13));
ITI_samps_min = max(Stm1.data(:,13))*fs_stim/1000; % This is the smallest ITI possible (in Stim 1)
PTD_ms =  max(Stm0.data(:,10));
PTD_samps =  max(Stm0.data(:,9));
PTD_samps = PTD_samps + PTD_samps/40; % Have to do this because the aperture TDT code always added in one extra pulse
IPI_us = max(Stm0.data(:,7));
% [stimStarts, stimEnds, stimChanges_pks, stimChanges_time] = StimStarts(Stim.data(startSampStim:endSampStim,4), fs_stim, ITI_ms, PTD_ms, IPI_us, 'off');
[stimStarts, startsPks] = StimStarts(Stim.data(startSampStim:endSampStim,4), fs_stim, ITI_ms, PTD_ms, IPI_us, 'off');


%% Convert the stim start and end sample numbers from stim samples to ECoG wave samples (ECoG was sampled slower)
% And add the startSampStim and endSampStim values, since the values that
% StimStarts returns do not take the startSampStim into consideration

stimStarts_shifted = stimStarts + startSampStim;
stimEnds_shifted = stimStarts_shifted + PTD_samps;

% If stim starts are too close to one another, only consider the first stim
% start and the last stim end of the group:
indexStarts_keep = (stimStarts_shifted(2:end) - stimStarts_shifted(1:end-1) >= ITI_samps_min);
indexEnds_keep = logical([indexStarts_keep; 1]);

stimStarts_shifted = stimStarts_shifted(logical([1; indexStarts_keep]));
stimEnds_shifted = stimEnds_shifted(indexEnds_keep);


startStim_wave = stimStarts_shifted/fs_stim*fs_wave + 15 - 3; % change this arbitrary choice of 15 and 7 samples (the whole thing seemed like it need to be shifted by ~10 ms = 15samples, and then it still seemed to include too much)
endStim_wave = stimEnds_shifted/fs_stim*fs_wave + 15 + 3;
% endStim_wave = startStim_wave + PTD_samps + 15 + 3;

%% Visualize
figure
plot(t_wave(startSampWave:endSampWave), Wave.data(startSampWave:endSampWave,10))
hold on
stem(startStim_wave/fs_wave, repmat(5*10^(-4), size(startStim_wave)), 'r')
stem(endStim_wave/fs_wave, repmat(5*10^(-4), size(startStim_wave)), 'g')

% stem((stimStarts+startSampStim)/fs_stim+0.01, repmat(5*10^(-4), size(stimEnds/fs_stim)), 'r')
% stem((stimEnds+startSampStim)/fs_stim+0.01, repmat(5*10^(-4), size(stimEnds/fs_stim)), 'g')

%% Create data matrix for connectivity measures - 3D matrix with NaN padding any unfilled cells
% % Need: d1: samples, d2: channels, d3: trials
% % Trials will be segmented to cut out all stim artifact
%
% maxLength = max(startStim_wave(2:end) - endStim_wave(1:end-1));
% epochs = length(startStim_wave)-1;
%
% data = zeros(maxLength, 128, epochs);
%
% % data(:,:,1)=Wave.data(startSampWave:startStim_wave(1));
% for i=1:length(stimStarts)-1
%     data(1:length(endStim_wave(i):startStim_wave(i+1)), :, i)=Wave.data(endStim_wave(i):startStim_wave(i+1),:);
%     data(length(endStim_wave(i):startStim_wave(i+1))+1:end, :, i)=NaN;
% end
% % data(1:length(endStim_wave(i+1):endSampWave),:,i+1)=Wave.data(endStim_wave(end):endSampWave, :);
% % data(length(endStim_wave(i+1):endSampWave)+1:end, :, i)=NaN;
%
% % k=15;
% % plot(t_wave(endStim_wave(k):startStim_wave(k+1)), Wave.data(endStim_wave(k):startStim_wave(k+1),1))
% % xlabel('Seconds')
% %
% % miliseconds = (startStim_wave(k+1)-endStim_wave(k))/fs_wave*10^3

%% Create data cell array with 2D matrices in each cell
% Matrix: samples x channels
% Cells: trials/epochs

epochs = length(startStim_wave)-1;
data = cell([epochs 1]);

for i=1:length(startStim_wave)-1
    data{i}=Wave.data(endStim_wave(i):startStim_wave(i+1),1:64);
end

end

