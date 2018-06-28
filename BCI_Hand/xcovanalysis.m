clear all
params = setupAll('hazelnut');
subjectcount = numel(params.subjects);
% subjectcount = 1;

%% Compute
coeffmaps = zeros(64, 6, subjectcount);
trodelocs = zeros(64, 3, subjectcount);
for subjectnum = 1:subjectcount
    subjis = params.subjects{subjectnum};
    coeffmaps(:, :, subjectnum) = xcov_analyzesubj(subjis, 5, 2);
    trodelocs(:, :, subjectnum) = trodeLocsFromMontagemod(subjis);
end

%% Plot
% for synergynum = 1:size(coeffmaps, 2)
righttrodes = trodelocs;
righttrodes(:, 1, :) = abs(trodelocs(:, 1, :));
%%
for synergynum = 1:size(coeffmaps, 2)

    for subjectnum = 1:subjectcount
        figure
        coeffs = coeffmaps(:, synergynum, subjectnum);
        trodes = righttrodes(:, :, subjectnum);
        % global ranging (same across all)
        % PlotDotsmod('tail', params.talairach, trodes, coeffs, true, 'r', [min(coeffmaps(:)) max(coeffmaps(:))], 9, 'autumn', [], false)
        % local ranging (same for each subject, across synergies)
        PlotDotsmod('tail', params.talairach, trodes, coeffs, true, 'r', [min(min(coeffmaps(:, :, subjectnum))) max(max(coeffmaps(:, :, subjectnum)))], 10, 'autumn', [], false)
        colorbar
        saveallopenfigs(['subj' num2str(subjectnum) '-syn' num2str(synergynum)]);
    end
end

% saveallopenfigs('experiment')

% %% covariance plot
% plot_asgrid(corrmap, 'RD');
% % saveallopenfigs('ebffea_synxcov');
% %% time lag plot
% % load('splitmap');
% % plot_asgrid(lagmap, 'RD', 'relative', splitmap);
% plot_asgrid(lagmap, 'RD');

% bar(corrmap(:, :, 1)')
% scatter3(synergy_ts_filt(1:200:end, 1), synergy_ts_filt(1:200:end, 2), synergy_ts_filt(1:200:end, 3), 5, 'filled')
% scattercloud(calibrated_subjsynts_diff(1, :), calibrated_subjsynts(2, :), 25, 20, 'k+', autumn);

% figure, scattercloud(calibrated_subjsynts_diff(:, 1), subjHG(:, 4), 25, 20, 'k+', autumn);
% figure, scattercloud(calibrated_subjsynts_diff(:, 1), subjHG(:, 62), 25, 20, 'k+', autumn);
% figure, scattercloud(calibrated_subjsynts_diff(:, 1), subjHG(:, 8), 25, 20, 'k+', autumn);
% mask = calibrated_subjsynts_diff(:, 1) > 0.001;
% figure, scattercloud(calibrated_subjsynts_diff(mask, 1), subjHG(mask, 4), 25, 20, 'k+', autumn)
% figure, scattercloud(calibrated_subjsynts_diff(mask, 1), subjHG(mask, 62), 25, 20, 'k+', autumn);
% 





% coeffmaps = xcov_analyzesubj(params.subjects{8}, 5, 1);
% load('C:\Users\jiwu\Desktop\recon\9ab7ab\other\trodes.mat')
% for iter = 1:6
% figure
% PlotDotsmod('9ab7ab', [params.recondir '/9ab7ab/'], Grid, coeffmaps(:, iter), true, 'l', [min(coeffmaps(:)) max(coeffmaps(:))], 12, 'autumn', 1:64, true)
% colorbar
% end