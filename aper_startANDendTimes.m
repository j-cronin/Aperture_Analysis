function [ startTime, endTime ] = aper_startANDendTimes(data, time, practiceTrial)
%% Determine start time and end time
% The startTime and endTime parameters indicate what region of the task to
% consider in seconds (i.e., you can cut out the portion of the trace
% before the stim was turned on - indicated by the discontinuity in the
% target path when it resets to it's starting location - and you can cut
% out the last second or two if you notice another discontinuity which
% sometimes occurs).
% This determines the start and end times.
% 'practiceTrial' should either be 'yes' or 'no', indicating whether or not
% the trial for the given data set was a practice trial

dx = diff(data);
[pks, locs] = findpeaks(abs(dx));
[~, I] = sort(pks, 'descend');
sortIndeces = sort(I(1:3), 'descend');

if strcmp(practiceTrial, 'yes')
    % When it is a practice trial with straight lines at the beginning, the
    % diff approach of finding the start time (as used below) does not
    % work. Instead, just determine what the start time should be based on
    % the end time.
    [~, firstloc] = findpeaks(abs(dx), 'NPeaks', 2);
    startLoc = firstloc(2)-(locs(sortIndeces(1)) - firstloc(2));
    startTime = ceil(time(startLoc));
    endTime = floor(time(locs(I(1))));
    
elseif strcmp(practiceTrial, 'no')
    startTime = ceil(time(locs(sortIndeces(2))));
    endTime = floor(time(locs(sortIndeces(1))));
else
    error('practiceTrial parameter must either be <yes> or <no>');
end

end

