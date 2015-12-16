function [] = aper_ANALYSIS(sid, pathToSave, fileName, trialNum)
% Aper ANALYSIS



%% Initialize
load(fileName);
Fs_aper = Aper.info.SamplingRateHz;
Aper_time = (0:length(Aper.data(:,1))-1)/Fs_aper;
Fs_stim = Stim.info.SamplingRateHz;
Stim_time = (0:length(Stim.data(:,1))-1)/Fs_stim;

%% Load start time and end time 
load(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum));
startSampAper = floor(startTime*Fs_aper);
endSampAper = floor(endTime*Fs_aper);
data = Aper.data(startSampAper:endSampAper,1);
high_boundary = Aper.data(startSampAper:endSampAper,2);
low_boundary = Aper.data(startSampAper:endSampAper,3);

Aper_time2 = (0:length(data)-1)/Fs_aper;

startSampStim = floor(startTime*Fs_stim);
endSampStim = floor(endTime*Fs_stim);

%% Find when the stim changes state
ITI = max(Stm0.data(:,11));
PTD = max(Stm0.data(:,8));
IPI = max(Stm0.data(:,5));
[stimChanges, stimPks] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI, PTD, IPI, 'on');

% Change stimChanges to represent Aper samples rather than Stim samples
stimChanges_aperSamps = [floor(stimChanges/Fs_stim*Fs_aper)];

%% Find the points of significant change in movement
[locs_movement, data_interp, data_filt, dx3] = aper_coherence_3(Aper, Stim, startTime, endTime);

%% Compute average jerk after state change
window = 9; % in seconds
indeces = [];

for i=1:length(stimChanges_aperSamps)
    indeces = [indeces, (stimChanges_aperSamps(i):(stimChanges_aperSamps(i)+window*Fs_aper))];
end

afterStateChange = unique(indeces);
noStateChange = setdiff((1:length(data)), unique(indeces));

try
    dx3_stateChange = dx3(afterStateChange);
    dx3_noChange = dx3(noStateChange);
catch
    afterStateChange = afterStateChange(find(afterStateChange<=length(dx3)));
    noStateChange = noStateChange(find(noStateChange<=length(dx3)));
    dx3_stateChange = dx3(afterStateChange);
    dx3_noChange = dx3(noStateChange);
end

mean(dx3_stateChange);
mean(dx3_noChange);

%% save average dx3 values
save(strcat(pathToSave, sid, '_AperANALYSIS_dx3_', trialNum),...
    'dx3_stateChange', 'dx3_noChange');
end

