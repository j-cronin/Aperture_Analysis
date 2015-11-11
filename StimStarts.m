function [starts, startsPks, startsTime] = StimStarts(stimWave, stimSamplingRateHz, ITI, PTD, IPI, stateChange)
% StimStarts will return the indeces of the stimWave that start each
% stimulation train or that start each stim train when there's a state
% change. 

% TO-DO!!
%   ARGUMENTS
%   stimWave (double []) is ....
%   stimSamplingRateHz (double) is the sampling rate of the stimWave data
%   ITI (double) inter-train interval (ms). The miliseconds that follow a train. 
%       For the purposes of enveloping the stim signal based on the current
%       stim state, the ITI interval that follows the train will be
%       considered part of that train's stim state. Thus, if a subject is
%       trying to recognize changes in the stim waveform (or stim state),
%       we consider the ITI part of the previous stim train such that the
%       state change actually occurs at the end of the ITI, or at the start
%       of a new train (whichever comes first).
%   PTD (double) pulse train duration (ms)
%   IPI (double) inter-pulse interval (us)
%   stateChange (string) can either be 'on' or 'off'. When stateChange is
%       'on' StimStarts will only return the start of each stim train that
%       begins a state change. When stateChange is 'off', StimStarts will
%       return the start of every stim train, independent of whether or not
%       there's been a state change (i.e. a change in the stimulation
%       somehow). If empty, stateChange will default to 'off'
%
%   RETURNS
%   starts (double []) sample location of all of the peak starts (keeping
%       in mind the stateChange argument
%   startsPks (double []) peak values at each sample in starts
%   startsTime (double []) time in seconds of each sample location
 

%TO-DO:    Detailed explanation goes here
% Update so that 121 samples isn't hard coded
% Doesn't default to stateChange = 'off'

[pks,locs] = findpeaks(stimWave);

stimEnvelope = zeros(size(stimWave));
ITI_samps = stimSamplingRateHz*ITI*10^(-3);
PTD_samps = stimSamplingRateHz*PTD*10^(-3);
IPI_samps = stimSamplingRateHz*IPI*10^(-6);

if (strcmp(stateChange, 'on'))
    for i=1:length(locs)-1
        if pks(i) == pks(i+1) && (locs(i+1)-locs(i))<=ITI_samps + IPI_samps
            stimEnvelope(locs(i):locs(i+1)) = pks(i);
        else
            stimEnvelope(locs(i):locs(i)+IPI_samps+ITI_samps) = pks(i);
        end
    end
    
elseif (strcmp(stateChange, 'off') || strcmp(stateChange, []))
    if strcmp(stateChange, [])
        warning('stateChange defaulted to off, returning starts of all stim trains');
    end
    
    for i=1:length(locs)-1
        if pks(i) == pks(i+1) && (locs(i+1)-locs(i))<=PTD_samps
            stimEnvelope(locs(i):locs(i+1)) = pks(i);
        else
            stimEnvelope(locs(i):locs(i)+IPI_samps) = pks(i);
        end
    end
else
    error('stateChange must be set to "on", "off", or left out');
end

    

starts = find(diff(stimEnvelope)~=0)+1;
startsTime = starts/stimSamplingRateHz;
startsPks = stimEnvelope(starts);

figure
plot(stimWave,'r')
hold on
plot(stimEnvelope, 'b');
stem(starts, startsPks, 'c');
title('Stimulation envelope and stem points marking the start of state changes or trains');

end

