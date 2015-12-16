function [] = aper_ANALYSIS(sid, pathToSave, fileName, trialNum, practiceTrials)
% Aper ANALYSIS



%% Initialize
load(fileName);
Fs_aper = Aper.info.SamplingRateHz;
Aper_time = (0:length(Aper.data(:,1))-1)/Fs_aper;
Fs_stim = Stim.info.SamplingRateHz;
Stim_time = (0:length(Stim.data(:,1))-1)/Fs_stim;
startTime = zeros(length(fca96e_trials), 1);
endTime = zeros(length(fca96e_trials), 1);

%% Determine start time and end time 
    if practiceTrials(i) == 1
        [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'yes');
    elseif practiceTrials(i) == 0
        [startTime(i), endTime(i)] = aper_startANDendTimes(Aper.data(:,3), Aper_time, 'no');
    else
        error('practiceTrials array must only include 0s and 1s');
    end

% Plot all aper data with start and end times overlaid
% figure
% plot(Aper_time, Aper.data(:,1)); hold on; 
% plot(Aper_time, Aper.data(:,2),'r'); plot(Aper_time, Aper.data(:,3),'r')
% stem(startTime, max(Aper.data(:,2)), 'g')
% stem(endTime, max(Aper.data(:,2)), 'k')
% title(strcat('Trial #: ', num2str(trialNum)))
% 
% startSampAper = floor(startTime*Fs_aper);
% endSampAper = floor(endTime*Fs_aper);
% data = Aper.data(startSampAper:endSampAper,1);
% high_boundary = Aper.data(startSampAper:endSampAper,2);
% low_boundary = Aper.data(startSampAper:endSampAper,3);
% Aper_time2 = (0:length(data)-1)/Fs_aper;
% 
% startSampStim = floor(startTime*Fs_stim);
% endSampStim = floor(endTime*Fs_stim);

%% Find when the stim changes state
ITI = max(Stm0.data(:,11));
PTD = max(Stm0.data(:,8));
IPI = max(Stm0.data(:,5));
[stimChanges, stimPks] = StimStarts(Stim.data(startSampStim:endSampStim,4), Fs_stim, ITI, PTD, IPI, 'on');

% Change stimChanges to represent Aper samples rather than Stim samples
stimChanges_aperSamps = [floor(stimChanges/Fs_stim*Fs_aper)];

%% Find the points of significant change in movement
[locs_movement, data_interp, data_filt, dx3] = aper_coherence_3(Aper, Stim, startTime, endTime);

% % Figure
figure
plot(Aper_time2, data, 'b'); hold on
plot(Aper_time2, high_boundary, 'r')
plot(Aper_time2, low_boundary, 'r')
scatter(Aper_time2(locs_movement), data(locs_movement), 8, 'filled', 'm');
scatter(Aper_time2(stimChanges_aperSamps), data(stimChanges_aperSamps), 8, 'filled', 'k');
legend('data', 'target boundary', 'target boundary', 'Significant movement changes', 'Stim state changes');
ylabel('Aperture value'); xlabel('time (s)');

%% Accuracy
aper_accuracy = sum(data < high_boundary & data > low_boundary)/length(data);

% Chance accuracy calculations:
[pos_shuffled, entersTarget, chanceAccuracy, std_chanceAccuracy] = aper_chanceAccuracy(data, data_interp, high_boundary, low_boundary);

%% Response timing
[responseTime_open, responseTime_closed] = aper_responseTime(locs_movement, stimChanges_aperSamps, stimPks, Stm1, Fs_aper);

% edges_open = 0:50:ceil(max(responseTime_open)/50)*50;
% figure
% hist(responseTime_open, edges_open) % Histogram of the response times in ms
% title('Time after stim error (too open, no stim) to change in movement')
% xlabel('response timing (ms)')
% ylabel('count')
% 
% edges_closed = 0:50:ceil(max(responseTime_closed)/50)*50;
% figure
% hist(responseTime_closed, edges_closed) % Histogram of the response times in ms
% title('Time after stim error (too closed, high intensity stim) to change in movement')
% xlabel('response timing (ms)')
% ylabel('count')

%% Correction timing
locs_reenters_open = find(data(1:end-1)>high_boundary(1:end-1) & data(2:end)<high_boundary(2:end));
locs_reenters_closed = find(data(1:end-1)<low_boundary(1:end-1) & data(2:end)>low_boundary(2:end));

[correctionTime_open, correctionTime_closed ] = aper_correctionTime(locs_reenters_open, locs_reenters_closed, stimChanges_aperSamps, stimPks, Stm1, Fs_aper);

% edges_open = 0:50:ceil(max(correctionTime_open)/50)*50;
% figure
% hist(correctionTime_open, edges_open) % Histogram of the response times in ms
% title('Time after stim error (too open, no stim) to re-entering target region')
% xlabel('correction timing (ms)')
% ylabel('count')
% 
% edges_closed = 0:50:ceil(max(correctionTime_closed)/50)*50;
% figure
% hist(correctionTime_closed, edges_closed) % Histogram of the response times in ms
% title('Time after stim error (too closed, high intensity stim) to re-entering target region')
% xlabel('correction timing (ms)')
% ylabel('count')

%% Line fit, R^2
% Predicted = target 'boundary'
% Actual/observed = actual hand aperture value
entersTarget = find(data < high_boundary & data > low_boundary, 1); % + startSamp-1;
center_boundary = (high_boundary(entersTarget:end) + low_boundary(entersTarget:end))./2;
data_entered = data(entersTarget:end);

SSResid_center = sum((data_entered-center_boundary).^2);
SSTo = sum((data_entered-mean(data_entered)).^2);
r2_center = 1-SSResid_center/SSTo;

SSResid_high = sum((data_entered-high_boundary(entersTarget:end)).^2);
r2_high = 1-SSResid_high/SSTo;

SSResid_low = sum((data_entered-low_boundary(entersTarget:end)).^2);
r2_low = 1-SSResid_low/SSTo;

% Determine the chance level of the R^2 value using the shuffled positions
% from the accuracy chance calculation
SSResid_center_chance = zeros(1, 1000);
SSTo_chance = zeros(1, 1000);
r2_center_chance = zeros(1, 1000);
for i =1:1000
    SSResid_center_chance(1, i) = sum((pos_shuffled(:,i)-center_boundary).^2);
    SSTo_chance(1, i) = sum((pos_shuffled(:,i)-mean(pos_shuffled(:,i))).^2);
    r2_center_chance(1, i) = 1-SSResid_center_chance(1, i)/SSTo_chance(1, i);
end
r2_chance = mean(r2_center_chance);

%% Compute average jerk after state change
window = 5; % in seconds
indeces = [];

for i=1:length(stimChanges_aperSamps)
    indeces = [indeces, (stimChanges_aperSamps(i):(stimChanges_aperSamps(i)+window))];
end

afterStateChange = unique(indeces);
noStateChange = setdiff((1:length(data)), unique(indeces));

dx3_stateChange = dx3(afterStateChange);
dx3_noChange = dx3(noStateChange);

mean(dx3_stateChange);
mean(dx3_noChange);

%% Save all results
% save(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum), 'startTime', 'endTime', 'locs_movement',...
%     'aper_accuracy', 'chanceAccuracy', 'std_chanceAccuracy', 'responseTime_open',...
%     'responseTime_closed', 'correctionTime_open', 'correctionTime_closed',... 
%     'r2_center', 'r2_high', 'r2_low', 'r2_chance');


% save(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum), 'startTime', 'endTime', 'locs_movement',...
%     'aper_accuracy', 'responseTime_open',...
%     'responseTime_closed', 'correctionTime_open', 'correctionTime_closed',... 
%     'r2_center', 'r2_high', 'r2_low', 'r2_chance');

%% Just save R^2 values to re-do
save(strcat(pathToSave, sid, '_AperANALYSIS_R2_', trialNum),...
    'r2_center', 'r2_high', 'r2_low', 'r2_chance');
end

