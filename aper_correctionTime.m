function [ correctionTime_open, correctionTime_closed  ] = aper_correctionTime(locs_reenters_open, locs_reenters_closed, stimChanges, stimPeaks, Stm1, Fs)
% aper_correctionTime determines the response timing of the subject, defined
% as the time between the onset of an error signal stim (i.e., the
% beginning of a stimulus train that indicates that the subject is outside
% of the target region) and the subject re-entering the target region

% If stim changes are outside of the boundary (i.e. stimPeaks are equal to
% 0:too open, or the high intensity stim: too closed), count the samples
% from the stimChanges locations until the hand re-enters the target region

% First, outside of boundary because too open:
stimChanges_open = stimChanges(stimPeaks(1:end-1)==0);
correctionTime_open = zeros(size(stimChanges_open));
for i=1:length(stimChanges_open)
    try
        index = find(locs_reenters_open>stimChanges_open(i), 1);
        correctionTime_open(i) = locs_reenters_open(index) - stimChanges_open(i);
    catch
        warning('Did not re-enter after the last stim state change');
        correctionTime_open = correctionTime_open(1:i-1);
        break
    end
end

% Now, outside of boundary because too closed:
stimChanges_closed = stimChanges(stimPeaks(1:end-1)==max(Stm1.data(:,1)));
correctionTime_closed = zeros(size(stimChanges_closed));
for i=1:length(stimChanges_closed)
    try
        index = find(locs_reenters_closed>stimChanges_closed(i), 1);
        correctionTime_closed(i) = locs_reenters_closed(index) - stimChanges_closed(i);
    catch
        warning('Did not re-enter after the last stim state change');
        correctionTime_closed = correctionTime_closed(1:i-1);
        break
    end
end

% Convert from samples to ms
correctionTime_open = correctionTime_open/Fs*100;
correctionTime_closed = correctionTime_closed/Fs*100;

end

