function [ chanceResponseTimes ] = aper_responseTime_chance( stimChanges_aperSamps, stimPks, entersTarget,  pos_shuffled, fs_aper, amp0, amp1)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Chance response timing calculations (use the same 1000 shuffled positions from accuracy & R^2 calculations):
temp = stimChanges_aperSamps>=entersTarget;
chanceStimChanges = stimChanges_aperSamps(temp); % this only includes the stimChanges (in aperture samples) that occur after the entersTarget sample.
chanceStimChanges = chanceStimChanges - entersTarget + 1;
chanceStimPks = stimPks(temp); % this only includes the stimPks (in aperture samples) that occur after the entersTarget sample.

responseTime_open = cell(1,1,size(pos_shuffled,2));
responseTime_closed = cell(1,1,size(pos_shuffled,2));
responseTime_in = cell(1,1,size(pos_shuffled,2));
parfor ind = 1:size(pos_shuffled,2)
    % find significant changes in movement for each random walk:
    [chanceRT_movement_locs, ~, ~, ~] = aper_coherence_3(pos_shuffled(:,ind), fs_aper);
    [ responseTime_open{ind}, responseTime_closed{ind}, responseTime_in{ind}] = aper_responseTime(chanceRT_movement_locs, chanceStimChanges, chanceStimPks, fs_aper, amp0, amp1, 0);
end
chanceResponseTimes = [responseTime_open, responseTime_closed, responseTime_in];
end

