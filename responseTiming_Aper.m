% responseTiming_Aper determines the response timing of the subject, defined
% as the time between the onset of an error signal stim (i.e., the
% beginning of a stimulus train that indicates that the subject is outside
% of the target region) and the subject changing the direction of motion of
% their hand

%% Timing analysis

trial = 13;
startTime = 19;
endTime = 134;
fileName = strcat('C:\Users\jcronin\Data\Subjects\ecb43e, April 2015\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-', num2str(trial));
load(fileName);

SamplingRate = Stim.info.SamplingRateHz;
Stim_timeStep = 1/SamplingRate;
Stim_time = (0:length(Stim.data(:,1))-1)/SamplingRate;

Aper_SamplingRate = Aper.info.SamplingRateHz;
Aper_timeStep = 1/Aper_SamplingRate;
Aper_time = (0:length(Aper.data(:,1))-1)/Aper_SamplingRate;

figure
plot(Aper_time, Aper.data(:,1),'b')
hold on
plot(Aper_time, Aper.data(:,2),'g')
plot(Aper_time, Aper.data(:,3),'g')

%%

startSampAper = floor(startTime*Aper_SamplingRate);

%Calculate start time for the trial based on when trace first enters the
%target position:
startSampAper = find(Aper.data(startSampAper:end,1)<Aper.data(startSampAper:end,2) & Aper.data(startSampAper:end,1)>Aper.data(startSampAper:end,3), 1) + startSampAper - 1;
endSampAper = floor(endTime*Aper_SamplingRate);

% stimSampled = Stim.data(startSampStim:SamplingRate/Aper_SamplingRate:endSampStim,5);
% stimSampled = stim(1:SamplingRate/Aper_SamplingRate:end,5);
aper =  Aper.data(startSampAper:endSampAper,1);

%wts = [1/24;repmat(1/12,11,1);1/24];
samps = floor(Aper_SamplingRate/3);
if mod(samps,2)==0 % if samps is even
    samps = samps + 1; % add 1 to samps to make it odd, so that the moving average is symmetric
end
wts = repmat(1/samps,samps,1);
aperFilt = conv(aper,wts,'same'); % LOOK INTO THIS MORE!!!!!

aperFilt = aperFilt(floor(samps/2)+1:end-floor(samps/2));

startSampAper = startSampAper + floor(samps/2);
endSampAper = endSampAper - floor(samps/2);
startTime = startSampAper/Aper_SamplingRate;
endTime = endSampAper/Aper_SamplingRate;
startSampStim = floor(startTime*SamplingRate);
endSampStim = floor(endTime*SamplingRate);

plot(aper, 'g')
hold on
plot(aperFilt, 'b')
plot(Aper.data(startSampAper:endSampAper,2),'r')
plot(Aper.data(startSampAper:endSampAper,3),'r')
title('Moving average filtered aperture data');

[stimChanges, stimChanges_pks, stimChanges_time] = StimStarts(Stim.data(startSampStim:endSampStim,4), SamplingRate, max(Stm0.data(:,13)));
stimChanges_samps = stimChanges_time*Aper_SamplingRate;
stateChanges = zeros(size(stimChanges_pks));
stateChanges(stimChanges_pks == max(Stm1.data(:,1))) =  3;  
stateChanges(stimChanges_pks == max(Stm0.data(:,1))) =  1;
stateChanges(stimChanges_pks == 0) =  2;

%% Time to successful correction
try
    load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_correctionTime', 'avg_correctionTime');
catch
    avg_correctionTime = zeros(19,2);
    save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_correctionTime', 'avg_correctionTime');
end

% out = double(aper > Aper.data(startSampAper:endSampAper-1,2) | aper < Aper.data(startSampAper:endSampAper-1,3));
out = double(aperFilt > Aper.data(startSampAper:endSampAper,2) | aperFilt < Aper.data(startSampAper:endSampAper,3));

corrTimeLow = zeros(size(find(stateChanges==3)));
corrTimeHigh = zeros(size(find(stateChanges==2)));

above_ind = 1;
below_ind = 1;
for i=1:length(stateChanges)
    if stateChanges(i) == 3 % Too closed
        % Count samples until back in target range (opening hand)
        j=ceil(stimChanges_samps(i));
        while j<length(out) && out(j)==1
            corrTimeLow(below_ind) = corrTimeLow(below_ind) + 1;
            j=j+1;
        end
        below_ind = below_ind + 1;
    elseif stateChanges(i) == 2 % Too open
        % Count samples until back in target range (closing hand)
        j=ceil(stimChanges_samps(i));
        while j<length(out) && out(j)==1
            corrTimeHigh(above_ind) = corrTimeHigh(above_ind) + 1;
            j=j+1;
        end
        above_ind = above_ind + 1;
    end
end 

corrTimeLow = corrTimeLow/Aper_SamplingRate;
corrTimeHigh = corrTimeHigh/Aper_SamplingRate;

avg_corrTimeLow = mean(corrTimeLow)
avg_corrTimeHigh = mean(corrTimeHigh)

figure
subplot(2,1,1)
plot(corrTimeLow);
xlabel('Trials');
ylabel('Time (s)');
title('Correction Time when too closed');
subplot(2,1,2)
plot(corrTimeHigh);
xlabel('Trials');
ylabel('Time (s)');
title('Correction Time when too open');

% Save
avg_correctionTime(trial, 1) = avg_corrTimeLow;
avg_correctionTime(trial, 2) = avg_corrTimeHigh;
save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_correctionTime', 'avg_correctionTime');

%% Response time (Stim to Change in the sign of the velocity, or change in the direction of movement)
try
    load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_responseTime', 'avg_responseTime');
catch
    avg_responseTime = zeros(19,2);
    save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_responseTime', 'avg_responseTime');
end

dx=diff(aperFilt);

samps = floor(Aper_SamplingRate/2);
if mod(samps,2)==0 % if samps is even
    samps = samps + 1; % add 1 to samps to make it odd, so that the moving average is symmetric
end
wts = repmat(1/samps,samps,1);
dxFilt = conv(dx, wts, 'same'); % LOOK INTO THIS MORE!!!!!

[locsPos, locsNeg] = ZeroCrossing_basic(dxFilt); % locs corresponds to the aperture samples

figure
plot(aper, 'g')
hold on
plot(aperFilt, 'b')
plot(Aper.data(startSampAper:endSampAper,2),'r')
plot(Aper.data(startSampAper:endSampAper,3),'r')
stem(locsPos, ones(size(locsPos)), 'c')
stem(locsNeg, ones(size(locsNeg)), 'y')

respTimeLow = zeros(size(find(stateChanges==3)));
respTimeHigh = zeros(size(find(stateChanges==2)));
high_ind = 1;
low_ind = 1;

for i=1:length(stateChanges)-1
    if stateChanges(i) == 3 % Too closed
        % Count samples until back in target range (opening hand)
        j=ceil(stimChanges_samps(i));
        switchDir = locsPos(find(locsPos>j, 1));
        respTimeLow(low_ind) = switchDir - j;
        low_ind = low_ind + 1;
    elseif stateChanges(i) == 2 % Too open
        % Count samples until back in target range (closing hand)
        j=ceil(stimChanges_samps(i));
        switchDir = locsNeg(find(locsNeg>j, 1));
        respTimeHigh(high_ind) = switchDir - j;
        high_ind = high_ind + 1;
    end
end

respTimeLow = respTimeLow/Aper_SamplingRate;
respTimeHigh = respTimeHigh/Aper_SamplingRate;

avg_respTimeLow = mean(respTimeLow)
avg_respTimeHigh = mean(respTimeHigh)

figure
subplot(2,1,1)
plot(respTimeLow);
xlabel('Trials');
ylabel('Time (s)');
title('Response Time when too closed');
subplot(2,1,2)
plot(respTimeHigh);
xlabel('Trials');
ylabel('Time (s)');
title('Response Time when too open');

% Save
avg_responseTime(trial,1) = avg_respTimeLow;
avg_responseTime(trial,2) = avg_respTimeHigh;
save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_responseTime', 'avg_responseTime');

%% Periods of time that subject's trace remains in the target range
try
    load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_inTime', 'avg_inTime');
catch
    avg_inTime = zeros(19,1);
    save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_inTime', 'avg_inTime');
end

in = double(~out);

[pks,locs] = findpeaks(in);
inTime=zeros(size(pks));
for i=1:length(pks)-1
    inTime(i) = sum(in(locs(i):locs(i+1)-1))/Aper_SamplingRate;
end
inTime(end) = sum(in(locs(end):end))/Aper_SamplingRate;
figure
plot(inTime);
title('Time periods spent in the target range');
% Save
avg_time_inside = mean(inTime)
avg_inTime(trial) = avg_time_inside;
save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_inTime', 'avg_inTime');

num_insidePeriods = length(inTime)

%% TO-DO: Time to successful correction, when followed by x amount of time inside the target range
