function [] = aper_ANALYSIS_justR2(sid, pathToSave, fileName, trialNum)
% Aper ANALYSIS

%% Initialize
load(fileName);
Fs_aper = Aper.info.SamplingRateHz;

%% Load start time and end time 
load(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum));
startSampAper = floor(startTime*Fs_aper);
endSampAper = floor(endTime*Fs_aper);
data = Aper.data(startSampAper:endSampAper,1);
high_boundary = Aper.data(startSampAper:endSampAper,2);
low_boundary = Aper.data(startSampAper:endSampAper,3);

%% Line fit, R^2
% Predicted = target 'boundary'
% Actual/observed = actual hand aperture value
entersTarget = find(data < high_boundary & data > low_boundary, 1); % + startSamp-1;
center_boundary = (high_boundary(entersTarget:end) + low_boundary(entersTarget:end))./2;
data_entered = data(entersTarget:end);

% SSResid_center = sum((data_entered-center_boundary).^2);
% SSTo = sum((data_entered-mean(data_entered)).^2);
% r2_center = 1-SSResid_center/SSTo;

% % Determine the chance level of the R^2 value using the shuffled positions
% % from the accuracy chance calculation
% SSResid_center_chance = zeros(1, 1000);
% SSTo_chance = zeros(1, 1000);
% r2_center_chance = zeros(1, 1000);
% for i =1:1000
%     SSResid_center_chance(1, i) = sum((pos_shuffled(:,i)-center_boundary).^2);
%     SSTo_chance(1, i) = sum((pos_shuffled(:,i)-mean(pos_shuffled(:,i))).^2);
%     r2_center_chance(1, i) = 1-SSResid_center_chance(1, i)/SSTo_chance(1, i);
% end
% r2_chance = mean(r2_center_chance);

%% Save R^2 values 
save(strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\r2_analysis\', sid, '_R2_dataArrays_', trialNum),...
    'center_boundary', 'data_entered');
end

