% have loaded: a samples x channels x epochs matrix, fs = sample rate, bad
% channels (from montage)
% know where your electrodes are and what condition it is
% Version 1 - June 2015 - Kaitlyn
%data = your signal

% Initialize
numepochs = size(data,1);
numchans = size(data{1},2);
% badChans = [];

% Process
HGPower = cell(size(data));
betaPower = cell(size(data));
% PLV
HGPlv = zeros(numchans, numchans, numepochs);
maskedHGPlvs = zeros(numchans, numchans, numepochs);
betaPlv = zeros(numchans, numchans, numepochs);
maskedbetaPlvs = zeros(numchans, numchans, numepochs);
% PSI
HG_psi = zeros(numchans, numchans, numepochs);
HG_maskedpsi = zeros(numchans, numchans, numepochs);

% parpool(16)

parfor k = 1:numepochs
    epochData = data{k};
    
    % Process
%     samples = size(data{k},1);
%     HGPower = zeros(samples, numchans, numepochs);
%     betaPower = zeros(samples, numchans, numepochs);
%     HGPower(:,:,k) = hilbAmp(epochData, [70 200], fs).^2;
%     betaPower(:,:,k) = hilbAmp(epochData, [12 30], fs).^2;
    HGPower{k} = hilbAmp(epochData, [70 200], fs).^2;
    betaPower{k} = hilbAmp(epochData, [12 30], fs).^2;
    
    % PLV
    HGPlv(:,:,k) = plv_revised(epochData);
    betaPlv(:,:,k) = plv_revised(epochData);
    [maskedHGPlvs(:,:,k), maskedbetaPlvs(:,:,k)] = mini_phaseshuff( epochData, fs, badChans, HGPlv(:,:,k), betaPlv(:,:,k), 20);
    
    % PSI
    [HG_psi(:,:,k), HG_maskedpsi(:,:,k)] = PSI_HGonly(data{k}, fs); %yes you really do pass it the broadband signal
    
end

fileNameSave = strcat('analysis/', sid, '_PLV_trial_',trialNum);
save(fileNameSave, 'HGPower', 'betaPower', 'HGPlv', 'betaPlv', 'maskedHGPlvs', 'maskedbetaPlvs', 'HG_psi', 'HG_maskedpsi');




