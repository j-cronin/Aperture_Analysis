%% PLV analysis
% addpath('C:\Users\jcronin\Box Sync\Code\Matlab\SigAnal');
% addpath('/Users/jcronin/Box Sync/Code/Matlab/SigAnal');

parpool(16)

warning('off','all')

sid = 'fca96e';
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];
fca96e_practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];

% Initialize
startTime = zeros(length(fca96e_trials), 1);
endTime = zeros(length(fca96e_trials), 1);
modeLength = zeros(length(fca96e_trials), 1);
categoryALL = cell([length(fca96e_trials), 1]);
data_epoched = cell([length(fca96e_trials), 1]);
dataShortALL = cell([length(fca96e_trials), 1]);

for i=1:length(fca96e_trials)
    trialNum = num2str(fca96e_trials(i));
    fileName = strcat('../data/fca96e/Aperture-', trialNum);
%     fileName = strcat('C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-', trialNum);
%     fileName = strcat('/Users/jcronin/Box Sync/Lab/Temp data/fca96e/Aperture-', trialNum);
    load(fileName);
    Fs_aper = Aper.info.SamplingRateHz;
    Aper_time = (0:length(Aper.data(:,1))-1)/Fs_aper;
    
    if fca96e_practiceTrials(i) == 1
        [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'yes');
    elseif fca96e_practiceTrials(i) == 0
        [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'no');
    else
        error('practiceTrials array must only include 0s and 1s');
    end
    
    [data_epoched{i}, epochs, category] = removeStim_fast(fileName, startTime(i), endTime(i), 1);
    data = data_epoched{i};
    epoch_lengths = cellfun(@length, data);
    modeLength(i) = mode(epoch_lengths);
    noStim = find(category==1);
    if ~isempty(noStim)
        cuts = floor(cellfun(@length, data(noStim))/modeLength(i));
        noStimCount = sum(cuts);
        dataWithCuts = cell([epochs-length(noStim)+noStimCount,1]);
        categoryWithCuts = zeros(epochs-length(noStim)+noStimCount,1);
        
        dataWithCuts(1:noStim(1)-1) = data(1:noStim(1)-1);
        categoryWithCuts(1:noStim(1)-1) = category(1:noStim(1)-1);
        idx = noStim(1);
        for j=1:cuts(1)
            dataWithCuts{idx} = data{noStim(1)}(modeLength(i)*(j-1) + 1:modeLength(i)*j,:);
            categoryWithCuts(idx) = 1;
            idx = idx+1;
        end
        
        for k=2:length(noStim)
            dataWithCuts(idx:idx+(noStim(k)-noStim(k-1)-2)) = data(noStim(k-1)+1:noStim(k)-1);
            categoryWithCuts(idx:idx+(noStim(k)-noStim(k-1)-2)) = category(noStim(k-1)+1:noStim(k)-1);
            idx = idx+noStim(k)-noStim(k-1)-1;
            for j=1:cuts(k)
                dataWithCuts{idx} = data{noStim(k)}(modeLength(i)*(j-1) + 1:modeLength(i)*j,:);
                categoryWithCuts(idx) = 1;
                idx = idx+1;
            end
        end
        dataWithCuts(idx:end) = data(noStim(end)+1:end);
        categoryWithCuts(idx:end) = category(noStim(end)+1:end);
    else
        dataWithCuts = data;
        categoryWithCuts = category;
    end
    
    epochs = length(dataWithCuts);
    epoch_lengths = cellfun(@length, dataWithCuts);
    tooShort = find(epoch_lengths<modeLength(i));
    dataShort = cell([length(dataWithCuts)-length(tooShort), 1]);
    categoryShort = zeros(length(categoryWithCuts)-length(tooShort), 1);
    idx=1;
    for j=1:epochs
        if length(dataWithCuts{j})>modeLength(i)
            dataShort{idx} = dataWithCuts{j}(1:modeLength(i),:);
            categoryShort(idx) = categoryWithCuts(j);
            idx=idx+1;
        elseif length(dataWithCuts{j})== modeLength(i)
            dataShort(idx) = dataWithCuts(j);
            categoryShort(idx) = categoryWithCuts(j);
            idx=idx+1;
        end
    end
    
    epochs = length(dataShort);
    data = dataShort;
    category = categoryShort;
    categoryALL{i} = category;
    dataShortALL{i} = dataShort;
    
    
    %% Filter and common average reference
    fs_wave = Wave.info.SamplingRateHz; % sampling rate of the wave data (Hz)
    
    load('../data/fca96e/montage');
%     load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\montage');
%     load('/Users/jcronin/Box Sync/Lab/ECoG/Aperture/Data Analysis/fca96e/montage');
    Montage.Montage = 64;
    Montage.BadChannels = [4 5];
    
    sig = cell(size(data));
    bpsig = cell(size(data));
    for k=1:length(data)
        sig{k} = ReferenceCAR(Montage.Montage, Montage.BadChannels, data{k});
        sig{k} = notch(sig{k}, [60 120 180], fs_wave, 4);
        bpsig{k} = highpass(sig{k}, 1, fs_wave, 4);
    end
    
    %% Plv analysis
    badChans = Montage.BadChannels;
    fs = fs_wave;
    data = bpsig;
    connectivityRHI_par
    
end

fileNameSave = strcat('analysis/', sid, '_startANDendTimes');
% fileNameSave = strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\PLVs\', sid, '_startANDendTimes');
% fileNameSave = strcat('/Users/jcronin/Box Sync/Lab/ECoG/Aperture/Data Analysis/PLVs/', sid, '_startANDendTimes');
save(fileNameSave, 'startTime', 'endTime');

fileNameSave = strcat('analysis/', sid, '_allEPOCHS');
% fileNameSave = strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\PLVs\', sid, '_allEPOCHS');
% fileNameSave = strcat('/Users/jcronin/Box Sync/Lab/ECoG/Aperture/Data Analysis/PLVs/', sid, '_allEPOCHS');
save(fileNameSave, 'data_epoched', 'dataShortALL', 'modeLength', 'categoryALL');
