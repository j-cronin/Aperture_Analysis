%% Choose the analysis types that you want to run, can be:
% chance, responseTiming, R2...
% analysisTypes = {'chance'}; % Finish this later - could set up so that you can enter whichever analyses you want to run


%%
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\DataGlove');
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\SigAnal');

% SIDS = {'ecb43e' 'fca96e' 'cdceeb'};
SIDS = {'cdceeb'};

%SIDS = SIDS(2);

for idx = 1:length(SIDS)
    sid = SIDS{idx};
    
    switch(sid)
        case 'ecb43e'
            wp = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\'; % write path
            rp_matlab = 'C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\'; % read path for Matlab data (includes glove data)
            rp = strcat(rp_matlab, 'Matlab, Aperture\Aperture_ecb43e-'); % read path TDT data
            %'C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-'; % read path TDT data
            trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];
            practiceTrials = zeros(size(trials)); % 1: practice trial with straight beginning and then sine wave
            trials_NV = [4 9 10 11 12 13 14 15 16 18 19]; % trials w/o visual feedback
            trials_matlab = {'20150406T145822_trial1'
                '20150406T150020_trial2'
                '20150406T150511_trial3'
                '20150406T150829_trial4'
                '20150406T151409_trial5'
                '20150406T151735_trial6'
                '20150406T152143_trial7'
                '20150406T152520_trial8'
                '20150406T153041_trial9'
                '20150406T153342_trial10'
                '20150406T153641_trial11'
                '20150406T153951_trial12'
                '20150406T154321_trial13'
                '20150406T155446_trial14'
                '20150406T155805_trial15'};
            matlab_prefix = 'apertureTask_ecb43e_';
            stims = [46 47];
            badChans = [];
            
        case 'fca96e'
            wp = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\'; % write path
            rp_matlab = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\'; % read path for Matlab data (includes glove data)
            rp = strcat(rp_matlab, 'Matlab\Aperture-'); % read path TDT data
            trials = [2 5 7 8 9 10 12 13 15 16 17];
            practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];
            trials_NV = [5 7 8 9 10 17]; % trials w/o visual feedback
            trials_matlab = {'20150706T104116_trial1-'
                '20150706T110029_trial2'
                '20150706T110640_trial3-7'
                '20150706T111113_trial4-8'
                '20150706T111554_trial5-9'
                '20150706T111852_trial6-10'
                '20150706T113115_trial7-12'
                '20150706T113435_trial8-13'
                '20150706T114309_trial9-15'
                '20150706T114919_trial10-16'
                '20150706T115311_trial11-17'};
            matlab_prefix = 'apertureTask_fca96e_';
            stims = [4 5];
            badChans = [];
        case 'cdceeb'
            wp = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb\'; % write path
            rp_matlab = 'C:\Users\jcronin\Data\Subjects\cdceeb (wrong-f3e511)\data\d14\Aperture_cdceeb\'; % read path for Matlab data (includes glove data)
            rp = strcat(rp_matlab, 'Matlab\ApertureCheck-'); % read path TDT data
            trials = [1 2 3];
            practiceTrials = zeros(size(trials));
            trials_NV = [1 2 3]; % trials w/o visual feedback
            trials_matlab = {'20150316T165011'
                '20150316T165447'
                '20150316T170323'};
            matlab_prefix = 'apertureTask_Practice_cdceeb_';
            
            stims = [4 5]; % FIX THIS!!
            badChans = [];
        otherwise
            error('unknown SID entered');
    end
    %     chans(ismember(chans, stims)) = [];
    
    
    
    %% Execute functions on subject data
    %% Get glove means
    %     [gloveRawMean] = getGloveMeans(sid, trials_matlab, matlab_prefix, rp_matlab);
    %     pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\gloveMeans\';
    %     % Save
    %     save(strcat(pathToSave, sid, '_gloveMeans'), 'gloveRawMean');
    
    startTime = zeros(1, length(trials));
    endTime = zeros(1, length(trials));
    %     pos_shuffled = cell(1, length(trials));
    %     entersTarget = zeros(1, length(trials));
    accuracy = zeros(1, length(trials));
    chanceAccuracy = zeros(1, length(trials));
    std_chanceAccuracy = zeros(1, length(trials));
    rsq = zeros(1, length(trials));
    chanceRsq = zeros(1, length(trials));
    std_chanceRsq = zeros(1, length(trials));
    responseTime_open = cell(length(trials), 1);
    responseTime_closed = cell(length(trials), 1);
    correctionTime_open = cell(length(trials), 1);
    correctionTime_closed = cell(length(trials), 1);
    
    for i=1:length(trials)
        % Initialize
        trialNum = num2str(trials(i));
        fileName = strcat(rp, trialNum); % read path
        load(fileName);
        
        Fs_aper = Aper.info.SamplingRateHz;
        Aper_time = (0:length(Aper.data(:,1))-1)/Fs_aper;
        Fs_stim = Stim.info.SamplingRateHz;
        Stim_time = (0:length(Stim.data(:,1))-1)/Fs_stim;
        
        % Determine start time and end time
        if practiceTrials(i) == 1
            [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'yes');
        elseif practiceTrials(i) == 0
            [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'no');
        else
            error('practiceTrials array must only include 0s and 1s');
        end
        
        startSampAper = floor(startTime(i)*Fs_aper);
        endSampAper = floor(endTime(i)*Fs_aper);
        data = Aper.data(startSampAper:endSampAper,1);
        high_boundary = Aper.data(startSampAper:endSampAper,2);
        low_boundary = Aper.data(startSampAper:endSampAper,3);
        startSampStim = floor(startTime(i)*Fs_stim);
        endSampStim = floor(endTime(i)*Fs_stim);
        
        % Get filtered signal and find the points of significant change in movement
        [locs_movement, data_interp, data_filt, dx3] = aper_coherence_3(Aper, Stim, startTime(i), endTime(i));
        
        % Find when the stim changes state
        ITI0 = max(Stm0.data(:,11));
        ITI1 = max(Stm1.data(:,11));
        if strcmp(sid, 'cdceeb')
            amp0 = max(Stm0.data(:,1))/2; % because amp was divided across two electrodes
            amp1 = max(Stm1.data(:,1))/2;
        else
            amp0 = max(Stm0.data(:,1));
            amp1 = max(Stm1.data(:,1));
        end
        PTD = max(Stm0.data(:,8));
        IPI = max(Stm0.data(:,5));
        [stimChanges, stimPks, ~] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI0, ITI1, amp0, amp1, PTD, IPI, 'on');
        % Change stimChanges to represent Aper samples rather than Stim samples
        stimChanges_aperSamps = floor(stimChanges/Fs_stim*Fs_aper);
        
        % Response timing
        [responseTime_open{i}, responseTime_closed{i}] = aper_responseTime(locs_movement, stimChanges_aperSamps, stimPks, Stm1, Fs_aper, amp1);
        
        % Correction timing
        locs_reenters_open = find(data(1:end-1)>high_boundary(1:end-1) & data(2:end)<high_boundary(2:end));
        locs_reenters_closed = find(data(1:end-1)<low_boundary(1:end-1) & data(2:end)>low_boundary(2:end));
        
        [correctionTime_open{i}, correctionTime_closed{i}] = aper_correctionTime(locs_reenters_open, locs_reenters_closed, stimChanges_aperSamps, stimPks, Stm1, Fs_aper);
        
%         % Accuracy:
%         accuracy(i) = sum(data < high_boundary & data > low_boundary)/length(data);
%         % Chance accuracy calculations:
%         [pos_shuffled, entersTarget, chanceAccuracy(i), std_chanceAccuracy(i)] = aper_chanceAccuracy(data, data_interp, high_boundary, low_boundary);
%         
%         % R^2
%         center_boundary = (high_boundary(entersTarget:end) + low_boundary(entersTarget:end))./2;
%         [rsq(i)] = lmrsquare(center_boundary, data(entersTarget:end));
%         % Chance R^2 calculations:
%         [chanceRsq, std_chanceRsq] = rsquare_chance(center_boundary, pos_shuffled);
    end
    
    % Save
    %     save_path = strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\', sid, '_accuracy');
    %     save(save_path, 'startTime', 'endTime', 'accuracy', 'chanceAccuracy', 'std_chanceAccuracy', 'rsq', 'chanceRsq', 'std_chanceRsq');
    
    % Save just response times
    save_path = strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ResponseTimes\', sid, '_ResponseTiming');
    save(save_path, 'responseTime_open', 'responseTime_closed', 'correctionTime_open', 'correctionTime_closed');
end