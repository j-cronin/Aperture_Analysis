addpath('C:\Users\jcronin\Box Sync\Code\Matlab\DataGlove');

SIDS = {'ecb43e' 'fca96e' 'cdceeb'};

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
            wp = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\'; % write path
            rp_matlab = 'C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\'; % read path for Matlab data (includes glove data)
            rp = strcat(rp_matlab, 'Matlab\Aperture-'); % read path TDT data
            trials = [2 5 7 8 9 10 12 13 15 16 17];
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
            wp = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\'; % write path
            rp_matlab = 'C:\Users\jcronin\Data\Subjects\cdceeb (wrong-f3e511)\data\d14\Aperture_cdceeb\'; % read path for Matlab data (includes glove data)
            rp = strcat(rp_matlab, 'Matlab\ApertureCheck-'); % read path TDT data
            trials = [1 2 3];
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
    
    trialNum = num2str(trials(idx));
    fileName = strcat(rp, trialNum); % read path
    
    %% Execute functions on subject data
    [gloveRawMean] = getGloveMeans(sid, trials_matlab, matlab_prefix, rp_matlab);
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\gloveMeans\';
    % Save
    save(strcat(pathToSave, sid, '_gloveMeans'), 'gloveRawMean');
    
end