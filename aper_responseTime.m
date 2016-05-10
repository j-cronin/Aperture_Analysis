function [ responseTime_open, responseTime_closed, responseTime_in  ] = aper_responseTime(locs_movement, stimChanges, stimPeaks, Fs, targetStimAmp, closedStimAmp, allLocs)
% aper_responseTime returns the response timing in miliseconds of the subject, defined
% as the time between the onset of an error signal stim (i.e., the
% beginning of a stimulus train that indicates that the subject is outside
% of the target region) and the subject changing the direction of motion of
% their hand. 

% If the allLocs variable = 1, then this will return all the response times
% from the stimulation change sample to all of the locs_movement that are
% between the stim change and the next stim change.
% If the allLocs variable = 0, then this function will return just the one
% response time from the stimulation change to the first locs_movement that
% follows it.

% If stim changes are outside of the boundary (i.e. stimPeaks are equal to
% 0:too open, or the high intensity stim: too closed), count the samples
% from the stimChanges locations until the next locs_movement
% until the next significant change in movement (locs_movement)

% First, outside of boundary because too open:
stimChanges_open = stimChanges(stimPeaks(1:end-1)==0);
responseTime_open = cell(size(stimChanges_open));
for i=1:length(stimChanges_open)
    try
        if allLocs
            nextStimChange = stimChanges(find(stimChanges>stimChanges_open(i),1)); % This is the next stim change after the current stimChange_open
            % Do the above because we only want to look for locs_movement
            % between the two consecutive stim changes, regardless of the
            % state of that stim change.
            % Below will find all of the locs_movement between the two
            % stimChanges and subtract the stimChanges_open sample number
            % from those
            responseTime_open{i} = locs_movement(locs_movement>stimChanges_open(i) & locs_movement<nextStimChange) - stimChanges_open(i);
        else
            index = find(locs_movement>stimChanges_open(i), 1);
            responseTime_open{i} = locs_movement(index) - stimChanges_open(i);
        end
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_open = responseTime_open(1:i-1);
        break
    end
end
    
% Now, outside of boundary because too closed:
stimChanges_closed = stimChanges(stimPeaks(1:end-1)==closedStimAmp);
responseTime_closed = cell(size(stimChanges_closed));
for i=1:length(stimChanges_closed)
    try
        if allLocs
            nextStimChange = stimChanges(find(stimChanges>stimChanges_closed(i),1)); % This is the next stim change after the current stimChange_open
            % Do the above because we only want to look for locs_movement
            % between the two consecutive stim changes, regardless of the
            % state of that stim change.
            % Below will find all of the locs_movement between the two
            % stimChanges and subtract the stimChanges_open sample number
            % from those
            responseTime_closed{i} = locs_movement(locs_movement>stimChanges_closed(i) & locs_movement<nextStimChange) - stimChanges_closed(i);
        else
            index = find(locs_movement>stimChanges_closed(i), 1);
            responseTime_closed{i} = locs_movement(index) - stimChanges_closed(i);
        end
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_closed = responseTime_closed(1:i-1);
        break
    end
end

% Now, inside of boundary:
stimChanges_in = stimChanges(stimPeaks(1:end-1)==targetStimAmp);
responseTime_in = cell(size(stimChanges_in));
for i=1:length(stimChanges_in)
    try
        if allLocs
            nextStimChange = stimChanges(find(stimChanges>stimChanges_in(i),1)); % This is the next stim change after the current stimChange_open
            % Do the above because we only want to look for locs_movement
            % between the two consecutive stim changes, regardless of the
            % state of that stim change.
            % Below will find all of the locs_movement between the two
            % stimChanges and subtract the stimChanges_open sample number
            % from those
            responseTime_in{i} = locs_movement(locs_movement>stimChanges_in(i) & locs_movement<nextStimChange) - stimChanges_in(i);
        else
            index = find(locs_movement>stimChanges_in(i), 1);
            responseTime_in{i} = locs_movement(index) - stimChanges_in(i);
        end
    catch
        % warning('No significant movement changes after the stim state change');
        responseTime_in = responseTime_in(1:i-1);
        break
    end
end

% Convert from cell to array and then Convert from samples to ms
responseTime_open = cell2mat(responseTime_open)/Fs*100;
responseTime_closed = cell2mat(responseTime_closed)/Fs*100;
responseTime_in = cell2mat(responseTime_in)/Fs*100;
    
end

