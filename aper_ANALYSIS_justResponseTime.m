function [] = aper_ANALYSIS_justResponseTime(sid, pathToSave, fileName, trialNum)
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

%% Response timing
[responseTime_open, responseTime_closed] = aper_responseTime(locs_movement, stimChanges_aperSamps, stimPks, Stm1, Fs_aper);

%% Correction timing
locs_reenters_open = find(data(1:end-1)>high_boundary(1:end-1) & data(2:end)<high_boundary(2:end));
locs_reenters_closed = find(data(1:end-1)<low_boundary(1:end-1) & data(2:end)>low_boundary(2:end));

[correctionTime_open, correctionTime_closed ] = aper_correctionTime(locs_reenters_open, locs_reenters_closed, stimChanges_aperSamps, stimPks, Stm1, Fs_aper);

%% Just save response timing values  
save(strcat(pathToSave, sid, '_AperANALYSIS_Timing_', trialNum),...
    'responseTime_open', 'responseTime_closed', 'correctionTime_open', 'correctionTime_closed');
end

