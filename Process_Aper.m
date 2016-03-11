%% Process data Aperture

% Subject specific:
sid = 'fca96e';
filePath = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-';
stims = [4 5];
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];
fca96e_practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];

% Initialize vectors for saving trial by trial values
startTime = zeros(length(fca96e_trials), 1);
endTime = zeros(length(fca96e_trials), 1);

for i=9:9 %length(fca96e_trials)
    trialNum = num2str(fca96e_trials(i));
    fileName = strcat(filePath, trialNum);
    load(fileName);
    aper = Aper.data(:,3);
    fs_aper = Aper.info.SamplingRateHz; % sampling rate of the stim data (Hz)
    t_aper = (0:1:length(Aper.data(:,1))-1)/fs_aper; % stim timing (s)

    
    if fca96e_practiceTrials(i) == 1
        [startTime(i), endTime(i)] = aper_startANDendTimes(aper, t_aper, 'yes');
    elseif fca96e_practiceTrials(i) == 0
        [startTime(i), endTime(i)] = aper_startANDendTimes(aper, t_aper, 'no');
    else
        error('practiceTrials array must only include 0s and 1s');
    end
    
    epochSignal = ExtractNeuralData_Aper(filePath, fca96e_trials(i), startTime(i), endTime(i));
    
end