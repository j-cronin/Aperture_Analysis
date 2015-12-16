%% PLV analysis

% parpool(16)

warning('off','all')

sid = 'fca96e';
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];
fca96e_practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];

% Initialize
startTime = zeros(length(fca96e_trials), 1);
endTime = zeros(length(fca96e_trials), 1);

for i=9:9 %length(fca96e_trials)
    trialNum = num2str(fca96e_trials(i));
    fileName = strcat('../data/fca96e/Aperture-', trialNum);
    load(fileName);
    data = Aper.data(:,3);
    Fs_aper = Aper.info.SamplingRateHz;
    Aper_time = (0:length(Aper.data(:,1))-1)/Fs_aper;
    
    if fca96e_practiceTrials(i) == 1
        [startTime(i), endTime(i)] = aper_startANDendTimes(data, Aper_time, 'yes');
    elseif fca96e_practiceTrials(i) == 0
        [startTime(i), endTime(i)] = aper_startANDendTimes(data, Aper_time, 'no');
    else
        error('practiceTrials array must only include 0s and 1s');
    end
    
    [data, epochs] = removeStim_fast(fileName, startTime(i), endTime(i));
    
    %% Filter and common average reference
    load(fileName);
    fs_wave = Wave.info.SamplingRateHz; % sampling rate of the wave data (Hz)
    
    load('../data/fca96e/montage');
    Montage.Montage = 64;
    Montage.BadChannels = [4 5];
    
    sig = cell(size(data));
    bpsig = cell(size(data));
    for j=1:length(data)
        sig{j} = ReferenceCAR(Montage.Montage, Montage.BadChannels, data{j});
        sig{j} = notch(sig{j}, [60 120 180], fs_wave, 4);
        bpsig{j} = highpass(sig{j}, 1, fs_wave, 4);
    end
    
    %% Plv analysis
    badChans = Montage.BadChannels;
    fs = fs_wave;
    connectivityRHI_par_short
    
end

fileNameSave = strcat('analysis/', sid, '_startANDendTimes');
save(fileNameSave, 'startTime', 'endTime');






