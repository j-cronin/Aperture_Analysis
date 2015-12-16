ecb43e_trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];
ecb43e_trials_NV = [4 9 10 11 12 13 14 15 16 18 19];

for i=1:length(ecb43e_trials_NV)
    sid = 'ecb43e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
    trialNum = num2str(ecb43e_trials(i));
    fileName = strcat('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-', trialNum);
    %     aper_ANALYSIS(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justR2(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justDX3(sid, pathToSave, fileName, trialNum);
    aper_ANALYSIS_justResponseTime(sid, pathToSave, fileName, trialNum);
end

fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
fca96e_trials_NV = [5 7 8 9 10 17];
for i=1:length(fca96e_trials_NV)
    sid = 'fca96e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
    trialNum = num2str(fca96e_trials_NV(i));
    fileName = strcat('C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-', trialNum);
    %     aper_ANALYSIS(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justR2(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justDX3(sid, pathToSave, fileName, trialNum);
    aper_ANALYSIS_justResponseTime(sid, pathToSave, fileName, trialNum);
end

cdceeb_trials = [1 2 3];
cdceeb_trials_NV = [1 2 3];
for i=1:length(cdceeb_trials_NV)
    sid = 'cdceeb';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
    trialNum = num2str(cdceeb_trials_NV(i));
    fileName = strcat('C:\Users\jcronin\Data\Subjects\cdceeb (wrong-f3e511)\data\d14\Aperture_cdceeb\Matlab\ApertureCheck-', trialNum);
    %     aper_ANALYSIS(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justR2(sid, pathToSave, fileName, trialNum);
    %aper_ANALYSIS_justDX3(sid, pathToSave, fileName, trialNum);
    aper_ANALYSIS_justResponseTime(sid, pathToSave, fileName, trialNum);
end
