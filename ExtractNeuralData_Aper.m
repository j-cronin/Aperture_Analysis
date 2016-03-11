%function [epochSignal] = ExtractNeuralData_Aper(filePath, trial, startTime, endTime)
clear all, close all

% Subject specific:
sid = 'fca96e';
filePath = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-';
stims = [4 5];
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];
fca96e_practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];

% Initialize vectors for saving trial by trial values


for i=9:9 %length(fca96e_trials)
    close all
    trialNum = num2str(fca96e_trials(i));
    fileName = strcat(filePath, trialNum);
    load(fileName);
    wave = Wave; % ECoG data
    stim = Stim; % Stim data
    aper = Aper;
    amp0 = max(Stm0.data(:,1));
    amp1 = max(Stm1.data(:,1));
    IPI_us = max(Stm0.data(:,7));
    ITI_ms1 = max(Stm1.data(:,13)); % This is the shorter ITI of the two stim waveforms
    clear Wave Stim Aper Stm0 Stm1 Ctch Task
    
    % Pull sampling rates and times:
    fs_stim = stim.info.SamplingRateHz; % sampling rate of the stim data (Hz)
    t_stim = (0:1:length(stim.data(:,1))-1)/fs_stim; % stim timing (s)
    fs_wave = wave.info.SamplingRateHz; % sampling rate of the wave data (Hz)
    fs_aper = aper.info.SamplingRateHz; % sampling rate of the stim data (Hz)
    t_aper = (0:1:length(aper.data(:,1))-1)/fs_aper; % stim timing (s)
    break
    if fca96e_practiceTrials(i) == 1
        [startTime, endTime] = aper_startANDendTimes(aper.data(:,3), t_aper, 'yes');
    elseif fca96e_practiceTrials(i) == 0
        [startTime, endTime] = aper_startANDendTimes(aper.data(:,3), t_aper, 'no');
    else
        error('practiceTrials array must only include 0s and 1s');
    end
    clear aper
    
    % Only want to consider the ECoG data after the trial began, to cut out
    % any spurious stim waveforms that weren't actually delivered because
    % stim wasn't armed.
    % Cut out the times before the trial began (stim turned on)and the last
    % seconds at the end:
    startSampECoG = floor(startTime*fs_wave);
    endSampECoG = floor(endTime*fs_wave);
    ecog = wave.data(startSampECoG:endSampECoG, :);
    t_wave = (0:1:length(ecog(:,1))-1)/fs_wave; % wave timing (s)
    clear wave
    
    % Get stim burst locations:
    [stimTable, PD] = StimTable(stim.data(:,4), fs_stim, IPI_us);
    
    % Convert the stim start and end sample numbers from stim samples to ECoG
    % wave samples (ECoG was sampled slower) and account for delay between
    % setting the stim output and recording stim output (stimTable was based
    % off of setting the IZ current output and there's delay between setting
    % the current and getting the voltage spike):
    fac = fs_stim/fs_wave;
    
    % Automate the delay detection:
    [~, loc_realized] = findpeaks(stim.data(:,5)/max(stim.data(:,5)),'NPeaks',1, 'MinPeakHeight', 0.5);
    % find the first instance when a value in the 1st row of stimTable (the
    % burst starts) is less than loc_realized, starting from the end of the
    % stimTable, and then add the pulse duration/2 to get to the last high
    % sample of the biphasic pulse:
    loc_set = find(stimTable(1,:)<loc_realized, 1, 'last');
    loc_set = stimTable(1,loc_set)+PD/2;
    delay = abs(loc_realized-loc_set);
    
    % Visualize delay:
    figure(2), hold off
    subplot(2,1,1), plot(stim.data(:,4)/max(stim.data(:,4)), 'k')
    hold on, plot(stim.data(:,5)/max(stim.data(:,5)), 'r')
    scatter(loc_realized, stim.data(loc_realized, 5)/max(stim.data(:,5)), 'c', 'filled')
    scatter(loc_set, stim.data(loc_set, 4)/max(stim.data(:,4)), 'y', 'filled')
    title('Delay, not shifted')
    subplot(2,1,2), plot(t_stim+delay/fs_stim, stim.data(:,4)/max(stim.data(:,4)), 'k')
    hold on, plot(t_stim, stim.data(:,5)/max(stim.data(:,5)), 'r')
    title('Shifted')
    
    % Convert the stim start and end sample numbers from stim samples to
    % ECoG wave samples:
    burstStarts = floor((stimTable(1,:)+delay)/fac);
    burstEnds = floor((stimTable(2,:)+delay)/fac);
    % Categorize the signal based on the amplitudes from the stimTable
    % low intensity = 2; high intensity = 3; no stim = 1 (this is optional
    % and will be added later)
    category = zeros(size(burstStarts));
    for idx=1:length(burstStarts)
        if stimTable(3,idx) == amp0
            category(idx) = 2;
        elseif stimTable(3,idx)== amp1
            category(idx) = 3;
        end
    end
    
    % Cut out and burst sample numbers after the stim is unarmed at the
    % end:
    burstStarts = burstStarts(burstStarts<endSampECoG);
    burstEnds = burstEnds(burstEnds<endSampECoG);
    % Also shift the sample numbers to cut out the time before the stim was
    % armed:
    burstStarts = burstStarts - startSampECoG;
    burstEnds = burstEnds - startSampECoG;
    % Since more ends could get cut than starts, check lengths and cut
    % starts from the end if they don't have a corresponding end
    if length(burstStarts)>length(burstEnds)
        burstStarts = burstStarts(1:length(burstEnds));
    end
    
    % Cut out any negative sample numbers due to stim not being armed
    % yet:
    temp = burstStarts>0;
    burstStarts = burstStarts(temp);
    burstEnds = burstEnds(temp);
    category = category(temp);
    
    % Visualize the burst starts and stops over the ECoG data
    figure(3)
    subplot(2,1,1)
    plot(t_wave, ecog(:,1),'k')
    hold on, scatter(burstStarts/fs_wave, zeros(size(burstStarts)), 'g')
    scatter(burstEnds/fs_wave, zeros(size(burstEnds)), 'r')
    %xlim([20.1 20.5]) % To zoom in
    
    % Account for additional delay in ecog data (this will differ slightly
    % from channel to channel, but will just pick one delay:
    Rdelay = 0.01; % recording delay (seconds)
    burstStarts = burstStarts + Rdelay*fs_wave;
    burstEnds = burstEnds + Rdelay*fs_wave;
    subplot(2,1,2)
    plot(t_wave, ecog(:,1),'k')
    hold on, scatter(burstStarts/fs_wave, zeros(size(burstStarts)), 'g')
    scatter(burstEnds/fs_wave, zeros(size(burstEnds)), 'r')
    %xlim([20.1 20.5]) % To zoom in
    
    %% (1) Segment with stim bursts
    % Samps to look before and after:
    presamps = round(0.025 * fs_wave); % pre time in sec
    postsamps = round(ITI_ms1*1e-3*fs_wave-presamps-1); % post time in sec, % modified JAC to look at the shorter ITI
    
    % Discard any burstStarts/Ends that are too close to one another. When
    % segmented the epochs will contain chunks of two bursts or be too
    % short:
    temp = burstStarts(2:end) - burstEnds(1:end-1)>=postsamps;
    burstStarts = burstStarts(temp);
    burstEnds = burstEnds(temp);
    category = category(temp);
    
    % Extract neural data, don't look at last burst set:
    epochSig = getEpochSignal(ecog, burstStarts(1:end-1)-presamps, burstEnds(1:end-1)+postsamps);
    
    % Consider epoched signals of the same length (this will disregard ones
    % that are too short due to a change in the stim intensity). Also
    % delete categories that we're dropping
    len = mode(burstEnds(1:end-1)+postsamps-(burstStarts(1:end-1)-presamps));
    temp = cellfun(@length, epochSig(1,:), 'UniformOutput', true)>=len-1;
    epochSig = epochSig(:,temp);
    category = category(temp);
    temp = cellfun(@length, epochSig(1,:), 'UniformOutput', true)>len-1;
    epochSig(:,temp) = cellfun(@(s)s(1:len-1), epochSig(:,temp), 'UniformOutput', false);
    
    % Sometimes epochs get spurious peak (e.g. trial 9, epoch 2, most
    % channels). Need to disregard these epochs. Look for spikes in the
    % data by comparing mean diffs to max diffs. Epochs with a large max
    % diff compared to the mean probably contain a spurious spike
    meanDiff = cellfun(@(s)mean(abs(diff(s))), epochSig, 'UniformOutput', true);
    maxDiff = cellfun(@(s)max(abs(diff(s))), epochSig, 'UniformOutput', true);
    frac = mean(maxDiff./meanDiff,1); % average across channels, because these spikes seem to show up in all of them
    % Drop epochs that are greater than one std dev from mean of (max/mean):
    temp = frac>mean(frac)+std(frac);
    epochSig = epochSig(:,~temp);
    category = category(~temp);
    
    % Visualize epoched signal:
    %         figure(4)
    %         for epoch=1:size(epochSig,2)
    %             plot(epochSig{1,epoch}), title(strcat('Each ind. epoch, Ch. 1, epoch #: ', num2str(epoch)))
    %             pause(0.5)
    %         end
    %     for chan=1:64
    %         plot(epochSig{chan,40}), title(strcat('Each ind. channel for epoch 40, Ch. #: ', num2str(chan)))
    %         pause(1)
    %     end
    
    % Visualize the mean signal with stim
    %     figure(5)
    
    % Convert cell of epochs to matrix (time x channel x epochs)
    epochMat = zeros(length(epochSig{1,1}), size(epochSig,1), size(epochSig,2));
    epochSig=epochSig';
    for idx = 1:size(epochSig,1)
        epochMat(:,:,idx) = cell2mat(epochSig(idx,:));
    end
    
    %% Save segments with stim
    sp = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Segmented\';
    fileNameSave = strcat(sp, 'fca96e_epoched_stim_', trialNum);
    save(fileNameSave, 'epochMat', 'category')
    
    %% (2) Segment w/o stim burst (in between the bursts)
    % Reset category:
    category = zeros(size(stimTable(3,idx)));
    for idx=1:length(burstStarts)
        if stimTable(3,idx) == amp0
            category(idx) = 2;
        elseif stimTable(3,idx)== amp1
            category(idx) = 3;
        end
    end
    
    % Because I want NO stim at all, need to shift starts and ends outwards
    % slightly
    presamps = floor(0.0025*fs_wave);
    postsamps = floor(0.0065*fs_wave);
    burstEnds = burstEnds + postsamps;
    burstStarts = burstStarts - presamps;
    
    % Visualize the burst starts and stops over the ECoG data
    %     figure(6)
    %     plot(t_wave, ecog(:,1),'k')
    %     hold on, scatter(burstStarts/fs_wave, zeros(size(burstStarts)), 'g')
    %     scatter(burstEnds/fs_wave, zeros(size(burstEnds)), 'r')
    %     xlim([20.1 20.5]) % To zoom in
    
    % Extract neural data between each burst, don't consider the ECoG
    % activity after the final burst:
    epochSig = getEpochSignal(ecog, burstEnds(1:end-1), burstStarts(2:end));
    
    % Only keep the epochs that are long enough (greater than or equal to
    % the shortert ITI). Delete categories that we're dropping
    len = floor(ITI_ms1*1e-3*fs_wave)-presamps-postsamps-1;
    temp = cellfun(@length, epochSig(1,:), 'UniformOutput', true)>=len;
    epochSig = epochSig(:,temp);
    category = category(temp);
    temp = cellfun(@length, epochSig(1,:), 'UniformOutput', true)>len;
    epochSig(:,temp) = cellfun(@(s)s(1:len), epochSig(:,temp), 'UniformOutput', false);
    
    % Sometimes epochs get spurious peak (e.g. trial 9, epoch 2, most
    % channels). Need to disregard these epochs. Look for spikes in the
    % data by comparing mean diffs to max diffs. Epochs with a large max
    % diff compared to the mean probably contain a spurious spike
    meanDiff = cellfun(@(s)mean(abs(diff(s))), epochSig, 'UniformOutput', true);
    maxDiff = cellfun(@(s)max(abs(diff(s))), epochSig, 'UniformOutput', true);
    frac = mean(maxDiff./meanDiff,1); % average across channels, because these spikes seem to show up in all of them
    % Drop epochs that are greater than one std dev from mean of (max/mean):
    temp = frac>mean(frac)+std(frac);
    epochSig = epochSig(:,~temp);
    category = category(~temp);
    
    % Visualize epoched signal:
    %     figure(4)
    %     for epoch=1:size(epochSig,2)
    %         plot(epochSig{1,epoch}), title(strcat('Each ind. epoch, Ch. 1, epoch #: ', num2str(epoch)))
    %         pause(0.5)
    %     end
    %     for chan=1:64
    %         plot(epochSig{chan,40}), title(strcat('Each ind. channel for epoch 40, Ch. #: ', num2str(chan)))
    %         pause(0.25)
    %     end
    
    % Convert cell of epochs to matrix (time x channel x epochs)
    epochMat = zeros(length(epochSig{1,1}), size(epochSig,1), size(epochSig,2));
    epochSig=epochSig';
    for idx = 1:size(epochSig,1)
        epochMat(:,:,idx) = cell2mat(epochSig(idx,:));
    end
    
    %% Save segments with stim
    sp = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Segmented\';
    fileNameSave = strcat(sp, 'fca96e_epoched_', trialNum);
    save(fileNameSave, 'epochMat', 'category')
    
end