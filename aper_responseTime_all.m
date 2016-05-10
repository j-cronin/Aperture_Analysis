function [ responseTime_open, responseTime_closed, responseTime_in  ] = aper_responseTime_all(locs_movement, stimChanges, stimPeaks, Fs, targetStimAmp, closedStimAmp, correctOnly)
% aper_responseTime returns the response timing in miliseconds of the subject, defined
% as the time between the onset of an error signal stim (i.e., the
% beginning of a stimulus train that indicates that the subject is outside
% of the target region) and the subject changing the direction of motion of
% their hand. 
% If the correctOnly variable = 1, then this will only return
% response times of responses that were made in the correct direction.
% This correctOnly portion has NOT BEEN CODED

% If stim changes are outside of the boundary (i.e. stimPeaks are equal to
% 0:too open, or the high intensity stim: too closed), count the samples
% from the stimChanges locations until the next locs_movement
% until the next significant change in movement (locs_movement)

% First, outside of boundary because too open:
stimChanges_open = stimChanges(stimPeaks(1:end-1)==0);
responseTime_open = zeros(size(stimChanges_open));
for i=1:length(stimChanges_open)
    try
        index = find(locs_movement>stimChanges_open(i), 1);
        responseTime_open(i) = locs_movement(index) - stimChanges_open(i);
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_open = responseTime_open(1:i-1);
        break
    end
end
    
% Now, outside of boundary because too closed:
stimChanges_closed = stimChanges(stimPeaks(1:end-1)==closedStimAmp);
responseTime_closed = zeros(size(stimChanges_closed));
for i=1:length(stimChanges_closed)
    try
        index = find(locs_movement>stimChanges_closed(i), 1);
        responseTime_closed(i) = locs_movement(index) - stimChanges_closed(i);
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_closed = responseTime_closed(1:i-1);
        break
    end
end

% Now, inside of boundary:
stimChanges_in = stimChanges(stimPeaks(1:end-1)==targetStimAmp);
responseTime_in = zeros(size(stimChanges_in));
for i=1:length(stimChanges_in)
    try
        index = find(locs_movement>stimChanges_in(i), 1);
        responseTime_in(i) = locs_movement(index) - stimChanges_in(i);
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_in = responseTime_in(1:i-1);
        break
    end
end

% Convert from samples to ms
responseTime_open = responseTime_open/Fs*100;
responseTime_closed = responseTime_closed/Fs*100;
responseTime_in = responseTime_in/Fs*100;
    
end

