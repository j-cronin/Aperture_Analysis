function [starts, startsPks, startsTime] = StimStarts(stimWave, stimSamplingRateHz, ITI_samples)
%StimStarts will return the indeces of the stimWave that start each
%stimulation when there's a state change

%TO-DO:    Detailed explanation goes here

[pks,locs] = findpeaks(stimWave);

stimEnvelope = zeros(size(stimWave));
ITI_sampsStored = stimSamplingRateHz*ITI_samples*10^(-3);
for i=1:length(locs)-1
    if pks(i) == pks(i+1) && (locs(i+1)-locs(i))<=ITI_sampsStored + 121
        stimEnvelope(locs(i):locs(i+1)) = pks(i);
    else
        stimEnvelope(locs(i):locs(i)+121+ITI_sampsStored) = pks(i);
    end
end

starts = find(diff(stimEnvelope)~=0)+1;
startsTime = starts/stimSamplingRateHz;
startsPks = stimEnvelope(starts);

figure
plot(stimWave,'r')
hold on
plot(stimEnvelope, 'b');
stem(starts, startsPks, 'c');
end

