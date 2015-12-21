% Compare aper categories

sid = 'fca96e';
fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];

%% 1-way ANOVA of the low HG power
p=zeros(length(fca96e_trials), 64);
    
for i=1:length(fca96e_trials)
    trialNum = num2str(fca96e_trials(i));
    % load(strcat('C:\Users\jcronin\Box Sync\Code\Matlab\Experiments\Aperture_Analysis\Hyak copies\PLV\analysis\fca96e_PLVcut_trial_',trialNum));
    load(strcat('/Users/jcronin/Box Sync/Code/Matlab/Experiments/Aperture_Analysis/Hyak copies/PLV/analysis/fca96e_PLVcut_trial_', trialNum));
    meanPwr = cellfun(@mean, lowHGPower, 'UniformOutput', false);
    meanPwr = cell2mat(meanPwr);

    
    for j=1:size(meanPwr,2)
        p(i,j)=anova1(meanPwr(:,j), category, 'off');
    end
    
    % categoryCell = mat2cell(repmat(category', 64, 1), R);
    % categoryCell = cellfun(@ctranspose, categoryCell, 'UniformOutput', false);
    % for i=1:length(c)
    %     meanPwr_perElectrode{i} = cell2mat(cellfun(@(v) v(i), meanPwr, 'UniformOutput', false));
    % end
    
end
% Save
save('/Users/jcronin/Box Sync/Code/Matlab/Experiments/Aperture_Analysis/Hyak copies/PLV/analysis/Anova1','p');


%% Split no, low, and high stim
load('C:\Users\jcronin\Box Sync\Code\Matlab\Experiments\Aperture_Analysis\Hyak copies\PLV\analysis\fca96e_allEPOCHS.mat')
dataShort_noStim = cell(size(dataShortALL));
dataShort_low = cell(size(dataShortALL));
dataShort_high = cell(size(dataShortALL));

for i=1:length(dataShortALL)
    dataShort_noStim{i} = dataShortALL{i}(categoryALL{i}==1);
    dataShort_low{i} = dataShortALL{i}(categoryALL{i}==2);
    dataShort_high{i} = dataShortALL{i}(categoryALL{i}==3);
end

%% Compute average PLV's (alpha and Beta) across the low-intensity state (category 2)
mean_alphaPlv_low = zeros(64, 64, length(fca96e_trials));
mean_betaPlv_low = zeros(64, 64, length(fca96e_trials));
mean_maskedalphaPlvs_low = zeros(64, 64, length(fca96e_trials));
mean_maskedbetaPlvs_low = zeros(64, 64, length(fca96e_trials));

for i=1:length(fca96e_trials)
    trialNum = num2str(fca96e_trials(6));
    load(strcat('/Users/jcronin/Box Sync/Code/Matlab/Experiments/Aperture_Analysis/Hyak copies/PLV/analysis/fca96e_PLVcut_trial_', trialNum));
    
    alphaPlv_low = alphaPlv(:,:,category==2);
    betaPlv_low = betaPlv(:,:,category==2);
    maskedalphaPlvs_low = maskedalphaPlvs(:,:,category==2);
    maskedbetaPlvs_low = maskedbetaPlvs(:,:,category==2);
    
    mean_alphaPlv_low(:,:,i) = mean(alphaPlv_low,3);
    mean_betaPlv_low(:,:,i) = mean(betaPlv_low,3);
    mean_maskedalphaPlvs_low(:,:,i) = mean(maskedalphaPlvs_low,3);
    mean_maskedbetaPlvs_low(:,:,i) = mean(maskedbetaPlvs_low,3);
end

% Save
save('/Users/jcronin/Box Sync/Code/Matlab/Experiments/Aperture_Analysis/Hyak copies/PLV/analysis/PLVs_lowState',...
    'mean_alphaPlv_low', 'mean_betaPlv_low', 'mean_maskedalphaPlvs_low','mean_maskedbetaPlvs_low');
    